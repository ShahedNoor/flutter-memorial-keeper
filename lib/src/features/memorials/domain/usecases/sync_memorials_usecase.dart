import 'package:memorialkeeper/src/utils/utils.dart';
import '../repositories/memorial_repository.dart';

class SyncMemorialsUseCase {
  final MemorialRepository _repository;

  SyncMemorialsUseCase(this._repository);

  FutureEither<dynamic> call([String? userId]) {
    return _repository.syncMemorials(userId: userId);
  }
}
