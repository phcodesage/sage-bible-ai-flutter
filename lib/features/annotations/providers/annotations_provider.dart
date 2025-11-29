import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagebible/features/annotations/models/annotation_models.dart';
import 'package:sagebible/features/annotations/services/annotations_storage_service.dart';
import 'package:sagebible/features/annotations/services/annotations_sync_service.dart';
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
  final AnnotationsSyncService _syncService;
  String? _userId;

  AnnotationsNotifier(this._storage, this._syncService) : super(const AnnotationsState()) {
    _loadAll();
  }

  /// Set current user ID
  void setUserId(String? userId) {
    _userId = userId;
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

    if (_userId != null) {
      await syncWithCloud(_userId!);
    }
  }

  /// Remove bookmark
  Future<void> removeBookmark(VerseReference reference) async {
    await _storage.removeBookmark(reference);
    await _loadAll();

    if (_userId != null) {
      // For removal, we need to handle it in sync service or just sync
      // Note: Current syncAll implementation upserts local to remote.
      // It does NOT delete remote if missing local.
      // So simple syncAll won't work for deletion!
      // We need specific delete method in SyncService.
      await _syncService.deleteBookmark(_userId!, reference);
      await syncWithCloud(_userId!);
    }
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

    if (_userId != null) {
      await syncWithCloud(_userId!);
    }
  }

  /// Remove highlight
  Future<void> removeHighlight(VerseReference reference) async {
    await _storage.removeHighlight(reference);
    await _loadAll();

    if (_userId != null) {
      await _syncService.deleteHighlight(_userId!, reference);
      await syncWithCloud(_userId!);
    }
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

    if (_userId != null) {
      await syncWithCloud(_userId!);
    }
  }

  /// Remove note
  Future<void> removeNote(VerseReference reference) async {
    await _storage.removeNote(reference);
    await _loadAll();

    if (_userId != null) {
      await _syncService.deleteNote(_userId!, reference);
      await syncWithCloud(_userId!);
    }
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

  /// Sync with cloud
  Future<void> syncWithCloud(String userId) async {
    print('DEBUG: AnnotationsNotifier.syncWithCloud called for user $userId');
    state = state.copyWith(isLoading: true);
    try {
      await _syncService.syncAll(userId);
      await _loadAll();
      print('DEBUG: AnnotationsNotifier.syncWithCloud completed');
    } catch (e) {
      // Handle error silently or expose via state if needed
      print('DEBUG: Sync error in Notifier: $e');
      state = state.copyWith(isLoading: false);
    }
  }
}

/// Provider for AnnotationsStorageService
final annotationsStorageServiceProvider = Provider<AnnotationsStorageService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return AnnotationsStorageService(storageService.prefs);
});

/// Provider for AnnotationsSyncService
final annotationsSyncServiceProvider = Provider<AnnotationsSyncService>((ref) {
  final storage = ref.watch(annotationsStorageServiceProvider);
  return AnnotationsSyncService(storage);
});

/// Provider for AnnotationsNotifier
final annotationsProvider = StateNotifierProvider<AnnotationsNotifier, AnnotationsState>((ref) {
  print('DEBUG: annotationsProvider initialized');
  final storage = ref.watch(annotationsStorageServiceProvider);
  final syncService = ref.watch(annotationsSyncServiceProvider);
  
  final notifier = AnnotationsNotifier(storage, syncService);

  // Listen for auth state changes
  ref.listen<AuthState>(authProvider, (previous, next) {
    print('DEBUG: Auth state changed. Previous: ${previous?.isAuthenticated}, Next: ${next.isAuthenticated}');
    
    // Update user ID in notifier
    notifier.setUserId(next.user?.id);

    // User logged in
    if (previous?.isAuthenticated == false && next.isAuthenticated && next.user != null) {
      print('DEBUG: Triggering sync from listener');
      notifier.syncWithCloud(next.user!.id);
    }
    
    // User logged out
    if (previous?.isAuthenticated == true && !next.isAuthenticated) {
      print('DEBUG: Clearing annotations from listener');
      notifier.clearAll();
    }
  });

  // Handle initial state (if already logged in when provider is created)
  final authState = ref.read(authProvider);
  print('DEBUG: Initial auth state: ${authState.isAuthenticated}');
  if (authState.isAuthenticated && authState.user != null) {
    notifier.setUserId(authState.user!.id);
    print('DEBUG: Triggering initial sync');
    Future.microtask(() => notifier.syncWithCloud(authState.user!.id));
  }

  return notifier;
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
