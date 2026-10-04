import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class LocalDatabaseService {
  LocalDatabaseService._();
  static final LocalDatabaseService instance = LocalDatabaseService._();

  static const String _dbName = 'memorialkeeper.db';
  static const int _dbVersion = 2;
  static const String tableMemorials = 'memorials';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docsDir.path, _dbName);

    return await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE $tableMemorials ADD COLUMN mapStyle TEXT NOT NULL DEFAULT \'streets\'',
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableMemorials (
        id TEXT PRIMARY KEY,
        fullName TEXT NOT NULL,
        arabicName TEXT,
        gender TEXT NOT NULL DEFAULT 'male',
        category TEXT NOT NULL,
        relationship TEXT NOT NULL,
        customRelation TEXT,
        dateOfBirth TEXT,
        birthYear INTEGER,
        dateOfDeath TEXT,
        passingYear INTEGER,
        age INTEGER,
        cemeteryName TEXT,
        cemeteryArea TEXT,
        gravePlot TEXT,
        latitude REAL,
        longitude REAL,
        mapStyle TEXT NOT NULL DEFAULT 'streets',
        profilePhotoPath TEXT,
        gravePhotoPath TEXT,
        memoryPhotoPaths TEXT,
        notesOrDua TEXT,
        isFavorite INTEGER NOT NULL DEFAULT 0,
        syncStatus TEXT NOT NULL DEFAULT 'synced',
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Pre-populate with initial seed memorials so the app is instantly rich with data
    await _seedInitialMemorials(db);
  }

  Future<void> _seedInitialMemorials(Database db) async {
    final now = DateTime.now().toIso8601String();
    const uuid = Uuid();

    final seeds = [
      {
        'id': uuid.v4(),
        'fullName': 'Haji Abdul Gafur',
        'arabicName': 'الحاج عبد الغفور',
        'gender': 'male',
        'category': 'family',
        'relationship': 'grandfather_paternal',
        'customRelation': 'Paternal Grandfather',
        'dateOfBirth': '1935-03-12T00:00:00.000',
        'birthYear': 1935,
        'dateOfDeath': '2016-11-20T00:00:00.000',
        'passingYear': 2016,
        'age': 81,
        'cemeteryName': 'Azimpur Graveyard',
        'cemeteryArea': 'Lalbagh, Dhaka',
        'gravePlot': 'Plot 14',
        'profilePhotoPath': null,
        'gravePhotoPath': null,
        'memoryPhotoPaths': jsonEncode([]),
        'notesOrDua': 'A deeply pious elder who built the village madrasa. May Allah grant him Jannatul Firdaus.',
        'isFavorite': 1,
        'syncStatus': 'synced',
        'createdAt': now,
        'updatedAt': now,
      },
      {
        'id': uuid.v4(),
        'fullName': 'Begum Rokeya Khatun',
        'arabicName': 'رقية خاتون',
        'gender': 'female',
        'category': 'family',
        'relationship': 'grandmother_paternal',
        'customRelation': 'Paternal Grandmother',
        'dateOfBirth': '1942-07-05T00:00:00.000',
        'birthYear': 1942,
        'dateOfDeath': '2020-04-18T00:00:00.000',
        'passingYear': 2020,
        'age': 78,
        'cemeteryName': 'Azimpur Graveyard',
        'cemeteryArea': 'Lalbagh, Dhaka',
        'gravePlot': 'Plot 15',
        'profilePhotoPath': null,
        'gravePhotoPath': null,
        'memoryPhotoPaths': jsonEncode([]),
        'notesOrDua': 'Gentle soul who always recited the Quran at dawn. Remember her in your daily prayers.',
        'isFavorite': 1,
        'syncStatus': 'synced',
        'createdAt': now,
        'updatedAt': now,
      },
      {
        'id': uuid.v4(),
        'fullName': 'Muhammad Shamsul Huda',
        'arabicName': 'محمد شمس الهدى',
        'gender': 'male',
        'category': 'family',
        'relationship': 'father',
        'customRelation': 'Father',
        'dateOfBirth': '1961-01-15T00:00:00.000',
        'birthYear': 1961,
        'dateOfDeath': '2023-08-10T00:00:00.000',
        'passingYear': 2023,
        'age': 62,
        'cemeteryName': 'Banani Cemetery',
        'cemeteryArea': 'Block B, Road 11, Dhaka',
        'gravePlot': 'Section B, Grave 42',
        'profilePhotoPath': null,
        'gravePhotoPath': null,
        'memoryPhotoPaths': jsonEncode([]),
        'notesOrDua': 'Loving father and guide. Always emphasized honesty, compassion, and prayer.',
        'isFavorite': 1,
        'syncStatus': 'synced',
        'createdAt': now,
        'updatedAt': now,
      },
      {
        'id': uuid.v4(),
        'fullName': 'Fatema Zohra Begum',
        'arabicName': 'فاطمة الزهراء',
        'gender': 'female',
        'category': 'family',
        'relationship': 'mother',
        'customRelation': 'Mother',
        'dateOfBirth': '1965-09-22T00:00:00.000',
        'birthYear': 1965,
        'dateOfDeath': '2024-02-14T00:00:00.000',
        'passingYear': 2024,
        'age': 58,
        'cemeteryName': 'Rayer Bazar Graveyard',
        'cemeteryArea': 'Mohammadpur, Dhaka',
        'gravePlot': 'Block C, Row 8',
        'profilePhotoPath': null,
        'gravePhotoPath': null,
        'memoryPhotoPaths': jsonEncode([]),
        'notesOrDua': 'A mother whose warmth was a sanctuary for our family. O Allah, make her grave a garden of paradise.',
        'isFavorite': 1,
        'syncStatus': 'synced',
        'createdAt': now,
        'updatedAt': now,
      },
      {
        'id': uuid.v4(),
        'fullName': 'Prof. Dr. Jamaluddin Ahmed',
        'arabicName': 'د. جمال الدين أحمد',
        'gender': 'male',
        'category': 'others',
        'relationship': 'teachers',
        'customRelation': 'University Mentor',
        'dateOfBirth': '1948-02-10T00:00:00.000',
        'birthYear': 1948,
        'dateOfDeath': '2022-06-30T00:00:00.000',
        'passingYear': 2022,
        'age': 74,
        'cemeteryName': 'Mirpur Martyred Intellectuals Graveyard',
        'cemeteryArea': 'Mirpur, Dhaka',
        'gravePlot': 'Section 3',
        'profilePhotoPath': null,
        'gravePhotoPath': null,
        'memoryPhotoPaths': jsonEncode([]),
        'notesOrDua': 'Inspiring academic and humanitarian. Left an indelible mark on generations of students.',
        'isFavorite': 0,
        'syncStatus': 'synced',
        'createdAt': now,
        'updatedAt': now,
      },
      {
        'id': uuid.v4(),
        'fullName': 'Shafiqur Rahman',
        'arabicName': 'شفيق الرحمن',
        'gender': 'male',
        'category': 'others',
        'relationship': 'friends',
        'customRelation': 'Childhood Best Friend',
        'dateOfBirth': '1970-05-18T00:00:00.000',
        'birthYear': 1970,
        'dateOfDeath': '2021-12-05T00:00:00.000',
        'passingYear': 2021,
        'age': 51,
        'cemeteryName': 'Rayer Bazar Graveyard',
        'cemeteryArea': 'Mohammadpur, Dhaka',
        'gravePlot': 'Block E, Row 12',
        'profilePhotoPath': null,
        'gravePhotoPath': null,
        'memoryPhotoPaths': jsonEncode([]),
        'notesOrDua': 'True friend who stood by through thick and thin. May Allah reunite us in Jannah.',
        'isFavorite': 0,
        'syncStatus': 'synced',
        'createdAt': now,
        'updatedAt': now,
      },
      {
        'id': uuid.v4(),
        'fullName': 'Maulana Abdul Hai',
        'arabicName': 'مولانا عبد الحي',
        'gender': 'male',
        'category': 'others',
        'relationship': 'elders',
        'customRelation': 'Neighborhood Mosque Imam',
        'dateOfBirth': '1938-10-12T00:00:00.000',
        'birthYear': 1938,
        'dateOfDeath': '2018-03-24T00:00:00.000',
        'passingYear': 2018,
        'age': 80,
        'cemeteryName': 'Uttara Sector 4 Cemetery',
        'cemeteryArea': 'Sector 4, Uttara, Dhaka',
        'gravePlot': 'Plot 28',
        'profilePhotoPath': null,
        'gravePhotoPath': null,
        'memoryPhotoPaths': jsonEncode([]),
        'notesOrDua': 'Led prayers for over 40 years. Known for his soft-spoken wisdom and generosity.',
        'isFavorite': 0,
        'syncStatus': 'synced',
        'createdAt': now,
        'updatedAt': now,
      },
    ];

    for (final seed in seeds) {
      await db.insert(tableMemorials, seed);
    }
  }

  // --- CRUD Operations ---

  Future<int> insertMemorial(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(tableMemorials, data);
  }

  Future<int> updateMemorial(String id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update(
      tableMemorials,
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteMemorial(String id) async {
    final db = await database;
    return await db.delete(
      tableMemorials,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getMemorials({
    String? category,
    String? searchQuery,
  }) async {
    final db = await database;
    String? whereClause;
    List<dynamic>? whereArgs;

    final conditions = <String>[];
    final args = <dynamic>[];

    if (category != null && category.isNotEmpty && category != 'all') {
      conditions.add('category = ?');
      args.add(category);
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = '%${searchQuery.trim()}%';
      conditions.add(
        '(fullName LIKE ? OR customRelation LIKE ? OR cemeteryName LIKE ? OR relationship LIKE ?)',
      );
      args.addAll([query, query, query, query]);
    }

    if (conditions.isNotEmpty) {
      whereClause = conditions.join(' AND ');
      whereArgs = args;
    }

    return await db.query(
      tableMemorials,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'isFavorite DESC, createdAt DESC',
    );
  }

  Future<Map<String, dynamic>?> getMemorialById(String id) async {
    final db = await database;
    final results = await db.query(
      tableMemorials,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> toggleFavorite(String id) async {
    final db = await database;
    final current = await getMemorialById(id);
    if (current == null) return 0;

    final currentFav = (current['isFavorite'] as int?) ?? 0;
    final newFav = currentFav == 1 ? 0 : 1;

    return await db.update(
      tableMemorials,
      {
        'isFavorite': newFav,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
