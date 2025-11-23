import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagebible/core/constants/app_constants.dart';
import 'package:sagebible/core/theme/app_theme.dart';

/// Bookmarks Screen
/// 
/// Displays user's bookmarked verses.
/// Works offline - no login required.
class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Implement bookmarks provider
    final bookmarks = <String>[]; // Placeholder

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
      ),
      body: bookmarks.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmark_outline,
                      size: 80,
                      color: AppTheme.textLight,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Bookmarks Yet',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the bookmark icon while reading to save your favorite verses',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              itemCount: bookmarks.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.bookmark,
                      color: AppTheme.primaryColor,
                    ),
                    title: Text('Bookmark ${index + 1}'),
                    subtitle: const Text('Coming soon...'),
                  ),
                );
              },
            ),
    );
  }
}
