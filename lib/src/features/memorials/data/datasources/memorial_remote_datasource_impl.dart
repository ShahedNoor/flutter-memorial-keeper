import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../config/app_config.dart';
import '../models/memorial_model.dart';
import 'memorial_remote_datasource.dart';

class MemorialRemoteDataSourceImpl implements MemorialRemoteDataSource {
  final FirebaseFirestore _firestore;

  MemorialRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? AppConfig.firestore;

  CollectionReference<Map<String, dynamic>> _userMemorialsRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('memorials');
  }

  @override
  Future<List<MemorialModel>> fetchMemorials(String userId) async {
    final snapshot = await _userMemorialsRef(userId).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      // Ensure the id matches document id
      data['id'] = doc.id;
      return MemorialModel.fromMap(data);
    }).toList();
  }

  @override
  Future<void> upsertMemorial(String userId, MemorialModel memorial) async {
    await _userMemorialsRef(userId).doc(memorial.id).set(
          memorial.toFirestoreMap(),
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> deleteMemorial(String userId, String memorialId) async {
    await _userMemorialsRef(userId).doc(memorialId).delete();
  }

  @override
  Future<void> batchUpsertMemorials(
    String userId,
    List<MemorialModel> memorials,
  ) async {
    if (memorials.isEmpty) return;

    // Firestore batch limit is 500 operations
    const int batchSize = 400;
    for (int i = 0; i < memorials.length; i += batchSize) {
      final end = (i + batchSize < memorials.length) ? i + batchSize : memorials.length;
      final chunk = memorials.sublist(i, end);
      final batch = _firestore.batch();

      for (final memorial in chunk) {
        final docRef = _userMemorialsRef(userId).doc(memorial.id);
        batch.set(docRef, memorial.toFirestoreMap(), SetOptions(merge: true));
      }

      await batch.commit();
    }
  }

  @override
  Future<void> batchDeleteMemorials(
    String userId,
    List<String> memorialIds,
  ) async {
    if (memorialIds.isEmpty) return;

    const int batchSize = 400;
    for (int i = 0; i < memorialIds.length; i += batchSize) {
      final end = (i + batchSize < memorialIds.length) ? i + batchSize : memorialIds.length;
      final chunk = memorialIds.sublist(i, end);
      final batch = _firestore.batch();

      for (final id in chunk) {
        final docRef = _userMemorialsRef(userId).doc(id);
        batch.delete(docRef);
      }

      await batch.commit();
    }
  }
}
