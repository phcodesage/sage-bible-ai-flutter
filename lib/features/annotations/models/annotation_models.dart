import 'dart:convert';

/// Verse Reference
/// 
/// Uniquely identifies a verse in the Bible
class VerseReference {
  final String bookName;
  final int chapter;
  final int verse;
  final String translation;

  VerseReference({
    required this.bookName,
    required this.chapter,
    required this.verse,
    this.translation = 'KJV',
  });

  /// Create unique ID for this verse
  String get id => '${bookName}_${chapter}_$verse';

  /// Format as readable reference (e.g., "Genesis 1:1")
  String get reference => '$bookName $chapter:$verse';

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'bookName': bookName,
      'chapter': chapter,
      'verse': verse,
      'translation': translation,
    };
  }

  /// Create from JSON
  factory VerseReference.fromJson(Map<String, dynamic> json) {
    return VerseReference(
      bookName: json['bookName'] as String,
      chapter: json['chapter'] as int,
      verse: json['verse'] as int,
      translation: json['translation'] as String? ?? 'KJV',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerseReference &&
          runtimeType == other.runtimeType &&
          bookName == other.bookName &&
          chapter == other.chapter &&
          verse == other.verse &&
          translation == other.translation;

  @override
  int get hashCode => 
      bookName.hashCode ^ 
      chapter.hashCode ^ 
      verse.hashCode ^ 
      translation.hashCode;
}

/// Bookmark
/// 
/// Saved verse for quick access
class Bookmark {
  final VerseReference reference;
  final String verseText;
  final DateTime createdAt;

  Bookmark({
    required this.reference,
    required this.verseText,
    required this.createdAt,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'reference': reference.toJson(),
      'verseText': verseText,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      reference: VerseReference.fromJson(json['reference'] as Map<String, dynamic>),
      verseText: json['verseText'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Highlight Color
enum HighlightColor {
  yellow('#FFF9C4', 'Yellow'),
  green('#C8E6C9', 'Green'),
  blue('#BBDEFB', 'Blue'),
  pink('#F8BBD0', 'Pink'),
  orange('#FFE0B2', 'Orange');

  final String hex;
  final String label;

  const HighlightColor(this.hex, this.label);

  /// Get Color from hex
  int get colorValue {
    return int.parse(hex.substring(1), radix: 16) + 0xFF000000;
  }
}

/// Highlight
/// 
/// Colored highlight on a verse
class Highlight {
  final VerseReference reference;
  final HighlightColor color;
  final DateTime createdAt;

  Highlight({
    required this.reference,
    required this.color,
    required this.createdAt,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'reference': reference.toJson(),
      'color': color.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory Highlight.fromJson(Map<String, dynamic> json) {
    return Highlight(
      reference: VerseReference.fromJson(json['reference'] as Map<String, dynamic>),
      color: HighlightColor.values.firstWhere(
        (c) => c.name == json['color'],
        orElse: () => HighlightColor.yellow,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Note
/// 
/// Personal note attached to a verse
class Note {
  final VerseReference reference;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.reference,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'reference': reference.toJson(),
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      reference: VerseReference.fromJson(json['reference'] as Map<String, dynamic>),
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Create copy with updated text
  Note copyWith({String? text}) {
    return Note(
      reference: reference,
      text: text ?? this.text,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
