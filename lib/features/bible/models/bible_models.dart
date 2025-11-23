/// Bible Data Models
/// 
/// Models for parsing and working with Bible JSON data.

/// Main Bible Data structure
class BibleData {
  final String translation;
  final List<Book> books;

  BibleData({
    required this.translation,
    required this.books,
  });

  /// Create BibleData from JSON
  factory BibleData.fromJson(Map<String, dynamic> json) {
    return BibleData(
      translation: json['translation'] as String,
      books: (json['books'] as List)
          .map((book) => Book.fromJson(book as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'translation': translation,
      'books': books.map((book) => book.toJson()).toList(),
    };
  }
}

/// Book model
class Book {
  final String name;
  final List<Chapter> chapters;

  Book({
    required this.name,
    required this.chapters,
  });

  /// Create Book from JSON
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      name: json['name'] as String,
      chapters: (json['chapters'] as List)
          .map((chapter) => Chapter.fromJson(chapter as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'chapters': chapters.map((chapter) => chapter.toJson()).toList(),
    };
  }

  /// Get total number of chapters
  int get chapterCount => chapters.length;
}

/// Chapter model
class Chapter {
  final int chapter;
  final List<Verse> verses;

  Chapter({
    required this.chapter,
    required this.verses,
  });

  /// Create Chapter from JSON
  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      chapter: json['chapter'] as int,
      verses: (json['verses'] as List)
          .map((verse) => Verse.fromJson(verse as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'chapter': chapter,
      'verses': verses.map((verse) => verse.toJson()).toList(),
    };
  }

  /// Get total number of verses
  int get verseCount => verses.length;
}

/// Verse model
class Verse {
  final int verse;
  final String text;

  Verse({
    required this.verse,
    required this.text,
  });

  /// Create Verse from JSON
  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      verse: json['verse'] as int,
      text: (json['text'] as String).trim(), // Trim whitespace
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'verse': verse,
      'text': text,
    };
  }
}

/// Bible Translation enum
enum BibleTranslation {
  kjv('KJV.json', 'KJV', 'King James Version'),
  akjv('AKJV.json', 'AKJV', 'American King James Version'),
  ceb('CebPinadayag.json', 'CEB', 'Cebuano (Pinadayag)');

  final String fileName;
  final String code;
  final String label;

  const BibleTranslation(this.fileName, this.code, this.label);

  /// Get asset path
  String get assetPath => 'assets/data/$fileName';
}
