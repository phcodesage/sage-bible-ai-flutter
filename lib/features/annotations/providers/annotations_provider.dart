import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagebible/features/annotations/models/annotation_models.dart';
import 'package:sagebible/features/annotations/services/annotations_storage_service.dart';
import 'package:sagebible/features/auth/providers/auth_provider.dart';

/// Annotations State
class AnnotationsState {
  final List<Bookmark> bookmarks;
  final List<Highlight> highlights;
  final List<Note> notes;
  final bool isLoading;

  const AnnotationsState({
    this.bookmarks = const [],
    this.highlights = const [],
    this.notes = const [],
    this.isLoading = false,
  });

  AnnotationsState copyWith({
    List<Bookmark>? bookmarks,
    List<Highlight>? highlights,
    List<Note>? notes,
    bool? isLoading,
  }) {
    return AnnotationsState(
      bookmarks: bookmarks ?? this.bookmarks,
      highlights: highlights ?? this.highlights,
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Annotations Notifier
class AnnotationsNotifier extends StateNotifier<AnnotationsState> {
  final AnnotationsStorageService _storage;

  AnnotationsNotifier(this._storage) : super(const AnnotationsState()) {
    _loadAll();
  }

  /// Load all annotations from storage
  Future<void> _loadAll() async {
    state = state.copyWith(isLoading: true);
    
    final bookmarks = _storage.getBookmarks();
    final highlights = _storage.getHighlights();
    final notes = _storage.getNotes();
    
    state = state.copyWith(
      bookmarks: bookmarks,
      highlights: highlights,
      notes: notes,
      isLoading: false,
    );
  }

  // ==================== BOOKMARKS ====================

  /// Toggle bookmark
  Future<void> toggleBookmark(VerseReference reference, String verseText) async {
    if (isBookmarked(reference)) {
      await removeBookmark(reference);
    } else {
      await addBookmark(reference, verseText);
    }
  }

  /// Add bookmark
  Future<void> addBookmark(VerseReference reference, String verseText) async {
    final bookmark = Bookmark(
      reference: reference,
      verseText: verseText,
      createdAt: DateTime.now(),
    );
    
    await _storage.addBookmark(bookmark);
    await _loadAll();
  }

  /// Remove bookmark
  Future<void> removeBookmark(VerseReference reference) async {
    await _storage.removeBookmark(reference);
    await _loadAll();
  }

  /// Check if bookmarked
  bool isBookmarked(VerseReference reference) {
    return state.bookmarks.any((b) => b.reference.id == reference.id);
  }

  // ==================== HIGHLIGHTS ====================

  /// Add or update highlight
  Future<void> addHighlight(VerseReference reference, HighlightColor color) async {
    final highlight = Highlight(
      reference: reference,
      color: color,
      createdAt: DateTime.now(),
    );
    
    await _storage.addHighlight(highlight);
    await _loadAll();
  }

  /// Remove highlight
  Future<void> removeHighlight(VerseReference reference) async {
    await _storage.removeHighlight(reference);
    await _loadAll();
  }

  /// Get highlight for verse
  Highlight? getHighlight(VerseReference reference) {
    try {
      return state.highlights.firstWhere((h) => h.reference.id == reference.id);
    } catch (e) {
      return null;
    }
  }

  // ==================== NOTES ====================

  /// Add or update note
  Future<void> addNote(VerseReference reference, String text) async {
    final existingNote = getNote(reference);
    
    final note = existingNote != null
        ? existingNote.copyWith(text: text)
        : Note(
            reference: reference,
            text: text,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
    
    await _storage.addNote(note);
    await _loadAll();
  }

  /// Remove note
  Future<void> removeNote(VerseReference reference) async {
    await _storage.removeNote(reference);
    await _loadAll();
  }

  /// Get note for verse
  Note? getNote(VerseReference reference) {
    try {
      return state.notes.firstWhere((n) => n.reference.id == reference.id);
    } catch (e) {
      return null;
    }
  }

  // ==================== UTILITIES ====================

  /// Clear all annotations
  Future<void> clearAll() async {
    await _storage.clearAll();
    await _loadAll();
  }
}

/// Provider for AnnotationsStorageService
final annotationsStorageServiceProvider = Provider<AnnotationsStorageService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return AnnotationsStorageService(storageService.prefs);
});

/// Provider for AnnotationsNotifier
final annotationsProvider = StateNotifierProvider<AnnotationsNotifier, AnnotationsState>((ref) {
  final storage = ref.watch(annotationsStorageServiceProvider);
  return AnnotationsNotifier(storage);
});

/// Convenience provider for bookmarks list
final bookmarksListProvider = Provider<List<Bookmark>>((ref) {
  return ref.watch(annotationsProvider).bookmarks;
});

/// Convenience provider for highlights list
final highlightsListProvider = Provider<List<Highlight>>((ref) {
  return ref.watch(annotationsProvider).highlights;
});

/// Convenience provider for notes list
final notesListProvider = Provider<List<Note>>((ref) {
  return ref.watch(annotationsProvider).notes;
});
