import 'package:memorialkeeper/src/services/local_database_service.dart';
import '../models/memorial_model.dart';

abstract class MemorialLocalDataSource {
  Future<List<MemorialModel>> getMemorials({
    String? category,
    String? searchQuery,
  });
  Future<MemorialModel?> getMemorialById(String id);
  Future<void> insertMemorial(MemorialModel memorial);
  Future<void> updateMemorial(MemorialModel memorial);
  Future<void> deleteMemorial(String id);
  Future<void> toggleFavorite(String id);
}

class MemorialLocalDataSourceImpl implements MemorialLocalDataSource {
  final LocalDatabaseService _dbService;

  MemorialLocalDataSourceImpl({LocalDatabaseService? dbService})
      : _dbService = dbService ?? LocalDatabaseService.instance;

  @override
  Future<List<MemorialModel>> getMemorials({
    String? category,
    String? searchQuery,
  }) async {
    final rows = await _dbService.getMemorials(
      category: category,
      searchQuery: searchQuery,
    );
    return rows.map((e) => MemorialModel.fromMap(e)).toList();
  }

  @override
  Future<MemorialModel?> getMemorialById(String id) async {
    final row = await _dbService.getMemorialById(id);
    if (row == null) return null;
    return MemorialModel.fromMap(row);
  }

  @override
  Future<void> insertMemorial(MemorialModel memorial) async {
    await _dbService.insertMemorial(memorial.toMap());
  }

  @override
  Future<void> updateMemorial(MemorialModel memorial) async {
    await _dbService.updateMemorial(memorial.id, memorial.toMap());
  }

  @override
  Future<void> deleteMemorial(String id) async {
    await _dbService.deleteMemorial(id);
  }

  @override
  Future<void> toggleFavorite(String id) async {
    await _dbService.toggleFavorite(id);
  }
}
