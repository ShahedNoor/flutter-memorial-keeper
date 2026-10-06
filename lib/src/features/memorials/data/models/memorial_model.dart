import 'dart:convert';
import '../../domain/entities/memorial.dart';

class MemorialModel extends Memorial {
  const MemorialModel({
    required super.id,
    required super.fullName,
    super.arabicName,
    super.gender,
    required super.category,
    required super.relationship,
    super.customRelation,
    super.dateOfBirth,
    super.birthYear,
    super.dateOfDeath,
    super.passingYear,
    super.age,
    super.cemeteryName,
    super.cemeteryArea,
    super.gravePlot,
    super.latitude,
    super.longitude,
    super.mapStyle = 'streets',
    super.profilePhotoPath,
    super.gravePhotoPath,
    super.memoryPhotoPaths,
    super.notesOrDua,
    super.isFavorite,
    super.syncStatus,
    required super.createdAt,
    required super.updatedAt,
  });

  factory MemorialModel.fromEntity(Memorial memorial) {
    return MemorialModel(
      id: memorial.id,
      fullName: memorial.fullName,
      arabicName: memorial.arabicName,
      gender: memorial.gender,
      category: memorial.category,
      relationship: memorial.relationship,
      customRelation: memorial.customRelation,
      dateOfBirth: memorial.dateOfBirth,
      birthYear: memorial.birthYear,
      dateOfDeath: memorial.dateOfDeath,
      passingYear: memorial.passingYear,
      age: memorial.age,
      cemeteryName: memorial.cemeteryName,
      cemeteryArea: memorial.cemeteryArea,
      gravePlot: memorial.gravePlot,
      latitude: memorial.latitude,
      longitude: memorial.longitude,
      mapStyle: memorial.mapStyle,
      profilePhotoPath: memorial.profilePhotoPath,
      gravePhotoPath: memorial.gravePhotoPath,
      memoryPhotoPaths: memorial.memoryPhotoPaths,
      notesOrDua: memorial.notesOrDua,
      isFavorite: memorial.isFavorite,
      syncStatus: memorial.syncStatus,
      createdAt: memorial.createdAt,
      updatedAt: memorial.updatedAt,
    );
  }

  factory MemorialModel.fromMap(Map<String, dynamic> map) {
    List<String> parsedMemoryPhotos = [];
    if (map['memoryPhotoPaths'] != null) {
      final rawPhotos = map['memoryPhotoPaths'];
      if (rawPhotos is List) {
        parsedMemoryPhotos = rawPhotos.map((e) => e.toString()).toList();
      } else if (rawPhotos is String && rawPhotos.isNotEmpty) {
        try {
          final decoded = jsonDecode(rawPhotos);
          if (decoded is List) {
            parsedMemoryPhotos = decoded.map((e) => e.toString()).toList();
          }
        } catch (_) {}
      }
    }

    final favRaw = map['isFavorite'];
    final bool isFav = favRaw is bool
        ? favRaw
        : (favRaw is num ? favRaw == 1 : false);

    return MemorialModel(
      id: map['id']?.toString() ?? '',
      fullName: map['fullName']?.toString() ?? '',
      arabicName: map['arabicName']?.toString(),
      gender: map['gender']?.toString() ?? 'male',
      category: map['category']?.toString() ?? 'family',
      relationship: map['relationship']?.toString() ?? 'other',
      customRelation: map['customRelation']?.toString(),
      dateOfBirth: map['dateOfBirth'] != null
          ? DateTime.tryParse(map['dateOfBirth'].toString())
          : null,
      birthYear: map['birthYear'] as int?,
      dateOfDeath: map['dateOfDeath'] != null
          ? DateTime.tryParse(map['dateOfDeath'].toString())
          : null,
      passingYear: map['passingYear'] as int?,
      age: map['age'] as int?,
      cemeteryName: map['cemeteryName']?.toString(),
      cemeteryArea: map['cemeteryArea']?.toString(),
      gravePlot: map['gravePlot']?.toString(),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      mapStyle: map['mapStyle']?.toString() ?? 'streets',
      profilePhotoPath: map['profilePhotoPath']?.toString(),
      gravePhotoPath: map['gravePhotoPath']?.toString(),
      memoryPhotoPaths: parsedMemoryPhotos,
      notesOrDua: map['notesOrDua']?.toString(),
      isFavorite: isFav,
      syncStatus: map['syncStatus']?.toString() ?? 'synced',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'arabicName': arabicName,
      'gender': gender,
      'category': category,
      'relationship': relationship,
      'customRelation': customRelation,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'birthYear': birthYear,
      'dateOfDeath': dateOfDeath?.toIso8601String(),
      'passingYear': passingYear,
      'age': age,
      'cemeteryName': cemeteryName,
      'cemeteryArea': cemeteryArea,
      'gravePlot': gravePlot,
      'latitude': latitude,
      'longitude': longitude,
      'mapStyle': mapStyle,
      'profilePhotoPath': profilePhotoPath,
      'gravePhotoPath': gravePhotoPath,
      'memoryPhotoPaths': jsonEncode(memoryPhotoPaths),
      'notesOrDua': notesOrDua,
      'isFavorite': isFavorite ? 1 : 0,
      'syncStatus': syncStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'id': id,
      'fullName': fullName,
      'arabicName': arabicName,
      'gender': gender,
      'category': category,
      'relationship': relationship,
      'customRelation': customRelation,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'birthYear': birthYear,
      'dateOfDeath': dateOfDeath?.toIso8601String(),
      'passingYear': passingYear,
      'age': age,
      'cemeteryName': cemeteryName,
      'cemeteryArea': cemeteryArea,
      'gravePlot': gravePlot,
      'latitude': latitude,
      'longitude': longitude,
      'mapStyle': mapStyle,
      'profilePhotoPath': profilePhotoPath,
      'gravePhotoPath': gravePhotoPath,
      'memoryPhotoPaths': memoryPhotoPaths,
      'notesOrDua': notesOrDua,
      'isFavorite': isFavorite,
      'syncStatus': 'synced',
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Memorial toEntity() => this;
}
