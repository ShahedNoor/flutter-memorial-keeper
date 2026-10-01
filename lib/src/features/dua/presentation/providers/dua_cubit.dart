import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/dua.dart';
import '../../domain/usecases/get_duas_usecase.dart';

class DuaState extends Equatable {
  final List<Dua> duas;
  final bool isLoading;
  final String? errorMessage;
  final String activeLanguage; // 'en' or 'bn'
  final String selectedCategory; // 'all' or category name

  final Map<String, int> recitationCounts;

  const DuaState({
    this.duas = const [],
    this.isLoading = false,
    this.errorMessage,
    this.activeLanguage = 'en',
    this.selectedCategory = 'all',
    this.recitationCounts = const {},
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
  }) {
    return DuaState(
      duas: duas ?? this.duas,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      activeLanguage: activeLanguage ?? this.activeLanguage,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      recitationCounts: recitationCounts ?? this.recitationCounts,
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
      ];
}

class DuaCubit extends Cubit<DuaState> {
  DuaCubit({required GetDuasUseCase getDuasUseCase})
      : _getDuasUseCase = getDuasUseCase,
        super(const DuaState());

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
}
