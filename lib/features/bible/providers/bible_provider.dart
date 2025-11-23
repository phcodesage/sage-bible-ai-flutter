import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagebible/features/bible/models/bible_models.dart';
import 'package:sagebible/features/bible/services/bible_repository.dart';

/// Bible State
/// 
/// Manages the current Bible translation and loaded data.
class BibleState {
  final BibleTranslation currentTranslation;
  final BibleData? data;
  final bool isLoading;
  final String? error;

  const BibleState({
    this.currentTranslation = BibleTranslation.kjv,
    this.data,
    this.isLoading = false,
    this.error,
  });

  BibleState copyWith({
    BibleTranslation? currentTranslation,
    BibleData? data,
    bool? isLoading,
    String? error,
  }) {
    return BibleState(
      currentTranslation: currentTranslation ?? this.currentTranslation,
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Bible Notifier
/// 
/// Manages Bible data loading and translation switching.
class BibleNotifier extends StateNotifier<BibleState> {
  final BibleRepository _repository;

  BibleNotifier(this._repository) : super(const BibleState());

  /// Load the current translation
  Future<void> loadCurrentTranslation() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await _repository.loadTranslation(state.currentTranslation);
      state = state.copyWith(
        data: data,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load Bible: ${e.toString()}',
      );
    }
  }

  /// Switch to a different translation
  Future<void> switchTranslation(BibleTranslation translation) async {
    if (translation == state.currentTranslation) return;

    state = state.copyWith(
      currentTranslation: translation,
      isLoading: true,
      error: null,
    );

    try {
      final data = await _repository.loadTranslation(translation);
      state = state.copyWith(
        data: data,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load translation: ${e.toString()}',
      );
    }
  }

  /// Get list of books
  List<String> getBooks() {
    if (state.data == null) return [];
    return _repository.getBooks(state.data!);
  }

  /// Get chapters for a book
  List<int> getChapters(String bookName) {
    if (state.data == null) return [];
    return _repository.getChapters(state.data!, bookName);
  }

  /// Get chapter content
  Chapter? getChapterContent(String bookName, int chapterNumber) {
    if (state.data == null) return null;
    return _repository.getChapterContent(state.data!, bookName, chapterNumber);
  }

  /// Search for verses containing the query
  List<SearchResult> search(String query) {
    if (state.data == null) return [];
    return _repository.search(state.data!, query);
  }
}

/// Provider for BibleRepository
final bibleRepositoryProvider = Provider<BibleRepository>((ref) {
  return BibleRepository();
});

/// Provider for BibleNotifier
final bibleProvider = StateNotifierProvider<BibleNotifier, BibleState>((ref) {
  final repository = ref.watch(bibleRepositoryProvider);
  final notifier = BibleNotifier(repository);
  
  // Auto-load default translation on startup
  Future.microtask(() => notifier.loadCurrentTranslation());
  
  return notifier;
});

/// Convenience provider to get current Bible data
final currentBibleDataProvider = Provider<BibleData?>((ref) {
  return ref.watch(bibleProvider).data;
});

/// Convenience provider to get list of books
final booksListProvider = Provider<List<String>>((ref) {
  final bibleState = ref.watch(bibleProvider);
  if (bibleState.data == null) return [];
  return bibleState.data!.books.map((book) => book.name).toList();
});
