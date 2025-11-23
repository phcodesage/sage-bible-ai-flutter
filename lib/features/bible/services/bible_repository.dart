import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sagebible/features/bible/models/bible_models.dart';

/// Bible Repository
/// 
/// Handles loading and caching Bible translations from JSON assets.
/// Equivalent to the Kotlin BibleRepository.
class BibleRepository {
  // Cache loaded translations to avoid re-parsing
  final Map<BibleTranslation, BibleData> _cache = {};

  /// Load a Bible translation from assets
  /// 
  /// Returns cached data if already loaded, otherwise loads from JSON.
  Future<BibleData> loadTranslation(BibleTranslation translation) async {
    // Return cached data if available
    if (_cache.containsKey(translation)) {
      return _cache[translation]!;
    }

    // Load from asset
    final jsonString = await rootBundle.loadString(translation.assetPath);
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;
    final bibleData = BibleData.fromJson(jsonData);

    // Cache for future use
    _cache[translation] = bibleData;

    return bibleData;
  }

  /// Get list of all book names from a translation
  List<String> getBooks(BibleData data) {
    return data.books.map((book) => book.name).toList();
  }

  /// Get list of chapter numbers for a specific book
  List<int> getChapters(BibleData data, String bookName) {
    final book = data.books.firstWhere(
      (b) => b.name == bookName,
      orElse: () => throw Exception('Book not found: $bookName'),
    );
    return book.chapters.map((chapter) => chapter.chapter).toList();
  }

  /// Get a specific chapter from a book
  Chapter? getChapterContent(BibleData data, String bookName, int chapterNumber) {
    try {
      final book = data.books.firstWhere((b) => b.name == bookName);
      return book.chapters.firstWhere((c) => c.chapter == chapterNumber);
    } catch (e) {
      return null;
    }
  }

  /// Get a specific book by name
  Book? getBook(BibleData data, String bookName) {
    try {
      return data.books.firstWhere((b) => b.name == bookName);
    } catch (e) {
      return null;
    }
  }

  /// Search for verses containing a query string
  /// 
  /// Returns a list of search results with book, chapter, and verse info.
  List<SearchResult> search(BibleData data, String query) {
    if (query.trim().isEmpty) return [];

    final results = <SearchResult>[];
    final lowerQuery = query.toLowerCase();

    for (final book in data.books) {
      for (final chapter in book.chapters) {
        for (final verse in chapter.verses) {
          if (verse.text.toLowerCase().contains(lowerQuery)) {
            results.add(SearchResult(
              bookName: book.name,
              chapterNumber: chapter.chapter,
              verseNumber: verse.verse,
              verseText: verse.text,
            ));
          }
        }
      }
    }

    return results;
  }

  /// Clear cache (useful for memory management)
  void clearCache() {
    _cache.clear();
  }

  /// Check if a translation is cached
  bool isCached(BibleTranslation translation) {
    return _cache.containsKey(translation);
  }
}

/// Search Result model
class SearchResult {
  final String bookName;
  final int chapterNumber;
  final int verseNumber;
  final String verseText;

  SearchResult({
    required this.bookName,
    required this.chapterNumber,
    required this.verseNumber,
    required this.verseText,
  });

  /// Format as reference (e.g., "Genesis 1:1")
  String get reference => '$bookName $chapterNumber:$verseNumber';
}
