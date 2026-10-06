import 'package:memorialkeeper/src/utils/utils.dart';

/// Remote auth contract — hides AuthService / SDK details from repositories.
abstract class AuthRemoteDataSource {
  Stream<Map<String, dynamic>?> get authStateChanges;

  FutureEither<Map<String, dynamic>?> login({
    required String email,
    required String password,
  });

  FutureEither<Map<String, dynamic>?> signUp({
    required String name,
    required String email,
    required String password,
  });

  FutureEither<Map<String, dynamic>?> loginWithGoogle();

  FutureEither<void> forgotPassword({required String email});

  FutureEither<void> logout();

  FutureEither<Map<String, dynamic>?> getCurrentUser();

  FutureEither<Map<String, dynamic>> updateProfile({
    required String userId,
    String? name,
    String? photoUrl,
    String? dateOfBirth,
  });
}
