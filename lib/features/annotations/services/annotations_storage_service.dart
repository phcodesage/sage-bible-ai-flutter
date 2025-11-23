import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagebible/features/annotations/models/annotation_models.dart';

/// Annotations Storage Service
/// 
/// Handles local storage of bookmarks, highlights, and notes
class AnnotationsStorageService {
  static const String _keyBookmarks = 'bookmarks';
  static const String _keyHighlights = 'highlights';
  static const String _keyNotes = 'notes';

  final SharedPreferences _prefs;

  AnnotationsStorageService(this._prefs);

  // ==================== BOOKMARKS ====================

  /// Get all bookmarks
  List<Bookmark> getBookmarks() {
    final json = _prefs.getString(_keyBookmarks);
    if (json == null) return [];

    final List<dynamic> list = jsonDecode(json);
    return list.map((item) => Bookmark.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// Save bookmarks
  Future<void> saveBookmarks(List<Bookmark> bookmarks) async {
    final json = jsonEncode(bookmarks.map((b) => b.toJson()).toList());
    await _prefs.setString(_keyBookmarks, json);
  }

  /// Add bookmark
  Future<void> addBookmark(Bookmark bookmark) async {
    final bookmarks = getBookmarks();
    
    // Remove if already exists
    bookmarks.removeWhere((b) => b.reference.id == bookmark.reference.id);
    
    // Add new bookmark
    bookmarks.insert(0, bookmark); // Add to beginning
    
    await saveBookmarks(bookmarks);
  }

  /// Remove bookmark
  Future<void> removeBookmark(VerseReference reference) async {
    final bookmarks = getBookmarks();
    bookmarks.removeWhere((b) => b.reference.id == reference.id);
    await saveBookmarks(bookmarks);
  }

  /// Check if verse is bookmarked
  bool isBookmarked(VerseReference reference) {
    final bookmarks = getBookmarks();
    return bookmarks.any((b) => b.reference.id == reference.id);
  }

  // ==================== HIGHLIGHTS ====================

  /// Get all highlights
  List<Highlight> getHighlights() {
    final json = _prefs.getString(_keyHighlights);
    if (json == null) return [];

    final List<dynamic> list = jsonDecode(json);
    return list.map((item) => Highlight.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// Save highlights
  Future<void> saveHighlights(List<Highlight> highlights) async {
    final json = jsonEncode(highlights.map((h) => h.toJson()).toList());
    await _prefs.setString(_keyHighlights, json);
  }

  /// Add or update highlight
  Future<void> addHighlight(Highlight highlight) async {
    final highlights = getHighlights();
    
    // Remove if already exists
    highlights.removeWhere((h) => h.reference.id == highlight.reference.id);
    
    // Add new highlight
    highlights.add(highlight);
    
    await saveHighlights(highlights);
  }

  /// Remove highlight
  Future<void> removeHighlight(VerseReference reference) async {
    final highlights = getHighlights();
    highlights.removeWhere((h) => h.reference.id == reference.id);
    await saveHighlights(highlights);
  }

  /// Get highlight for a verse
  Highlight? getHighlight(VerseReference reference) {
    final highlights = getHighlights();
    try {
      return highlights.firstWhere((h) => h.reference.id == reference.id);
    } catch (e) {
      return null;
    }
  }

  // ==================== NOTES ====================

  /// Get all notes
  List<Note> getNotes() {
    final json = _prefs.getString(_keyNotes);
    if (json == null) return [];

    final List<dynamic> list = jsonDecode(json);
    return list.map((item) => Note.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// Save notes
  Future<void> saveNotes(List<Note> notes) async {
    final json = jsonEncode(notes.map((n) => n.toJson()).toList());
    await _prefs.setString(_keyNotes, json);
  }

  /// Add or update note
  Future<void> addNote(Note note) async {
    final notes = getNotes();
    
    // Remove if already exists
    notes.removeWhere((n) => n.reference.id == note.reference.id);
    
    // Add new note
    notes.add(note);
    
    await saveNotes(notes);
  }

  /// Remove note
  Future<void> removeNote(VerseReference reference) async {
    final notes = getNotes();
    notes.removeWhere((n) => n.reference.id == reference.id);
    await saveNotes(notes);
  }

  /// Get note for a verse
  Note? getNote(VerseReference reference) {
    final notes = getNotes();
    try {
      return notes.firstWhere((n) => n.reference.id == reference.id);
    } catch (e) {
      return null;
    }
  }

  // ==================== CLEAR ALL ====================

  /// Clear all annotations
  Future<void> clearAll() async {
    await _prefs.remove(_keyBookmarks);
    await _prefs.remove(_keyHighlights);
    await _prefs.remove(_keyNotes);
  }
}
