import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/utils.dart';
import '../config/app_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  FirebaseAuth get _firebaseAuth => AppConfig.firebaseAuth;
  FirebaseFirestore get _firestore => AppConfig.firestore;

  /// Stream of auth state changes. Emits the current user map with Firestore profile or null.
  Stream<Map<String, dynamic>?> get authStateChanges {
    return logAuthStateChanges(
      _firebaseAuth.authStateChanges().asyncMap((User? user) async {
        if (user == null) return null;
        try {
          final doc = await _firestore.collection('users').doc(user.uid).get();
          if (doc.exists && doc.data() != null) {
            final data = doc.data()!;
            return {
              'id': user.uid,
              'email': data['email']?.toString() ?? user.email ?? '',
              'name': data['name']?.toString() ?? user.displayName ?? '',
              'photoUrl': data['photoUrl']?.toString() ?? user.photoURL,
              'dateOfBirth': data['dateOfBirth']?.toString(),
            };
          }
        } catch (_) {}
        return {
          'id': user.uid,
          'email': user.email ?? '',
          'name': user.displayName ?? '',
          'photoUrl': user.photoURL,
          'dateOfBirth': null,
        };
      }),
      userIdOf: (user) => user['id'] as String? ?? '',
    );
  }

  FutureEither<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    return runTask(
      () async {
        final credentials = await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        final user = credentials.user;
        if (user == null) return null;

        try {
          final doc = await _firestore.collection('users').doc(user.uid).get();
          if (doc.exists && doc.data() != null) {
            final data = doc.data()!;
            return {
              'id': user.uid,
              'email': data['email']?.toString() ?? user.email ?? email,
              'name': data['name']?.toString() ?? user.displayName ?? '',
              'photoUrl': data['photoUrl']?.toString() ?? user.photoURL,
              'dateOfBirth': data['dateOfBirth']?.toString(),
            };
          }
        } catch (_) {}

        // Fallback: create doc if it did not exist
        final fallbackData = {
          'id': user.uid,
          'email': user.email ?? email,
          'name': user.displayName ?? '',
          'photoUrl': user.photoURL,
          'dateOfBirth': null,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(fallbackData, SetOptions(merge: true));

        return {
          'id': user.uid,
          'email': user.email ?? email,
          'name': user.displayName ?? '',
          'photoUrl': user.photoURL,
          'dateOfBirth': null,
        };
      },
      operation: 'auth.login',
      category: LogCategory.auth,
      context: {'method': 'email'},
      requiresNetwork: true,
    );
  }

  FutureEither<Map<String, dynamic>?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    return runTask(
      () async {
        final credentials = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final user = credentials.user;
        if (user == null) return null;

        await user.updateDisplayName(name);

        final userData = {
          'id': user.uid,
          'email': user.email ?? email,
          'name': name,
          'photoUrl': user.photoURL,
          'dateOfBirth': null,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        // Persist to Firestore 'users' collection
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userData, SetOptions(merge: true));

        return {
          'id': user.uid,
          'email': user.email ?? email,
          'name': name,
          'photoUrl': user.photoURL,
          'dateOfBirth': null,
        };
      },
      operation: 'auth.signUp',
      category: LogCategory.auth,
      context: {'method': 'email'},
      requiresNetwork: true,
    );
  }

  FutureEither<void> forgotPassword({required String email}) async {
    return runTask(
      () async {
        await _firebaseAuth.sendPasswordResetEmail(email: email);
      },
      operation: 'auth.forgotPassword',
      category: LogCategory.auth,
      requiresNetwork: true,
    );
  }

  bool _isGoogleSignInInitialized = false;

  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_isGoogleSignInInitialized) {
      try {
        await GoogleSignIn.instance.initialize(
          serverClientId:
              '1081913766740-1obhmdj6svbmq3uutps664tpr8m58esa.apps.googleusercontent.com',
        );
      } catch (_) {
        // Safe if already initialized
      }
      _isGoogleSignInInitialized = true;
    }
  }

  FutureEither<Map<String, dynamic>?> loginWithGoogle() async {
    return runTask(
      () async {
        await _ensureGoogleSignInInitialized();

        final GoogleSignInAccount account;
        try {
          account = await GoogleSignIn.instance.authenticate();
        } on GoogleSignInException catch (e) {
          if (e.code == GoogleSignInExceptionCode.canceled) {
            // User cancelled Google sign-in dialog
            return null;
          }
          rethrow;
        }

        final GoogleSignInAuthentication auth = account.authentication;
        final String? idToken = auth.idToken;

        if (idToken == null) {
          throw const ServerFailure('No ID token received from Google sign-in.');
        }

        final OAuthCredential credential = GoogleAuthProvider.credential(
          idToken: idToken,
        );

        final userCredential =
            await _firebaseAuth.signInWithCredential(credential);
        final user = userCredential.user;
        if (user == null) return null;

        // Ensure user document exists in Firestore 'users' collection
        final userDocRef = _firestore.collection('users').doc(user.uid);
        final docSnap = await userDocRef.get();

        if (!docSnap.exists) {
          final newUserData = {
            'id': user.uid,
            'email': user.email ?? '',
            'name': user.displayName ?? '',
            'photoUrl': user.photoURL,
            'dateOfBirth': null,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          };
          await userDocRef.set(newUserData);
          return {
            'id': user.uid,
            'email': user.email ?? '',
            'name': user.displayName ?? '',
            'photoUrl': user.photoURL,
            'dateOfBirth': null,
          };
        } else {
          final data = docSnap.data();
          await userDocRef.update({'updatedAt': FieldValue.serverTimestamp()});
          return {
            'id': user.uid,
            'email': data?['email']?.toString() ?? user.email ?? '',
            'name': data?['name']?.toString() ?? user.displayName ?? '',
            'photoUrl': data?['photoUrl']?.toString() ?? user.photoURL,
            'dateOfBirth': data?['dateOfBirth']?.toString(),
          };
        }
      },
      operation: 'auth.loginWithGoogle',
      category: LogCategory.auth,
      context: {'method': 'google'},
      requiresNetwork: true,
    );
  }

  FutureEither<void> logout() async {
    return runTask(
      () async {
        try {
          await GoogleSignIn.instance.signOut();
        } catch (_) {}
        await _firebaseAuth.signOut();
      },
      operation: 'auth.logout',
      category: LogCategory.auth,
      requiresNetwork: true,
    );
  }

  FutureEither<Map<String, dynamic>?> getCurrentUser() async {
    return runTask(
      () async {
        final user = _firebaseAuth.currentUser;
        if (user == null) return null;
        try {
          final doc = await _firestore.collection('users').doc(user.uid).get();
          if (doc.exists && doc.data() != null) {
            final data = doc.data()!;
            return {
              'id': user.uid,
              'email': data['email']?.toString() ?? user.email ?? '',
              'name': data['name']?.toString() ?? user.displayName ?? '',
              'photoUrl': data['photoUrl']?.toString() ?? user.photoURL,
              'dateOfBirth': data['dateOfBirth']?.toString(),
            };
          }
        } catch (_) {}
        return {
          'id': user.uid,
          'email': user.email ?? '',
          'name': user.displayName ?? '',
          'photoUrl': user.photoURL,
          'dateOfBirth': null,
        };
      },
      operation: 'auth.getCurrentUser',
      category: LogCategory.auth,
    );
  }

  /// Update user profile data in Firestore and Firebase Auth
  FutureEither<Map<String, dynamic>> updateProfile({
    required String userId,
    String? name,
    String? photoUrl,
    String? dateOfBirth,
  }) async {
    return runTask(
      () async {
        final updates = <String, dynamic>{
          'updatedAt': FieldValue.serverTimestamp(),
          'dateOfBirth': dateOfBirth,
          'photoUrl': photoUrl,
        };
        if (name != null) updates['name'] = name;

        await _firestore
            .collection('users')
            .doc(userId)
            .set(updates, SetOptions(merge: true));

        final currentUser = _firebaseAuth.currentUser;
        if (currentUser != null) {
          if (name != null && name.isNotEmpty) {
            await currentUser.updateDisplayName(name);
          }
          await currentUser.updatePhotoURL(photoUrl);
        }

        final doc = await _firestore.collection('users').doc(userId).get();
        final data = doc.data() ?? {};
        return {
          'id': userId,
          'email': data['email']?.toString() ?? currentUser?.email ?? '',
          'name': data['name']?.toString() ?? name ?? '',
          'photoUrl': data['photoUrl']?.toString(),
          'dateOfBirth': data['dateOfBirth']?.toString(),
        };
      },
      operation: 'auth.updateProfile',
      category: LogCategory.auth,
      requiresNetwork: true,
    );
  }

  void dispose() {
    // Firebase manages its own streams
  }
}
