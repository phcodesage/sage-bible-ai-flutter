import 'dart:math';
import 'package:sagebible/features/bible/models/bible_models.dart';
import 'package:sagebible/features/bible/services/bible_repository.dart';

/// Daily Verse Service
/// 
/// Provides a verse of the day based on the current date
class DailyVerseService {
  final BibleRepository _repository;

  DailyVerseService(this._repository);

  /// Get verse of the day
  /// Uses date as seed for consistent daily verse
  Future<DailyVerse?> getDailyVerse(BibleData bibleData) async {
    try {
      // Use current date as seed for random selection
      final now = DateTime.now();
      final seed = now.year * 10000 + now.month * 100 + now.day;
      final random = Random(seed);

      // Get all books
      final books = bibleData.books;
      if (books.isEmpty) return null;

      // Select random book
      final book = books[random.nextInt(books.length)];
      
      // Select random chapter
      if (book.chapters.isEmpty) return null;
      final chapter = book.chapters[random.nextInt(book.chapters.length)];
      
      // Select random verse
      if (chapter.verses.isEmpty) return null;
      final verse = chapter.verses[random.nextInt(chapter.verses.length)];

      return DailyVerse(
        bookName: book.name,
        chapterNumber: chapter.chapter,
        verseNumber: verse.verse,
        verseText: verse.text,
        date: now,
      );
    } catch (e) {
      return null;
    }
  }
}

/// Daily Verse Model
class DailyVerse {
  final String bookName;
  final int chapterNumber;
  final int verseNumber;
  final String verseText;
  final DateTime date;

  DailyVerse({
    required this.bookName,
    required this.chapterNumber,
    required this.verseNumber,
    required this.verseText,
    required this.date,
  });

  /// Get formatted reference (e.g., "John 3:16")
  String get reference => '$bookName $chapterNumber:$verseNumber';

  /// Get formatted date
  String get formattedDate {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Get share text
  String get shareText {
    return '"$verseText"\n\n- $reference\n\nVerse of the Day - $formattedDate';
  }
}
