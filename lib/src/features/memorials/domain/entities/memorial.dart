import 'package:equatable/equatable.dart';

/// Pure domain entity representing a departed loved one.
class Memorial extends Equatable {
  const Memorial({
    required this.id,
    required this.fullName,
    this.arabicName,
    this.gender = 'male',
    required this.category,
    required this.relationship,
    this.customRelation,
    this.dateOfBirth,
    this.birthYear,
    this.dateOfDeath,
    this.passingYear,
    this.age,
    this.cemeteryName,
    this.cemeteryArea,
    this.gravePlot,
    this.latitude,
    this.longitude,
    this.profilePhotoPath,
    this.gravePhotoPath,
    this.memoryPhotoPaths = const [],
    this.notesOrDua,
    this.isFavorite = false,
    this.syncStatus = 'synced',
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String fullName;
  final String? arabicName;
  final String gender; // 'male' | 'female'
  final String category; // 'family' | 'others'
  final String relationship; // e.g. 'father', 'mother', 'friends', 'teachers', etc.
  final String? customRelation; // e.g. 'Paternal Grandfather (দাদা)'

  final DateTime? dateOfBirth;
  final int? birthYear;
  final DateTime? dateOfDeath;
  final int? passingYear;
  final int? age;

  final String? cemeteryName;
  final String? cemeteryArea;
  final String? gravePlot;
  final double? latitude;
  final double? longitude;

  final String? profilePhotoPath;
  final String? gravePhotoPath;
  final List<String> memoryPhotoPaths;

  final String? notesOrDua;
  final bool isFavorite;
  final String syncStatus; // 'synced' | 'pending_create' | 'pending_update' | 'pending_delete'
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Helper to display relationship formatted
  String get displayRelationship {
    if (customRelation != null && customRelation!.trim().isNotEmpty) {
      return customRelation!;
    }
    return switch (relationship.toLowerCase()) {
      'father' => 'Father',
      'mother' => 'Mother',
      'grandfather_paternal' => 'Grandfather (Paternal)',
      'grandmother_paternal' => 'Grandmother (Paternal)',
      'grandfather_maternal' => 'Grandfather (Maternal)',
      'grandmother_maternal' => 'Grandmother (Maternal)',
      'brother' => 'Brother',
      'sister' => 'Sister',
      'spouse' => gender == 'female' ? 'Wife' : 'Husband',
      'son' => 'Son',
      'daughter' => 'Daughter',
      'uncle' => 'Uncle',
      'aunt' => 'Aunt',
      'friends' => 'Friend',
      'teachers' => 'Mentor / Teacher',
      'elders' => 'Elder / Imam',
      'neighbors' => 'Neighbor',
      'colleagues' => 'Colleague',
      _ => relationship,
    };
  }

  /// Helper to display lifespan years (e.g., '1935 – 2016' or 'Passed away in 2020')
  String get lifespanDisplay {
    final bYear = birthYear ?? (dateOfBirth?.year);
    final pYear = passingYear ?? (dateOfDeath?.year);

    if (bYear != null && pYear != null) {
      final ageStr = age != null ? ' ($age yrs)' : '';
      return '$bYear – $pYear$ageStr';
    } else if (pYear != null) {
      final ageStr = age != null ? ' ($age yrs)' : '';
      return 'Died in $pYear$ageStr';
    } else if (age != null) {
      return 'Age $age yrs';
    }
    return '';
  }

  /// Helper to display resting place summary
  String get restingPlaceDisplay {
    final parts = <String>[];
    if (cemeteryName != null && cemeteryName!.isNotEmpty) {
      parts.add(cemeteryName!);
    }
    if (gravePlot != null && gravePlot!.isNotEmpty) {
      parts.add(gravePlot!);
    }
    if (cemeteryArea != null && cemeteryArea!.isNotEmpty) {
      parts.add(cemeteryArea!);
    }
    return parts.join(', ');
  }

  Memorial copyWith({
    String? id,
    String? fullName,
    String? arabicName,
    String? gender,
    String? category,
    String? relationship,
    String? customRelation,
    DateTime? dateOfBirth,
    int? birthYear,
    DateTime? dateOfDeath,
    int? passingYear,
    int? age,
    String? cemeteryName,
    String? cemeteryArea,
    String? gravePlot,
    double? latitude,
    double? longitude,
    String? profilePhotoPath,
    String? gravePhotoPath,
    List<String>? memoryPhotoPaths,
    String? notesOrDua,
    bool? isFavorite,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Memorial(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      arabicName: arabicName ?? this.arabicName,
      gender: gender ?? this.gender,
      category: category ?? this.category,
      relationship: relationship ?? this.relationship,
      customRelation: customRelation ?? this.customRelation,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      birthYear: birthYear ?? this.birthYear,
      dateOfDeath: dateOfDeath ?? this.dateOfDeath,
      passingYear: passingYear ?? this.passingYear,
      age: age ?? this.age,
      cemeteryName: cemeteryName ?? this.cemeteryName,
      cemeteryArea: cemeteryArea ?? this.cemeteryArea,
      gravePlot: gravePlot ?? this.gravePlot,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      gravePhotoPath: gravePhotoPath ?? this.gravePhotoPath,
      memoryPhotoPaths: memoryPhotoPaths ?? this.memoryPhotoPaths,
      notesOrDua: notesOrDua ?? this.notesOrDua,
      isFavorite: isFavorite ?? this.isFavorite,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        arabicName,
        gender,
        category,
        relationship,
        customRelation,
        dateOfBirth,
        birthYear,
        dateOfDeath,
        passingYear,
        age,
        cemeteryName,
        cemeteryArea,
        gravePlot,
        latitude,
        longitude,
        profilePhotoPath,
        gravePhotoPath,
        memoryPhotoPaths,
        notesOrDua,
        isFavorite,
        syncStatus,
        createdAt,
        updatedAt,
      ];
}
