import 'package:memorialkeeper/src/imports/core_imports.dart';
import 'package:memorialkeeper/src/features/auth/data/datasources/auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({AuthService? authService})
      : _authService = authService ?? AuthService.instance;

  final AuthService _authService;

  @override
  Stream<Map<String, dynamic>?> get authStateChanges =>
      _authService.authStateChanges;

  @override
  FutureEither<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) =>
      _authService.login(email: email, password: password);

  @override
  FutureEither<Map<String, dynamic>?> signUp({
    required String name,
    required String email,
    required String password,
  }) =>
      _authService.signUp(name: name, email: email, password: password);

  @override
  FutureEither<Map<String, dynamic>?> loginWithGoogle() =>
      _authService.loginWithGoogle();

  @override
  FutureEither<void> forgotPassword({required String email}) =>
      _authService.forgotPassword(email: email);

  @override
  FutureEither<void> logout() => _authService.logout();

  @override
  FutureEither<Map<String, dynamic>?> getCurrentUser() =>
      _authService.getCurrentUser();

  @override
  FutureEither<Map<String, dynamic>> updateProfile({
    required String userId,
    String? name,
    String? photoUrl,
    String? dateOfBirth,
  }) =>
      _authService.updateProfile(
        userId: userId,
        name: name,
        photoUrl: photoUrl,
        dateOfBirth: dateOfBirth,
      );
}
