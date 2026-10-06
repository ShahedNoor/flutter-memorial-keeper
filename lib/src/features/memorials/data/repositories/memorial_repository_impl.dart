import 'dart:async';
import 'package:memorialkeeper/src/services/sync_service.dart';
import 'package:memorialkeeper/src/utils/utils.dart';
import '../../domain/entities/memorial.dart';
import '../../domain/repositories/memorial_repository.dart';
import '../datasources/memorial_local_datasource.dart';
import '../models/memorial_model.dart';

class MemorialRepositoryImpl implements MemorialRepository {
  MemorialRepositoryImpl({
    MemorialLocalDataSource? localDataSource,
    SyncService? syncService,
  })  : _localDataSource = localDataSource ?? MemorialLocalDataSourceImpl(),
        _syncService = syncService ?? SyncService.instance;

  final MemorialLocalDataSource _localDataSource;
  final SyncService _syncService;

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
        final status = _syncService.isAuthenticated ? 'synced' : 'pending_create';
        final model = MemorialModel.fromEntity(memorial.copyWith(
          syncStatus: status,
          updatedAt: DateTime.now(),
        ));

        // 1. Always save to local SQLite first (instant UI, offline tolerance)
        await _localDataSource.insertMemorial(model);

        // 2. If authenticated, attempt background cloud upload
        final userId = _syncService.currentUserId;
        if (userId != null) {
          unawaited(_syncService.pushMemorial(userId, model));
        }

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
        final status = _syncService.isAuthenticated ? 'synced' : 'pending_update';
        final model = MemorialModel.fromEntity(memorial.copyWith(
          syncStatus: status,
          updatedAt: DateTime.now(),
        ));

        // 1. Always save to local SQLite first
        await _localDataSource.updateMemorial(model);

        // 2. If authenticated, attempt background cloud upload
        final userId = _syncService.currentUserId;
        if (userId != null) {
          unawaited(_syncService.pushMemorial(userId, model));
        }

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
        // 1. Record tombstone & delete locally
        await _localDataSource.deleteMemorial(id);

        // 2. If authenticated, delete from cloud
        final userId = _syncService.currentUserId;
        if (userId != null) {
          unawaited(_syncService.deleteMemorial(userId, id));
        }
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

        // If authenticated, push updated state to cloud
        final userId = _syncService.currentUserId;
        if (userId != null) {
          final updated = await _localDataSource.getMemorialById(id);
          if (updated != null) {
            unawaited(_syncService.pushMemorial(userId, updated));
          }
        }
      },
      operation: 'toggleFavorite',
      category: LogCategory.app,
    );
  }

  @override
  FutureEither<dynamic> syncMemorials({String? userId}) async {
    return _syncService.sync(userId: userId);
  }
}
