import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memorial_keeper/src/config/app_config.dart';
import '../models/dua_model.dart';

abstract class DuaRemoteDataSource {
  Future<List<DuaModel>> fetchDuasFromFirestore();
}

class DuaRemoteDataSourceImpl implements DuaRemoteDataSource {
  @override
  Future<List<DuaModel>> fetchDuasFromFirestore() async {
    try {
      final snapshot = await AppConfig.firestore
          .collection('duas')
          .get(const GetOptions(source: Source.serverAndCache));

      if (snapshot.docs.isEmpty) {
        return [];
      }

      final list = snapshot.docs.map((doc) {
        return DuaModel.fromJson(doc.data(), doc.id);
      }).toList();

      list.sort((a, b) => a.order.compareTo(b.order));
      return list;
    } catch (_) {
      // Return empty list on connection/permission failure so fallback takes over seamlessly
      return [];
    }
  }
}
