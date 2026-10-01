import 'package:memorial_keeper/src/utils/utils.dart';
import '../repositories/memorial_repository.dart';

class ToggleFavoriteUseCase implements UseCase<String, void> {
  ToggleFavoriteUseCase(this._repository);

  final MemorialRepository _repository;

  @override
  FutureEither<void> call(String id) {
    return _repository.toggleFavorite(id);
  }
}
