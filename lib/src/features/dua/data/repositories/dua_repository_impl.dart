import 'package:memorialkeeper/src/utils/utils.dart';
import '../../domain/entities/dua.dart';
import '../../domain/repositories/dua_repository.dart';
import '../datasources/dua_local_datasource.dart';
import '../datasources/dua_remote_datasource.dart';

class DuaRepositoryImpl implements DuaRepository {
  final DuaLocalDataSource _localDataSource;
  final DuaRemoteDataSource _remoteDataSource;

  DuaRepositoryImpl({
    DuaLocalDataSource? localDataSource,
    DuaRemoteDataSource? remoteDataSource,
  })  : _localDataSource = localDataSource ?? DuaLocalDataSourceImpl(),
        _remoteDataSource = remoteDataSource ?? DuaRemoteDataSourceImpl();

  @override
  FutureEither<List<Dua>> getDuas({bool forceRefresh = false}) async {
    return runTask(
      () async {
        // 1. Fetch from Firestore
        final remoteDuas = await _remoteDataSource.fetchDuasFromFirestore();
        if (remoteDuas.isNotEmpty) {
          // Cache successful Firestore sync
          await _localDataSource.cacheDuas(remoteDuas);
          return remoteDuas.map((d) => d.toEntity()).toList();
        }

        // 2. If Firestore is empty/unavailable, return cached or fallback Duas
        final cached = await _localDataSource.getCachedDuas();
        if (cached.isNotEmpty) {
          return cached.map((d) => d.toEntity()).toList();
        }

        // 3. Fallback built-in Duas
        return _localDataSource
            .getFallbackDuas()
            .map((d) => d.toEntity())
            .toList();
      },
      operation: 'getDuas',
      category: LogCategory.app,
    );
  }
}
