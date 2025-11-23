import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagebible/core/constants/app_constants.dart';
import 'package:sagebible/core/theme/app_theme.dart';
import 'package:sagebible/features/bible/providers/bible_provider.dart';

/// Bible Reader Screen
/// 
/// Displays verses for a specific chapter with beautiful formatting.
class BibleReaderScreen extends ConsumerStatefulWidget {
  final String bookName;
  final int chapterNumber;

  const BibleReaderScreen({
    super.key,
    required this.bookName,
    required this.chapterNumber,
  });

  @override
  ConsumerState<BibleReaderScreen> createState() => _BibleReaderScreenState();
}

class _BibleReaderScreenState extends ConsumerState<BibleReaderScreen> {
  double _fontSize = 16.0;
  int? _selectedVerse;

  @override
  Widget build(BuildContext context) {
    final chapter = ref.read(bibleProvider.notifier)
        .getChapterContent(widget.bookName, widget.chapterNumber);

    if (chapter == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.bookName} ${widget.chapterNumber}'),
        ),
        body: const Center(child: Text('Chapter not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.bookName} ${widget.chapterNumber}'),
        actions: [
          // Font size controls
          IconButton(
            icon: const Icon(Icons.text_decrease),
            onPressed: () {
              setState(() {
                _fontSize = (_fontSize - 2).clamp(12.0, 24.0);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.text_increase),
            onPressed: () {
              setState(() {
                _fontSize = (_fontSize + 2).clamp(12.0, 24.0);
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        itemCount: chapter.verses.length,
        itemBuilder: (context, index) {
          final verse = chapter.verses[index];
          final isSelected = _selectedVerse == verse.verse;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedVerse = isSelected ? null : verse.verse;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Verse number
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        verse.verse.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Verse text
                  Expanded(
                    child: Text(
                      verse.text,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: _fontSize,
                        height: 1.8,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      
      // Action buttons when verse is selected
      bottomNavigationBar: _selectedVerse != null
          ? Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    context,
                    Icons.bookmark_outline,
                    'Bookmark',
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Bookmarked ${widget.bookName} ${widget.chapterNumber}:$_selectedVerse',
                          ),
                        ),
                      );
                    },
                  ),
                  _buildActionButton(
                    context,
                    Icons.highlight,
                    'Highlight',
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Highlight feature coming soon!')),
                      );
                    },
                  ),
                  _buildActionButton(
                    context,
                    Icons.note_outlined,
                    'Note',
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notes feature coming soon!')),
                      );
                    },
                  ),
                  _buildActionButton(
                    context,
                    Icons.share,
                    'Share',
                    () {
                      final verse = chapter.verses.firstWhere((v) => v.verse == _selectedVerse);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '"${verse.text}" - ${widget.bookName} ${widget.chapterNumber}:$_selectedVerse',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
