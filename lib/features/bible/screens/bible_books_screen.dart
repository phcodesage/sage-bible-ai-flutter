import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sagebible/core/constants/app_constants.dart';
import 'package:sagebible/core/theme/app_theme.dart';
import 'package:sagebible/features/bible/models/bible_models.dart';
import 'package:sagebible/features/bible/providers/bible_provider.dart';
import 'package:sagebible/features/bible/screens/bible_chapters_screen.dart';

/// Bible Books Screen
/// 
/// Displays list of all 66 books of the Bible.
/// Organized into Old Testament and New Testament sections.
class BibleBooksScreen extends ConsumerWidget {
  const BibleBooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bibleState = ref.watch(bibleProvider);
    final books = ref.watch(booksListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Read Bible'),
        actions: [
          // Translation selector
          PopupMenuButton<BibleTranslation>(
            icon: const Icon(Icons.translate),
            tooltip: 'Change Translation',
            onSelected: (translation) {
              ref.read(bibleProvider.notifier).switchTranslation(translation);
            },
            itemBuilder: (context) => BibleTranslation.values.map((translation) {
              final isCurrent = translation == bibleState.currentTranslation;
              return PopupMenuItem(
                value: translation,
                child: Row(
                  children: [
                    if (isCurrent)
                      Icon(Icons.check, color: AppTheme.primaryColor, size: 20)
                    else
                      const SizedBox(width: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            translation.code,
                            style: TextStyle(
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          Text(
                            translation.label,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: bibleState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : bibleState.error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingLarge),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppTheme.errorColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load Bible',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          bibleState.error!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            ref.read(bibleProvider.notifier).loadCurrentTranslation();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : books.isEmpty
                  ? const Center(child: Text('No books available'))
                  : _buildBooksList(context, books, bibleState.currentTranslation),
    );
  }

  Widget _buildBooksList(BuildContext context, List<String> books, BibleTranslation translation) {
    // Split into Old and New Testament
    // Typically first 39 books are OT, remaining 27 are NT
    final otBooks = books.take(39).toList();
    final ntBooks = books.skip(39).toList();

    return ListView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      children: [
        // Current translation badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingSmall,
          ),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.translate,
                size: 16,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                translation.label,
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Old Testament
        _buildSection(
          context,
          'Old Testament',
          otBooks,
          Icons.book_outlined,
        ),
        
        const SizedBox(height: 24),
        
        // New Testament
        _buildSection(
          context,
          'New Testament',
          ntBooks,
          Icons.auto_stories_outlined,
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, List<String> books, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${books.length})',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Books grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 60, // Fixed height for consistent display
          ),
          itemCount: books.length,
          itemBuilder: (context, index) {
            return _buildBookCard(context, books[index]);
          },
        ),
      ],
    );
  }

  Widget _buildBookCard(BuildContext context, String bookName) {
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
          Navigator.of(context).pushNamed(
            '/chapters',
            arguments: bookName,
          );
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  bookName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
