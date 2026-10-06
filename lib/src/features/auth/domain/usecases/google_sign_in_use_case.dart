import 'package:memorialkeeper/src/utils/utils.dart';
import 'package:memorialkeeper/src/features/auth/domain/entities/user.dart';
import 'package:memorialkeeper/src/features/auth/domain/repositories/auth_repository.dart';

class GoogleSignInUseCase implements UseCase<NoParams, AppUser> {
  GoogleSignInUseCase(this._repository);

  final AuthRepository _repository;

  @override
  FutureEither<AppUser> call([NoParams? params]) {
    return _repository.loginWithGoogle();
  }
}
