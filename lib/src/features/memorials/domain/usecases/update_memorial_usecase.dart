import 'package:memorial_keeper/src/utils/utils.dart';
import '../entities/memorial.dart';
import '../repositories/memorial_repository.dart';

class UpdateMemorialUseCase implements UseCase<Memorial, Memorial> {
  UpdateMemorialUseCase(this._repository);

  final MemorialRepository _repository;

  @override
  FutureEither<Memorial> call(Memorial memorial) {
    return _repository.updateMemorial(memorial);
  }
}
