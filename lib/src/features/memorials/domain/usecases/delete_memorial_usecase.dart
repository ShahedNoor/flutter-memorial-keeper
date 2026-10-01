import 'package:memorial_keeper/src/utils/utils.dart';
import '../repositories/memorial_repository.dart';

class DeleteMemorialUseCase implements UseCase<String, void> {
  DeleteMemorialUseCase(this._repository);

  final MemorialRepository _repository;

  @override
  FutureEither<void> call(String id) {
    return _repository.deleteMemorial(id);
  }
}
