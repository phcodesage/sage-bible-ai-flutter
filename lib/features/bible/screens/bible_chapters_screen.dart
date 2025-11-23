import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagebible/core/constants/app_constants.dart';
import 'package:sagebible/core/theme/app_theme.dart';
import 'package:sagebible/features/bible/providers/bible_provider.dart';
import 'package:sagebible/features/bible/screens/bible_reader_screen.dart';

/// Bible Chapters Screen
/// 
/// Displays list of chapters for a selected book.
class BibleChaptersScreen extends ConsumerWidget {
  final String bookName;

  const BibleChaptersScreen({
    super.key,
    required this.bookName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapters = ref.read(bibleProvider.notifier).getChapters(bookName);

    return Scaffold(
      appBar: AppBar(
        title: Text(bookName),
      ),
      body: chapters.isEmpty
          ? const Center(child: Text('No chapters available'))
          : GridView.builder(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final chapterNumber = chapters[index];
                return _buildChapterCard(context, chapterNumber);
              },
            ),
    );
  }

  Widget _buildChapterCard(BuildContext context, int chapterNumber) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        side: BorderSide(
          color: AppTheme.textLight.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BibleReaderScreen(
                bookName: bookName,
                chapterNumber: chapterNumber,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: Center(
          child: Text(
            chapterNumber.toString(),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
