import 'package:memorial_keeper/src/utils/utils.dart';
import '../entities/memorial.dart';

abstract class MemorialRepository {
  /// Fetch all memorials with optional category and search query filters
  FutureEither<List<Memorial>> getMemorials({
    String? category,
    String? searchQuery,
  });

  /// Get a single memorial by ID
  FutureEither<Memorial?> getMemorialById(String id);

  /// Add a new memorial
  FutureEither<Memorial> addMemorial(Memorial memorial);

  /// Update an existing memorial
  FutureEither<Memorial> updateMemorial(Memorial memorial);

  /// Delete a memorial by ID
  FutureEither<void> deleteMemorial(String id);

  /// Toggle favorite status of a memorial
  FutureEither<void> toggleFavorite(String id);
}
