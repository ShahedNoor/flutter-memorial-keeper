import 'package:firebase_auth/firebase_auth.dart';
import '../config/app_config.dart';
import '../features/memorials/data/datasources/memorial_remote_datasource.dart';
import '../features/memorials/data/datasources/memorial_remote_datasource_impl.dart';
import '../features/memorials/data/models/memorial_model.dart';
import '../utils/utils.dart';
import 'local_database_service.dart';

class SyncResult {
  final int pushedCount;
  final int pulledCount;
  final int deletedCount;
  final String message;

  const SyncResult({
    this.pushedCount = 0,
    this.pulledCount = 0,
    this.deletedCount = 0,
    this.message = 'Sync completed successfully',
  });

  bool get hasChanges =>
      pushedCount > 0 || pulledCount > 0 || deletedCount > 0;
}

class SyncService {
  SyncService._({
    LocalDatabaseService? dbService,
    MemorialRemoteDataSource? remoteDataSource,
    FirebaseAuth? auth,
  })  : _dbService = dbService ?? LocalDatabaseService.instance,
        _remoteDataSource =
            remoteDataSource ?? MemorialRemoteDataSourceImpl(),
        _auth = auth ?? AppConfig.firebaseAuth;

  static final SyncService instance = SyncService._();

  final LocalDatabaseService _dbService;
  final MemorialRemoteDataSource _remoteDataSource;
  final FirebaseAuth _auth;

  String? get currentUserId => _auth.currentUser?.uid;
  bool get isAuthenticated => currentUserId != null;

  /// Full bidirectional synchronization between SQLite and Firebase Firestore.
  /// Resolves conflicts via Last-Write-Wins (updatedAt timestamp).
  FutureEither<SyncResult> sync({String? userId}) {
    return runTask(
      () async {
        final targetUserId = userId ?? currentUserId;
        if (targetUserId == null || targetUserId.isEmpty) {
          AppLogger.info(
            'Sync skipped: User is unauthenticated (using local storage)',
            category: LogCategory.database,
          );
          return const SyncResult(
            message: 'Unauthenticated: Local storage active',
          );
        }

        AppLogger.info(
          'Starting synchronization for user $targetUserId',
          category: LogCategory.database,
        );

        int pushedCount = 0;
        int pulledCount = 0;
        int deletedCount = 0;

        // 1. Process deleted tombstones
        final deletedIds = await _dbService.getDeletedMemorialIds();
        if (deletedIds.isNotEmpty) {
          for (final id in deletedIds) {
            try {
              await _remoteDataSource.deleteMemorial(targetUserId, id);
              await _dbService.clearDeletedMemorial(id);
              deletedCount++;
            } catch (e) {
              AppLogger.warning(
                'Failed to delete remote memorial $id: $e',
                category: LogCategory.database,
              );
            }
          }
        }

        // 2. Fetch both local and remote collections
        final localRows = await _dbService.getAllMemorialsRaw();
        final localList = localRows.map((r) => MemorialModel.fromMap(r)).toList();
        final localMap = {for (final m in localList) m.id: m};

        final remoteList = await _remoteDataSource.fetchMemorials(targetUserId);
        final remoteMap = {for (final m in remoteList) m.id: m};

        // 3. Reconcile Local -> Remote
        for (final entry in localMap.entries) {
          final localId = entry.key;
          final localModel = entry.value;
          final remoteModel = remoteMap[localId];

          if (remoteModel == null) {
            // Local exists, remote does not -> Push to Firestore
            try {
              await _remoteDataSource.upsertMemorial(targetUserId, localModel);
              await _dbService.markMemorialSynced(localId);
              pushedCount++;
            } catch (e) {
              AppLogger.warning(
                'Failed to push local memorial $localId to cloud: $e',
                category: LogCategory.database,
              );
            }
          } else {
            // Exists in both: compare timestamps
            if (localModel.updatedAt.isAfter(remoteModel.updatedAt)) {
              // Local is newer -> Push to remote
              try {
                await _remoteDataSource.upsertMemorial(targetUserId, localModel);
                await _dbService.markMemorialSynced(localId);
                pushedCount++;
              } catch (e) {
                AppLogger.warning(
                  'Failed to push newer local memorial $localId to cloud: $e',
                  category: LogCategory.database,
                );
              }
            } else if (remoteModel.updatedAt.isAfter(localModel.updatedAt)) {
              // Remote is newer -> Pull into local SQLite
              await _dbService.upsertMemorial(remoteModel.toMap());
              pulledCount++;
            } else {
              // Timestamps identical, ensure marked synced
              if (localModel.syncStatus != 'synced') {
                await _dbService.markMemorialSynced(localId);
              }
            }
          }
        }

        // 4. Reconcile Remote -> Local
        for (final entry in remoteMap.entries) {
          final remoteId = entry.key;
          final remoteModel = entry.value;

          if (!localMap.containsKey(remoteId)) {
            // Remote has item that local lacks -> Insert into local SQLite
            await _dbService.upsertMemorial(remoteModel.toMap());
            pulledCount++;
          }
        }

        final result = SyncResult(
          pushedCount: pushedCount,
          pulledCount: pulledCount,
          deletedCount: deletedCount,
          message: 'Synced: $pushedCount uploaded, $pulledCount downloaded, $deletedCount removed',
        );

        AppLogger.success(
          'Synchronization finished: ${result.message}',
          category: LogCategory.database,
        );

        return result;
      },
      operation: 'syncService.sync',
      category: LogCategory.database,
    );
  }

  /// Push a single memorial to remote in the background.
  Future<void> pushMemorial(String userId, MemorialModel memorial) async {
    try {
      await _remoteDataSource.upsertMemorial(userId, memorial);
      await _dbService.markMemorialSynced(memorial.id);
    } catch (e) {
      AppLogger.warning(
        'Background push failed for memorial ${memorial.id}: $e (will sync later)',
        category: LogCategory.database,
      );
    }
  }

  /// Delete a single memorial from remote in the background.
  Future<void> deleteMemorial(String userId, String memorialId) async {
    try {
      await _remoteDataSource.deleteMemorial(userId, memorialId);
      await _dbService.clearDeletedMemorial(memorialId);
    } catch (e) {
      AppLogger.warning(
        'Background delete failed for memorial $memorialId: $e (tombstone retained)',
        category: LogCategory.database,
      );
    }
  }
}
