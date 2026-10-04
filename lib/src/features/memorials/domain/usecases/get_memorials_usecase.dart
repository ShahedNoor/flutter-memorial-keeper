import 'package:memorialkeeper/src/utils/utils.dart';
import '../entities/memorial.dart';
import '../repositories/memorial_repository.dart';

typedef GetMemorialsParams = ({String? category, String? searchQuery});

class GetMemorialsUseCase
    implements UseCase<GetMemorialsParams, List<Memorial>> {
  GetMemorialsUseCase(this._repository);

  final MemorialRepository _repository;

  @override
  FutureEither<List<Memorial>> call(GetMemorialsParams params) {
    return _repository.getMemorials(
      category: params.category,
      searchQuery: params.searchQuery,
    );
  }
}
