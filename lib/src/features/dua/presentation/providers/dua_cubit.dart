import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../services/storage_service.dart';
import '../../domain/entities/dua.dart';
import '../../domain/usecases/get_duas_usecase.dart';

class DuaState extends Equatable {
  final List<Dua> duas;
  final bool isLoading;
  final String? errorMessage;
  final String activeLanguage; // 'en' or 'bn'
  final String selectedCategory; // 'all' or category name
  final Map<String, int> recitationCounts;
  final double arabicFontSize;
  final double translationFontSize;

  const DuaState({
    this.duas = const [],
    this.isLoading = false,
    this.errorMessage,
    this.activeLanguage = 'en',
    this.selectedCategory = 'all',
    this.recitationCounts = const {},
    this.arabicFontSize = 19,
    this.translationFontSize = 13,
  });

  List<Dua> get filteredDuas {
    if (selectedCategory == 'all') return duas;
    return duas
        .where(
            (d) => d.category.toLowerCase() == selectedCategory.toLowerCase())
        .toList();
  }

  DuaState copyWith({
    List<Dua>? duas,
    bool? isLoading,
    String? errorMessage,
    String? activeLanguage,
    String? selectedCategory,
    Map<String, int>? recitationCounts,
    double? arabicFontSize,
    double? translationFontSize,
  }) {
    return DuaState(
      duas: duas ?? this.duas,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      activeLanguage: activeLanguage ?? this.activeLanguage,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      recitationCounts: recitationCounts ?? this.recitationCounts,
      arabicFontSize: arabicFontSize ?? this.arabicFontSize,
      translationFontSize: translationFontSize ?? this.translationFontSize,
    );
  }

  @override
  List<Object?> get props => [
        duas,
        isLoading,
        errorMessage,
        activeLanguage,
        selectedCategory,
        recitationCounts,
        arabicFontSize,
        translationFontSize,
      ];
}

class DuaCubit extends Cubit<DuaState> {
  static const double defaultArabicFontSize = 19;
  static const double defaultTranslationFontSize = 13;

  static const String _kArabicFontSizeKey = 'dua_arabic_font_size';
  static const String _kTranslationFontSizeKey = 'dua_translation_font_size';

  DuaCubit({required GetDuasUseCase getDuasUseCase})
      : _getDuasUseCase = getDuasUseCase,
        super(DuaState(
          arabicFontSize: StorageService.instance.getDouble(_kArabicFontSizeKey) ??
              defaultArabicFontSize,
          translationFontSize:
              StorageService.instance.getDouble(_kTranslationFontSizeKey) ??
                  defaultTranslationFontSize,
        ));

  final GetDuasUseCase _getDuasUseCase;

  Future<void> loadDuas({bool forceRefresh = false}) async {
    emit(state.copyWith(isLoading: true));
    final result = await _getDuasUseCase(forceRefresh);
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (duas) => emit(state.copyWith(
        isLoading: false,
        duas: duas,
      )),
    );
  }

  void switchLanguage(String languageCode) {
    emit(state.copyWith(activeLanguage: languageCode));
  }

  void selectCategory(String category) {
    emit(state.copyWith(selectedCategory: category));
  }

  void markRecited(String duaId) {
    final current = state.recitationCounts[duaId] ?? 0;
    emit(state.copyWith(
      recitationCounts: {
        ...state.recitationCounts,
        duaId: current + 1,
      },
    ));
  }

  void setArabicFontSize(double size) {
    emit(state.copyWith(arabicFontSize: size));
    StorageService.instance.setDouble(_kArabicFontSizeKey, size);
  }

  void setTranslationFontSize(double size) {
    emit(state.copyWith(translationFontSize: size));
    StorageService.instance.setDouble(_kTranslationFontSizeKey, size);
  }

  void resetFontSizes() {
    emit(state.copyWith(
      arabicFontSize: defaultArabicFontSize,
      translationFontSize: defaultTranslationFontSize,
    ));
    StorageService.instance.setDouble(_kArabicFontSizeKey, defaultArabicFontSize);
    StorageService.instance.setDouble(_kTranslationFontSizeKey, defaultTranslationFontSize);
  }
}
