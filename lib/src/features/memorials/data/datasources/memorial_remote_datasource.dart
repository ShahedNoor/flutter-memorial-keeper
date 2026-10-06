import '../models/memorial_model.dart';

abstract class MemorialRemoteDataSource {
  Future<List<MemorialModel>> fetchMemorials(String userId);
  Future<void> upsertMemorial(String userId, MemorialModel memorial);
  Future<void> deleteMemorial(String userId, String memorialId);
  Future<void> batchUpsertMemorials(String userId, List<MemorialModel> memorials);
  Future<void> batchDeleteMemorials(String userId, List<String> memorialIds);
}
