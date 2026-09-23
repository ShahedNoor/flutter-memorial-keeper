import 'package:memorial_keeper/src/utils/utils.dart';
import 'package:memorial_keeper/src/features/auth/domain/repositories/auth_repository.dart';

class ForgotPasswordUseCase implements UseCase<String, void> {
  ForgotPasswordUseCase(this._repository);

  final AuthRepository _repository;

  @override
  FutureEither<void> call(String email) {
    return _repository.forgotPassword(email: email);
  }
}
