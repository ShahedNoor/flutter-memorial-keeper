import 'package:memorialkeeper/src/utils/utils.dart';
import '../entities/memorial.dart';
import '../repositories/memorial_repository.dart';

class AddMemorialUseCase implements UseCase<Memorial, Memorial> {
  AddMemorialUseCase(this._repository);

  final MemorialRepository _repository;

  @override
  FutureEither<Memorial> call(Memorial memorial) {
    return _repository.addMemorial(memorial);
  }
}
