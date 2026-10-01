import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/memorial.dart';
import '../../domain/usecases/get_memorials_usecase.dart';
import '../../domain/usecases/add_memorial_usecase.dart';
import '../../domain/usecases/update_memorial_usecase.dart';
import '../../domain/usecases/delete_memorial_usecase.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';

// --- Events ---

sealed class MemorialEvent extends Equatable {
  const MemorialEvent();

  @override
  List<Object?> get props => [];
}

class LoadMemorials extends MemorialEvent {
  const LoadMemorials();
}

class AddMemorialEvent extends MemorialEvent {
  const AddMemorialEvent(this.memorial);
  final Memorial memorial;

  @override
  List<Object?> get props => [memorial];
}

class UpdateMemorialEvent extends MemorialEvent {
  const UpdateMemorialEvent(this.memorial);
  final Memorial memorial;

  @override
  List<Object?> get props => [memorial];
}

class DeleteMemorialEvent extends MemorialEvent {
  const DeleteMemorialEvent(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}

class ToggleFavoriteEvent extends MemorialEvent {
  const ToggleFavoriteEvent(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}

class CategoryFilterChanged extends MemorialEvent {
  const CategoryFilterChanged(this.category);
  final String category;

  @override
  List<Object?> get props => [category];
}

class SearchQueryChanged extends MemorialEvent {
  const SearchQueryChanged(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

// --- States ---

class MemorialState extends Equatable {
  const MemorialState({
    this.memorials = const [],
    this.selectedCategory = 'all',
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
    this.actionSuccessMessage,
  });

  final List<Memorial> memorials;
  final String selectedCategory;
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;
  final String? actionSuccessMessage;

  List<Memorial> get familyMemorials =>
      memorials.where((m) => m.category == 'family').toList();

  List<Memorial> get othersMemorials =>
      memorials.where((m) => m.category == 'others').toList();

  List<Memorial> get favoriteMemorials =>
      memorials.where((m) => m.isFavorite).toList();

  List<Memorial> get filteredMemorials {
    return memorials.where((m) {
      final matchesCategory = selectedCategory == 'all' ||
          m.category == selectedCategory ||
          m.relationship == selectedCategory;

      final query = searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          m.fullName.toLowerCase().contains(query) ||
          (m.arabicName?.toLowerCase().contains(query) ?? false) ||
          m.displayRelationship.toLowerCase().contains(query) ||
          (m.cemeteryName?.toLowerCase().contains(query) ?? false) ||
          (m.cemeteryArea?.toLowerCase().contains(query) ?? false) ||
          (m.gravePlot?.toLowerCase().contains(query) ?? false);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  MemorialState copyWith({
    List<Memorial>? memorials,
    String? selectedCategory,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
    String? actionSuccessMessage,
    bool clearActionSuccess = false,
    bool clearError = false,
  }) {
    return MemorialState(
      memorials: memorials ?? this.memorials,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      actionSuccessMessage: clearActionSuccess
          ? null
          : (actionSuccessMessage ?? this.actionSuccessMessage),
    );
  }

  @override
  List<Object?> get props => [
        memorials,
        selectedCategory,
        searchQuery,
        isLoading,
        errorMessage,
        actionSuccessMessage,
      ];
}

// --- BLoC ---

class MemorialBloc extends Bloc<MemorialEvent, MemorialState> {
  MemorialBloc({
    required GetMemorialsUseCase getMemorialsUseCase,
    required AddMemorialUseCase addMemorialUseCase,
    required UpdateMemorialUseCase updateMemorialUseCase,
    required DeleteMemorialUseCase deleteMemorialUseCase,
    required ToggleFavoriteUseCase toggleFavoriteUseCase,
  })  : _getMemorialsUseCase = getMemorialsUseCase,
        _addMemorialUseCase = addMemorialUseCase,
        _updateMemorialUseCase = updateMemorialUseCase,
        _deleteMemorialUseCase = deleteMemorialUseCase,
        _toggleFavoriteUseCase = toggleFavoriteUseCase,
        super(const MemorialState(isLoading: true)) {
    on<LoadMemorials>(_onLoadMemorials);
    on<AddMemorialEvent>(_onAddMemorial);
    on<UpdateMemorialEvent>(_onUpdateMemorial);
    on<DeleteMemorialEvent>(_onDeleteMemorial);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<CategoryFilterChanged>(_onCategoryFilterChanged);
    on<SearchQueryChanged>(_onSearchQueryChanged);
  }

  final GetMemorialsUseCase _getMemorialsUseCase;
  final AddMemorialUseCase _addMemorialUseCase;
  final UpdateMemorialUseCase _updateMemorialUseCase;
  final DeleteMemorialUseCase _deleteMemorialUseCase;
  final ToggleFavoriteUseCase _toggleFavoriteUseCase;

  Future<void> _onLoadMemorials(
    LoadMemorials event,
    Emitter<MemorialState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await _getMemorialsUseCase((
      category: null,
      searchQuery: null,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (memorials) => emit(state.copyWith(
        isLoading: false,
        memorials: memorials,
        clearError: true,
      )),
    );
  }

  Future<void> _onAddMemorial(
    AddMemorialEvent event,
    Emitter<MemorialState> emit,
  ) async {
    final result = await _addMemorialUseCase(event.memorial);

    await result.fold(
      (failure) async {
        emit(state.copyWith(errorMessage: failure.message));
      },
      (newMemorial) async {
        final updatedList = [newMemorial, ...state.memorials];
        emit(state.copyWith(
          memorials: updatedList,
          actionSuccessMessage: 'Added ${newMemorial.fullName} successfully',
        ));
      },
    );
  }

  Future<void> _onUpdateMemorial(
    UpdateMemorialEvent event,
    Emitter<MemorialState> emit,
  ) async {
    final result = await _updateMemorialUseCase(event.memorial);

    await result.fold(
      (failure) async {
        emit(state.copyWith(errorMessage: failure.message));
      },
      (updated) async {
        final updatedList = state.memorials.map((m) {
          return m.id == updated.id ? updated : m;
        }).toList();
        emit(state.copyWith(
          memorials: updatedList,
          actionSuccessMessage: 'Updated ${updated.fullName} successfully',
        ));
      },
    );
  }

  Future<void> _onDeleteMemorial(
    DeleteMemorialEvent event,
    Emitter<MemorialState> emit,
  ) async {
    final result = await _deleteMemorialUseCase(event.id);

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) {
        final updatedList =
            state.memorials.where((m) => m.id != event.id).toList();
        emit(state.copyWith(
          memorials: updatedList,
          actionSuccessMessage: 'Record deleted',
        ));
      },
    );
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<MemorialState> emit,
  ) async {
    final result = await _toggleFavoriteUseCase(event.id);

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) {
        final updatedList = state.memorials.map((m) {
          if (m.id == event.id) {
            return m.copyWith(isFavorite: !m.isFavorite);
          }
          return m;
        }).toList();
        emit(state.copyWith(memorials: updatedList));
      },
    );
  }

  void _onCategoryFilterChanged(
    CategoryFilterChanged event,
    Emitter<MemorialState> emit,
  ) {
    emit(state.copyWith(selectedCategory: event.category));
  }

  void _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<MemorialState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }
}
