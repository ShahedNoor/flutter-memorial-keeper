import 'package:memorialkeeper/src/utils/utils.dart';
import '../entities/dua.dart';

abstract class DuaRepository {
  /// Retrieves Islamic Duas from local cache/fallback and syncs with Firebase Firestore.
  FutureEither<List<Dua>> getDuas({bool forceRefresh = false});
}
