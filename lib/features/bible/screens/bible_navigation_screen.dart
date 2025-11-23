import 'package:flutter/material.dart';
import 'package:sagebible/features/bible/screens/bible_books_screen.dart';
import 'package:sagebible/features/bible/screens/bible_chapters_screen.dart';
import 'package:sagebible/features/bible/screens/bible_reader_screen.dart';

/// Bible Navigation Screen with nested navigation
/// 
/// Keeps the bottom navigation bar visible while navigating
/// between Books → Chapters → Reader screens
class BibleNavigationScreen extends StatefulWidget {
  const BibleNavigationScreen({super.key});

  @override
  State<BibleNavigationScreen> createState() => _BibleNavigationScreenState();
}

class _BibleNavigationScreenState extends State<BibleNavigationScreen> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      onGenerateRoute: (settings) {
        // Handle different routes within the Bible tab
        if (settings.name == '/chapters') {
          final bookName = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => BibleChaptersScreen(bookName: bookName),
          );
        } else if (settings.name == '/reader') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => BibleReaderScreen(
              bookName: args['bookName'] as String,
              chapterNumber: args['chapter'] as int,
            ),
          );
        }
        
        // Default route - Books list
        return MaterialPageRoute(
          builder: (context) => const BibleBooksScreen(),
        );
      },
    );
  }
}
