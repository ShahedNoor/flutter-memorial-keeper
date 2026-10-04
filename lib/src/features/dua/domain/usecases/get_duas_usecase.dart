import 'package:memorialkeeper/src/utils/utils.dart';
import '../entities/dua.dart';
import '../repositories/dua_repository.dart';

class GetDuasUseCase implements UseCase<bool, List<Dua>> {
  GetDuasUseCase(this._repository);

  final DuaRepository _repository;

  @override
  FutureEither<List<Dua>> call([bool forceRefresh = false]) {
    return _repository.getDuas(forceRefresh: forceRefresh);
  }
}
