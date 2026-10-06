import 'package:flutter_test/flutter_test.dart';
import 'package:memorialkeeper/src/features/memorials/data/models/memorial_model.dart';

void main() {
  group('MemorialModel Sync Serialization', () {
    test('Correctly deserializes from SQLite map format (encoded JSON string & int isFavorite)', () {
      final sqliteMap = {
        'id': 'mem-1',
        'fullName': 'Haji Abdul Gafur',
        'category': 'family',
        'relationship': 'grandfather_paternal',
        'isFavorite': 1,
        'syncStatus': 'pending_create',
        'memoryPhotoPaths': '["https://example.com/photo1.jpg", "https://example.com/photo2.jpg"]',
        'createdAt': '2026-01-01T00:00:00.000',
        'updatedAt': '2026-01-02T00:00:00.000',
      };

      final model = MemorialModel.fromMap(sqliteMap);

      expect(model.id, equals('mem-1'));
      expect(model.fullName, equals('Haji Abdul Gafur'));
      expect(model.isFavorite, isTrue);
      expect(model.memoryPhotoPaths.length, equals(2));
      expect(model.memoryPhotoPaths.first, equals('https://example.com/photo1.jpg'));
    });

    test('Correctly deserializes from Firestore map format (native List & bool isFavorite)', () {
      final firestoreMap = {
        'id': 'mem-2',
        'fullName': 'Fatema Zohra Begum',
        'category': 'family',
        'relationship': 'mother',
        'isFavorite': false,
        'syncStatus': 'synced',
        'memoryPhotoPaths': ['https://example.com/photo3.jpg'],
        'createdAt': '2026-02-01T00:00:00.000',
        'updatedAt': '2026-02-02T00:00:00.000',
      };

      final model = MemorialModel.fromMap(firestoreMap);

      expect(model.id, equals('mem-2'));
      expect(model.fullName, equals('Fatema Zohra Begum'));
      expect(model.isFavorite, isFalse);
      expect(model.memoryPhotoPaths.length, equals(1));
    });

    test('toFirestoreMap outputs native List and boolean types', () {
      final model = MemorialModel(
        id: 'mem-3',
        fullName: 'Test User',
        category: 'family',
        relationship: 'father',
        isFavorite: true,
        memoryPhotoPaths: const ['https://example.com/img.jpg'],
        createdAt: DateTime.parse('2026-03-01T00:00:00.000'),
        updatedAt: DateTime.parse('2026-03-02T00:00:00.000'),
      );

      final firestoreMap = model.toFirestoreMap();

      expect(firestoreMap['isFavorite'], isA<bool>());
      expect(firestoreMap['isFavorite'], isTrue);
      expect(firestoreMap['memoryPhotoPaths'], isA<List<String>>());
      expect(firestoreMap['syncStatus'], equals('synced'));
    });
  });
}
