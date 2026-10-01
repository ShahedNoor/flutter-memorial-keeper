import 'package:memorial_keeper/src/utils/utils.dart';
import '../../domain/entities/memorial.dart';
import '../../domain/repositories/memorial_repository.dart';
import '../datasources/memorial_local_datasource.dart';
import '../models/memorial_model.dart';

class MemorialRepositoryImpl implements MemorialRepository {
  MemorialRepositoryImpl({MemorialLocalDataSource? localDataSource})
      : _localDataSource = localDataSource ?? MemorialLocalDataSourceImpl();

  final MemorialLocalDataSource _localDataSource;

  @override
  FutureEither<List<Memorial>> getMemorials({
    String? category,
    String? searchQuery,
  }) async {
    return runTask(
      () async {
        final models = await _localDataSource.getMemorials(
          category: category,
          searchQuery: searchQuery,
        );
        return models.map((m) => m.toEntity()).toList();
      },
      operation: 'getMemorials',
      category: LogCategory.app,
    );
  }

  @override
  FutureEither<Memorial?> getMemorialById(String id) async {
    return runTask(
      () async {
        final model = await _localDataSource.getMemorialById(id);
        return model?.toEntity();
      },
      operation: 'getMemorialById',
      category: LogCategory.app,
    );
  }

  @override
  FutureEither<Memorial> addMemorial(Memorial memorial) async {
    return runTask(
      () async {
        final model = MemorialModel.fromEntity(memorial);
        await _localDataSource.insertMemorial(model);
        return model.toEntity();
      },
      operation: 'addMemorial',
      category: LogCategory.app,
    );
  }

  @override
  FutureEither<Memorial> updateMemorial(Memorial memorial) async {
    return runTask(
      () async {
        final model = MemorialModel.fromEntity(memorial);
        await _localDataSource.updateMemorial(model);
        return model.toEntity();
      },
      operation: 'updateMemorial',
      category: LogCategory.app,
    );
  }

  @override
  FutureEither<void> deleteMemorial(String id) async {
    return runTask(
      () async {
        await _localDataSource.deleteMemorial(id);
      },
      operation: 'deleteMemorial',
      category: LogCategory.app,
    );
  }

  @override
  FutureEither<void> toggleFavorite(String id) async {
    return runTask(
      () async {
        await _localDataSource.toggleFavorite(id);
      },
      operation: 'toggleFavorite',
      category: LogCategory.app,
    );
  }
}
