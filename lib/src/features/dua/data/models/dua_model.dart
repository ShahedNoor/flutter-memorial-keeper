import '../../domain/entities/dua.dart';

class DuaModel extends Dua {
  const DuaModel({
    required super.id,
    required super.titleEn,
    required super.titleBn,
    required super.category,
    required super.arabic,
    required super.transliteration,
    required super.translationEn,
    required super.translationBn,
    required super.reference,
    super.order = 0,
  });

  factory DuaModel.fromJson(Map<String, dynamic> json, [String? idOverride]) {
    final id = idOverride ?? (json['id']?.toString() ?? '');

    final titleEn = json['titleEn']?.toString() ??
        json['title_en']?.toString() ??
        json['title']?.toString() ??
        '';

    final titleBn = json['titleBn']?.toString() ??
        json['title_bn']?.toString() ??
        '';

    final category = json['category']?.toString() ?? 'General';
    final arabic = json['arabic']?.toString() ??
        json['arabic_text']?.toString() ??
        '';
    final transliteration = json['transliteration']?.toString() ?? '';

    final translationEn = json['translationEn']?.toString() ??
        json['translation_en']?.toString() ??
        json['english']?.toString() ??
        json['translation']?.toString() ??
        '';

    final translationBn = json['translationBn']?.toString() ??
        json['translation_bn']?.toString() ??
        json['bangla']?.toString() ??
        '';

    final reference = json['reference']?.toString() ?? '';
    final order = (json['order'] is num)
        ? (json['order'] as num).toInt()
        : (int.tryParse(json['order']?.toString() ?? '') ?? 0);

    return DuaModel(
      id: id,
      titleEn: titleEn,
      titleBn: titleBn,
      category: category,
      arabic: arabic,
      transliteration: transliteration,
      translationEn: translationEn,
      translationBn: translationBn,
      reference: reference,
      order: order,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titleEn': titleEn,
      'titleBn': titleBn,
      'category': category,
      'arabic': arabic,
      'transliteration': transliteration,
      'translationEn': translationEn,
      'translationBn': translationBn,
      'reference': reference,
      'order': order,
    };
  }

  factory DuaModel.fromEntity(Dua entity) {
    return DuaModel(
      id: entity.id,
      titleEn: entity.titleEn,
      titleBn: entity.titleBn,
      category: entity.category,
      arabic: entity.arabic,
      transliteration: entity.transliteration,
      translationEn: entity.translationEn,
      translationBn: entity.translationBn,
      reference: entity.reference,
      order: entity.order,
    );
  }

  Dua toEntity() => this;
}
