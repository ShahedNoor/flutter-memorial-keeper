import 'package:equatable/equatable.dart';

/// Authentic Islamic Dua entity supporting multi-language titles and translations.
class Dua extends Equatable {
  final String id;
  final String titleEn;
  final String titleBn;
  final String category;
  final String arabic;
  final String transliteration;
  final String translationEn;
  final String translationBn;
  final String reference;
  final int order;

  const Dua({
    required this.id,
    required this.titleEn,
    required this.titleBn,
    required this.category,
    required this.arabic,
    required this.transliteration,
    required this.translationEn,
    required this.translationBn,
    required this.reference,
    this.order = 0,
  });

  /// Returns title based on current language preference ('bn' vs 'en').
  String displayTitle(String languageCode) {
    if (languageCode == 'bn' && titleBn.trim().isNotEmpty) {
      return titleBn;
    }
    return titleEn.isNotEmpty ? titleEn : titleBn;
  }

  /// Returns translation based on current language preference ('bn' vs 'en').
  String displayTranslation(String languageCode) {
    if (languageCode == 'bn' && translationBn.trim().isNotEmpty) {
      return translationBn;
    }
    return translationEn.isNotEmpty ? translationEn : translationBn;
  }

  @override
  List<Object?> get props => [
        id,
        titleEn,
        titleBn,
        category,
        arabic,
        transliteration,
        translationEn,
        translationBn,
        reference,
        order,
      ];
}
