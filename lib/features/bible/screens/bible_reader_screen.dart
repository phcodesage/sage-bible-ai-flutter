import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sagebible/core/constants/app_constants.dart';
import 'package:sagebible/core/theme/app_theme.dart';
import 'package:sagebible/features/bible/providers/bible_provider.dart';
import 'package:sagebible/features/annotations/models/annotation_models.dart';
import 'package:sagebible/features/annotations/providers/annotations_provider.dart';

/// Bible Reader Screen
/// 
/// Displays verses for a specific chapter with beautiful formatting.
class BibleReaderScreen extends ConsumerStatefulWidget {
  final String bookName;
  final int chapterNumber;
  final int? highlightVerse; // Optional verse to scroll to and highlight

  const BibleReaderScreen({
    super.key,
    required this.bookName,
    required this.chapterNumber,
    this.highlightVerse,
  });

  @override
  ConsumerState<BibleReaderScreen> createState() => _BibleReaderScreenState();
}

class _BibleReaderScreenState extends ConsumerState<BibleReaderScreen> {
  double _fontSize = 16.0;
  int? _selectedVerse;
  late int _currentChapter;
  late String _currentBook;
  final ScrollController _scrollController = ScrollController();
  int? _highlightedVerse; // Verse to highlight from search
  final Map<int, GlobalKey> _verseKeys = {}; // Keys for each verse

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.chapterNumber;
    _currentBook = widget.bookName;
    _highlightedVerse = widget.highlightVerse;
    
    // Scroll to highlighted verse after build
    if (widget.highlightVerse != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToVerse(widget.highlightVerse!);
      });
    }
  }

  @override
  void didUpdateWidget(BibleReaderScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if we navigated to a different chapter/book with a new highlight
    if (widget.highlightVerse != null &&
        (widget.highlightVerse != oldWidget.highlightVerse ||
         widget.chapterNumber != oldWidget.chapterNumber ||
         widget.bookName != oldWidget.bookName)) {
      
      // Update state
      _currentChapter = widget.chapterNumber;
      _currentBook = widget.bookName;
      _highlightedVerse = widget.highlightVerse;
      _verseKeys.clear(); // Clear old keys
      
      // Scroll to new verse
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToVerse(widget.highlightVerse!);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _verseKeys.clear();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Clear verse keys when theme changes to avoid GlobalKey errors
    _verseKeys.clear();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _scrollToVerse(int verseNumber) {
    // Use a more aggressive approach: scroll to approximate position multiple times
    // to force ListView to build the items
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!_scrollController.hasClients) return;
      
      // Estimate: each verse is roughly 100-200 pixels depending on text length
      // Use 150 as a reasonable average
      final estimatedPosition = (verseNumber - 1) * 150.0;
      final maxScroll = _scrollController.position.maxScrollExtent;
      
      // First scroll: jump to approximate position
      _scrollController.jumpTo(
        estimatedPosition.clamp(0.0, maxScroll),
      );
      
      // Second attempt: after ListView builds more items
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted || !_scrollController.hasClients) return;
        
        final key = _verseKeys[verseNumber];
        if (key?.currentContext != null) {
          // Fine-tune with ensureVisible
          Scrollable.ensureVisible(
            key!.currentContext!,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            alignment: 0.15,
          );
        } else {
          // If key still not available, try scrolling a bit more
          final newEstimate = (verseNumber - 1) * 140.0;
          _scrollController.animateTo(
            newEstimate.clamp(0.0, _scrollController.position.maxScrollExtent),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
          
          // Third attempt
          Future.delayed(const Duration(milliseconds: 400), () {
            if (!mounted) return;
            final key = _verseKeys[verseNumber];
            if (key?.currentContext != null) {
              Scrollable.ensureVisible(
                key!.currentContext!,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: 0.15,
              );
            }
          });
        }
      });
      
      // Clear highlight after 4 seconds
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() {
            _highlightedVerse = null;
          });
        }
      });
    });
  }

  void _goToNextChapter() {
    final chapters = ref.read(bibleProvider.notifier).getChapters(_currentBook);
    if (_currentChapter < chapters.length) {
      setState(() {
        _currentChapter++;
        _selectedVerse = null;
      });
      _scrollToTop();
    } else {
      // Try to go to next book
      _goToNextBook();
    }
  }

  void _goToPreviousChapter() {
    if (_currentChapter > 1) {
      setState(() {
        _currentChapter--;
        _selectedVerse = null;
      });
      _scrollToTop();
    } else {
      // Try to go to previous book
      _goToPreviousBook();
    }
  }

  void _goToNextBook() {
    final books = ref.read(bibleProvider.notifier).getBooks();
    final currentIndex = books.indexOf(_currentBook);
    if (currentIndex < books.length - 1) {
      setState(() {
        _currentBook = books[currentIndex + 1];
        _currentChapter = 1;
        _selectedVerse = null;
      });
      _scrollToTop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Moved to $_currentBook'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _goToPreviousBook() {
    final books = ref.read(bibleProvider.notifier).getBooks();
    final currentIndex = books.indexOf(_currentBook);
    if (currentIndex > 0) {
      final previousBook = books[currentIndex - 1];
      final previousBookChapters = ref.read(bibleProvider.notifier).getChapters(previousBook);
      setState(() {
        _currentBook = previousBook;
        _currentChapter = previousBookChapters.length; // Last chapter
        _selectedVerse = null;
      });
      _scrollToTop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Moved to $_currentBook'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  bool _canGoToNextBook() {
    final books = ref.read(bibleProvider.notifier).getBooks();
    final currentIndex = books.indexOf(_currentBook);
    return currentIndex < books.length - 1;
  }

  bool _canGoToPreviousBook() {
    final books = ref.read(bibleProvider.notifier).getBooks();
    final currentIndex = books.indexOf(_currentBook);
    return currentIndex > 0;
  }

  void _handleBookmark() async {
    if (_selectedVerse == null) return;
    
    final verse = ref.read(bibleProvider.notifier)
        .getChapterContent(_currentBook, _currentChapter)
        ?.verses.firstWhere((v) => v.verse == _selectedVerse);
    
    if (verse == null) return;
    
    final verseRef = VerseReference(
      bookName: _currentBook,
      chapter: _currentChapter,
      verse: _selectedVerse!,
    );
    
    await ref.read(annotationsProvider.notifier).toggleBookmark(verseRef, verse.text);
    
    if (mounted) {
      final isBookmarked = ref.read(annotationsProvider.notifier).isBookmarked(verseRef);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isBookmarked ? 'Bookmark added' : 'Bookmark removed'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _handleHighlight() async {
    if (_selectedVerse == null) return;
    
    final verseRef = VerseReference(
      bookName: _currentBook,
      chapter: _currentChapter,
      verse: _selectedVerse!,
    );
    
    // Show color picker
    final color = await showDialog<HighlightColor>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Highlight Color'),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: HighlightColor.values.map((color) {
            return InkWell(
              onTap: () => Navigator.of(context).pop(color),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(color.colorValue),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey, width: 1),
                ),
                child: Center(
                  child: Text(
                    color.label,
                    style: const TextStyle(fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(annotationsProvider.notifier).removeHighlight(verseRef);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    
    if (color != null) {
      await ref.read(annotationsProvider.notifier).addHighlight(verseRef, color);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Highlight added'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _handleNote() async {
    if (_selectedVerse == null) return;
    
    final verseRef = VerseReference(
      bookName: _currentBook,
      chapter: _currentChapter,
      verse: _selectedVerse!,
    );
    
    final existingNote = ref.read(annotationsProvider.notifier).getNote(verseRef);
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: existingNote?.text ?? '');
        
        return AlertDialog(
          title: Text('Note for ${verseRef.reference}'),
          content: TextField(
            controller: controller,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Enter your note...',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            if (existingNote != null)
              TextButton(
                onPressed: () async {
                  await ref.read(annotationsProvider.notifier).removeNote(verseRef);
                  if (context.mounted) Navigator.of(context).pop('deleted');
                },
                child: const Text('Delete'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = controller.text;
                Navigator.of(context).pop(text);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    
    if (result != null && result.isNotEmpty && result != 'deleted') {
      await ref.read(annotationsProvider.notifier).addNote(verseRef, result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note saved'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } else if (result == 'deleted' && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note deleted'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _handleShare() {
    if (_selectedVerse == null) return;
    
    final verse = ref.read(bibleProvider.notifier)
        .getChapterContent(_currentBook, _currentChapter)
        ?.verses.firstWhere((v) => v.verse == _selectedVerse);
    
    if (verse == null) return;
    
    final verseRef = VerseReference(
      bookName: _currentBook,
      chapter: _currentChapter,
      verse: _selectedVerse!,
    );
    
    final shareText = '"${verse.text}"\n\n- ${verseRef.reference}';
    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    final chapter = ref.read(bibleProvider.notifier)
        .getChapterContent(_currentBook, _currentChapter);

    if (chapter == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('$_currentBook $_currentChapter'),
        ),
        body: const Center(child: Text('Chapter not found')),
      );
    }

    final chapters = ref.read(bibleProvider.notifier).getChapters(_currentBook);
    final hasPrevious = _currentChapter > 1 || _canGoToPreviousBook();
    final hasNext = _currentChapter < chapters.length || _canGoToNextBook();

    return Scaffold(
      appBar: AppBar(
        title: Text('$_currentBook $_currentChapter'),
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
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          // Swipe left = next chapter
          if (details.primaryVelocity! < 0 && hasNext) {
            _goToNextChapter();
          }
          // Swipe right = previous chapter
          else if (details.primaryVelocity! > 0 && hasPrevious) {
            _goToPreviousChapter();
          }
        },
        child: Column(
          children: [
            // Chapter navigation bar
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingSmall,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.05),
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.textLight.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button
                  TextButton.icon(
                    onPressed: hasPrevious ? _goToPreviousChapter : null,
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Previous'),
                    style: TextButton.styleFrom(
                      foregroundColor: hasPrevious
                          ? AppTheme.primaryColor
                          : AppTheme.textLight,
                    ),
                  ),
                  
                  // Chapter indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Chapter $_currentChapter of ${chapters.length}',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  
                  // Next button
                  TextButton.icon(
                    onPressed: hasNext ? _goToNextChapter : null,
                    icon: const Text('Next'),
                    label: const Icon(Icons.chevron_right),
                    style: TextButton.styleFrom(
                      foregroundColor: hasNext
                          ? AppTheme.primaryColor
                          : AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
            
            // Verses list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                itemCount: chapter.verses.length,
                itemBuilder: (context, index) {
                  final verse = chapter.verses[index];
                  final isSelected = _selectedVerse == verse.verse;
                  final isHighlighted = _highlightedVerse == verse.verse;
                  
                  // Create or get key for this verse
                  _verseKeys.putIfAbsent(verse.verse, () => GlobalKey());
                  
                  // Get annotations for this verse
                  final verseRef = VerseReference(
                    bookName: _currentBook,
                    chapter: _currentChapter,
                    verse: verse.verse,
                  );
                  final highlight = ref.read(annotationsProvider.notifier).getHighlight(verseRef);
                  final isBookmarked = ref.watch(annotationsProvider.notifier).isBookmarked(verseRef);
                  final hasNote = ref.read(annotationsProvider.notifier).getNote(verseRef) != null;

                  return GestureDetector(
                    key: _verseKeys[verse.verse],
                    onTap: () {
                      setState(() {
                        _selectedVerse = isSelected ? null : verse.verse;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      decoration: BoxDecoration(
                        color: isHighlighted
                            ? AppTheme.accentColor.withOpacity(0.3)
                            : isSelected
                                ? AppTheme.primaryColor.withOpacity(0.1)
                                : highlight != null
                                    ? Color(highlight.color.colorValue)
                                    : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        border: isHighlighted
                            ? Border.all(color: AppTheme.accentColor, width: 3)
                            : isBookmarked
                                ? Border.all(color: AppTheme.accentColor, width: 2)
                                : null,
                        boxShadow: isHighlighted
                            ? [
                                BoxShadow(
                                  color: AppTheme.accentColor.withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Verse number with indicators
                          Column(
                            children: [
                              Stack(
                                children: [
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
                                  if (isBookmarked)
                                    Positioned(
                                      right: -2,
                                      top: -2,
                                      child: Icon(
                                        Icons.bookmark,
                                        size: 16,
                                        color: AppTheme.accentColor,
                                      ),
                                    ),
                                ],
                              ),
                              if (hasNote)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Icon(
                                    Icons.note,
                                    size: 12,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                            ],
                          ),
                          
                          const SizedBox(width: 12),
                          
                          // Verse text
                          Expanded(
                            child: Text(
                              verse.text,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontSize: _fontSize,
                                height: 1.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      
      // Action buttons when verse is selected
      bottomNavigationBar: _selectedVerse != null
          ? Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
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
                    _handleBookmark,
                  ),
                  _buildActionButton(
                    context,
                    Icons.highlight,
                    'Highlight',
                    _handleHighlight,
                  ),
                  _buildActionButton(
                    context,
                    Icons.note_outlined,
                    'Note',
                    _handleNote,
                  ),
                  _buildActionButton(
                    context,
                    Icons.share,
                    'Share',
                    _handleShare,
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
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
