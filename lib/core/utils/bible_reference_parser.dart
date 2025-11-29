class BibleReferenceParser {
  // Regex to match Bible references like:
  // John 3:16
  // 1 Corinthians 13:4
  // Genesis 1:1-5
  // Leviticus 11:7-8
  static final RegExp _referenceRegex = RegExp(
    r'\b((?:[1-3]\s)?[A-Za-z]+)\s+(\d+):(\d+)(?:-(\d+))?\b',
    caseSensitive: false,
  );

  /// Find all Bible references in the text
  static List<BibleReferenceMatch> parse(String text) {
    final matches = _referenceRegex.allMatches(text);
    return matches.map((match) {
      return BibleReferenceMatch(
        text: match.group(0)!,
        book: match.group(1)!,
        chapter: int.parse(match.group(2)!),
        verse: int.parse(match.group(3)!),
        endVerse: match.group(4) != null ? int.parse(match.group(4)!) : null,
        start: match.start,
        end: match.end,
      );
    }).toList();
  }
}

class BibleReferenceMatch {
  final String text;      // Full text "John 3:16"
  final String book;      // "John"
  final int chapter;      // 3
  final int verse;        // 16
  final int? endVerse;    // Optional end verse
  final int start;        // Start index in original string
  final int end;          // End index in original string

  BibleReferenceMatch({
    required this.text,
    required this.book,
    required this.chapter,
    required this.verse,
    this.endVerse,
    required this.start,
    required this.end,
  });
}
