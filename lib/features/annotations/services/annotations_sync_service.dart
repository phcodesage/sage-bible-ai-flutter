import 'package:sagebible/core/services/supabase_service.dart';
import 'package:sagebible/features/annotations/models/annotation_models.dart';
import 'package:sagebible/features/annotations/services/annotations_storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Annotations Sync Service
/// 
/// Handles synchronization of bookmarks, highlights, and notes between
/// local storage and Supabase.
class AnnotationsSyncService {
  final AnnotationsStorageService _storageService;
  final SupabaseClient _supabase = SupabaseService.client;

  AnnotationsSyncService(this._storageService);

  /// Sync all annotations
  /// 
  /// 1. Uploads local annotations to Supabase (merging with existing)
  /// 2. Downloads latest annotations from Supabase
  /// 3. Updates local storage
  Future<void> syncAll(String userId) async {
    await Future.wait([
      _syncBookmarks(userId),
      _syncHighlights(userId),
      _syncNotes(userId),
    ]);
  }

  // ==================== BOOKMARKS ====================

  Future<void> _syncBookmarks(String userId) async {
    print('DEBUG: Starting bookmark sync for user $userId');
    // 1. Get local bookmarks
    final localBookmarks = _storageService.getBookmarks();
    print('DEBUG: Found ${localBookmarks.length} local bookmarks to sync');

    // 2. Upload local bookmarks to Supabase
    if (localBookmarks.isNotEmpty) {
      try {
        final bookmarksData = localBookmarks.map((b) {
          final json = b.toJson();
          // Add user_id and ensure fields match DB schema
          return {
            'user_id': userId,
            'book_name': b.reference.bookName,
            'chapter': b.reference.chapter,
            'verse': b.reference.verse,
            'verse_text': b.verseText,
            'translation': b.reference.translation,
            'created_at': b.createdAt.toIso8601String(),
          };
        }).toList();

        print('DEBUG: Uploading ${bookmarksData.length} bookmarks to Supabase');
        // Upsert: Insert or update on conflict
        // We use upsert to handle duplicates gracefully
        await _supabase.from('bookmarks').upsert(
          bookmarksData,
          onConflict: 'user_id, book_name, chapter, verse, translation',
        );
        print('DEBUG: Upload successful');
      } catch (e) {
        print('DEBUG: Error uploading bookmarks: $e');
      }
    }

    // 3. Download all bookmarks from Supabase
    try {
      print('DEBUG: Fetching remote bookmarks');
      final response = await _supabase
          .from('bookmarks')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      print('DEBUG: Fetched ${response.length} remote bookmarks');

      final remoteBookmarks = (response as List).map((item) {
        return Bookmark(
          reference: VerseReference(
            bookName: item['book_name'],
            chapter: item['chapter'],
            verse: item['verse'],
            translation: item['translation'],
          ),
          verseText: item['verse_text'],
          createdAt: DateTime.parse(item['created_at']),
        );
      }).toList();

      // 4. Update local storage
      await _storageService.saveBookmarks(remoteBookmarks);
      print('DEBUG: Local storage updated with ${remoteBookmarks.length} bookmarks');
    } catch (e) {
      print('DEBUG: Error fetching bookmarks: $e');
    }
  }

  // ==================== HIGHLIGHTS ====================

  Future<void> _syncHighlights(String userId) async {
    // 1. Get local highlights
    final localHighlights = _storageService.getHighlights();

    // 2. Upload local highlights to Supabase
    if (localHighlights.isNotEmpty) {
      final highlightsData = localHighlights.map((h) {
        return {
          'user_id': userId,
          'book_name': h.reference.bookName,
          'chapter': h.reference.chapter,
          'verse': h.reference.verse,
          'color': h.color.name, // Enum to string
          'translation': h.reference.translation,
          'created_at': h.createdAt.toIso8601String(),
        };
      }).toList();

      await _supabase.from('highlights').upsert(
        highlightsData,
        onConflict: 'user_id, book_name, chapter, verse, translation',
      );
    }

    // 3. Download all highlights from Supabase
    final response = await _supabase
        .from('highlights')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final remoteHighlights = (response as List).map((item) {
      // Parse color string to enum
      HighlightColor color;
      try {
        color = HighlightColor.values.firstWhere(
          (e) => e.name == item['color'],
          orElse: () => HighlightColor.yellow,
        );
      } catch (_) {
        color = HighlightColor.yellow;
      }

      return Highlight(
        reference: VerseReference(
          bookName: item['book_name'],
          chapter: item['chapter'],
          verse: item['verse'],
          translation: item['translation'],
        ),
        color: color,
        createdAt: DateTime.parse(item['created_at']),
      );
    }).toList();

    // 4. Update local storage
    await _storageService.saveHighlights(remoteHighlights);
  }

  // ==================== NOTES ====================

  Future<void> _syncNotes(String userId) async {
    // 1. Get local notes
    final localNotes = _storageService.getNotes();

    // 2. Upload local notes to Supabase
    if (localNotes.isNotEmpty) {
      final notesData = localNotes.map((n) {
        return {
          'user_id': userId,
          'book_name': n.reference.bookName,
          'chapter': n.reference.chapter,
          'verse': n.reference.verse,
          'note_text': n.text,
          'translation': n.reference.translation,
          'created_at': n.createdAt.toIso8601String(),
          'updated_at': n.updatedAt.toIso8601String(),
        };
      }).toList();

      await _supabase.from('notes').upsert(
        notesData,
        onConflict: 'user_id, book_name, chapter, verse, translation',
      );
    }

    // 3. Download all notes from Supabase
    final response = await _supabase
        .from('notes')
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false);

    final remoteNotes = (response as List).map((item) {
      return Note(
        reference: VerseReference(
          bookName: item['book_name'],
          chapter: item['chapter'],
          verse: item['verse'],
          translation: item['translation'],
        ),
        text: item['note_text'],
        createdAt: DateTime.parse(item['created_at']),
        updatedAt: DateTime.parse(item['updated_at']),
      );
    }).toList();

    // 4. Update local storage
    await _storageService.saveNotes(remoteNotes);
  }

  // ==================== DELETE METHODS ====================

  Future<void> deleteBookmark(String userId, VerseReference reference) async {
    await _supabase.from('bookmarks').delete().match({
      'user_id': userId,
      'book_name': reference.bookName,
      'chapter': reference.chapter,
      'verse': reference.verse,
      'translation': reference.translation,
    });
  }

  Future<void> deleteHighlight(String userId, VerseReference reference) async {
    await _supabase.from('highlights').delete().match({
      'user_id': userId,
      'book_name': reference.bookName,
      'chapter': reference.chapter,
      'verse': reference.verse,
      'translation': reference.translation,
    });
  }

  Future<void> deleteNote(String userId, VerseReference reference) async {
    await _supabase.from('notes').delete().match({
      'user_id': userId,
      'book_name': reference.bookName,
      'chapter': reference.chapter,
      'verse': reference.verse,
      'translation': reference.translation,
    });
  }
}
