import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagebible/core/constants/app_constants.dart';
import 'package:sagebible/core/theme/app_theme.dart';
import 'package:sagebible/features/bible/models/bible_models.dart';
import 'package:sagebible/features/bible/providers/bible_provider.dart';
import 'package:sagebible/features/bible/services/bible_repository.dart';
import 'package:sagebible/features/bible/screens/bible_reader_screen.dart';
import 'package:sagebible/features/search/providers/search_history_provider.dart';

/// Search Screen
/// 
/// Search for words or phrases across the entire Bible.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<SearchResult> _searchResults = [];
  List<SearchResult> _allSearchResults = []; // Store all results before filtering
  bool _isSearching = false;
  String _lastQuery = '';
  String? _selectedBook; // Selected book filter

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _allSearchResults = [];
        _lastQuery = '';
        _selectedBook = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _lastQuery = query;
    });

    try {
      final results = ref.read(bibleProvider.notifier).search(query);
      
      // Add to search history
      await ref.read(searchHistoryProvider.notifier).addSearch(query);
      
      if (mounted) {
        setState(() {
          _allSearchResults = results;
          _searchResults = _filterResultsByBook(results);
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search error: $e')),
        );
      }
    }
  }

  List<SearchResult> _filterResultsByBook(List<SearchResult> results) {
    if (_selectedBook == null || _selectedBook == 'All Books') {
      return results;
    }
    return results.where((r) => r.bookName == _selectedBook).toList();
  }

  void _applyBookFilter(String? bookName) {
    setState(() {
      _selectedBook = bookName;
      _searchResults = _filterResultsByBook(_allSearchResults);
    });
  }

  List<String> _getUniqueBooks() {
    final books = _allSearchResults.map((r) => r.bookName).toSet().toList();
    books.sort();
    return ['All Books', ...books];
  }

  @override
  Widget build(BuildContext context) {
    final bibleState = ref.watch(bibleProvider);
    final currentTranslation = bibleState.currentTranslation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Bible'),
        actions: [
          // Translation selector
          PopupMenuButton<BibleTranslation>(
            icon: const Icon(Icons.translate),
            tooltip: 'Change Translation',
            onSelected: (translation) {
              ref.read(bibleProvider.notifier).switchTranslation(translation);
              // Re-search if there was a previous query
              if (_lastQuery.isNotEmpty) {
                _performSearch(_lastQuery);
              }
            },
            itemBuilder: (context) => BibleTranslation.values.map((translation) {
              final isCurrent = translation == currentTranslation;
              return PopupMenuItem(
                value: translation,
                child: Row(
                  children: [
                    if (isCurrent)
                      Icon(Icons.check, color: AppTheme.primaryColor, size: 20)
                    else
                      const SizedBox(width: 20),
                    const SizedBox(width: 12),
                    Text(
                      translation.code,
                      style: TextStyle(
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for words or phrases...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchResults = [];
                                _lastQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onSubmitted: _performSearch,
                  onChanged: (value) {
                    setState(() {}); // Update to show/hide clear button
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Searching in ${currentTranslation.label}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: _buildResultsView(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView() {
    if (_isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Searching...'),
          ],
        ),
      );
    }

    if (_lastQuery.isEmpty) {
      final recentSearches = ref.watch(searchHistoryProvider);
      
      return SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: AppTheme.textLight,
            ),
            const SizedBox(height: 24),
            Text(
              'Search the Bible',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter a word or phrase to find verses',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            
            // Recent searches
            if (recentSearches.isNotEmpty) ...[
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Searches',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Clear History'),
                          content: const Text('Clear all recent searches?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Clear'),
                            ),
                          ],
                        ),
                      );
                      
                      if (confirm == true) {
                        await ref.read(searchHistoryProvider.notifier).clearHistory();
                      }
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: recentSearches.map((search) {
                  return InputChip(
                    avatar: const Icon(Icons.history, size: 18),
                    label: Text(search),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      _searchController.text = search;
                      _performSearch(search);
                    },
                    onDeleted: () {
                      ref.read(searchHistoryProvider.notifier).removeSearch(search);
                    },
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    side: BorderSide(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ],
            
            // Suggestions
            const SizedBox(height: 32),
            Text(
              'Popular Searches',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildSuggestionChip('love'),
                _buildSuggestionChip('faith'),
                _buildSuggestionChip('hope'),
                _buildSuggestionChip('peace'),
                _buildSuggestionChip('joy'),
                _buildSuggestionChip('prayer'),
                _buildSuggestionChip('forgiveness'),
                _buildSuggestionChip('grace'),
              ],
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 80,
                color: AppTheme.textLight,
              ),
              const SizedBox(height: 24),
              Text(
                'No results found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Try different keywords or check your spelling',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Results count and filter
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingSmall,
          ),
          color: AppTheme.primaryColor.withOpacity(0.1),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 16,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                '${_searchResults.length} ${_searchResults.length == 1 ? 'verse' : 'verses'}',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_allSearchResults.length != _searchResults.length)
                Text(
                  ' (${_allSearchResults.length} total)',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              const Spacer(),
              // Book filter dropdown
              if (_allSearchResults.isNotEmpty)
                PopupMenuButton<String>(
                  icon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.filter_list,
                        size: 18,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _selectedBook ?? 'All',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  tooltip: 'Filter by book',
                  onSelected: _applyBookFilter,
                  itemBuilder: (context) {
                    final books = _getUniqueBooks();
                    return books.map((book) {
                      final isSelected = book == (_selectedBook ?? 'All Books');
                      return PopupMenuItem(
                        value: book,
                        child: Row(
                          children: [
                            if (isSelected)
                              Icon(Icons.check, size: 18, color: AppTheme.primaryColor)
                            else
                              const SizedBox(width: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                book,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList();
                  },
                ),
            ],
          ),
        ),

        // Results list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              return _buildResultCard(_searchResults[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionChip(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        _searchController.text = text;
        _performSearch(text);
      },
    );
  }

  Widget _buildResultCard(SearchResult result) {
    // Highlight search term in text
    final query = _lastQuery.toLowerCase();
    final text = result.verseText;
    final lowerText = text.toLowerCase();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BibleReaderScreen(
                bookName: result.bookName,
                chapterNumber: result.chapterNumber,
                highlightVerse: result.verseNumber,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reference
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      result.reference,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Verse text with highlighted search term
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                  ),
                  children: _buildHighlightedText(text, query),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<TextSpan> _buildHighlightedText(String text, String query) {
    if (query.isEmpty) {
      return [TextSpan(text: text)];
    }

    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(query, start);
      if (index == -1) {
        // Add remaining text
        if (start < text.length) {
          spans.add(TextSpan(
            text: text.substring(start),
            style: TextStyle(color: AppTheme.textPrimary),
          ));
        }
        break;
      }

      // Add text before match
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: TextStyle(color: AppTheme.textPrimary),
        ));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: TextStyle(
          backgroundColor: AppTheme.accentColor.withOpacity(0.3),
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ));

      start = index + query.length;
    }

    return spans;
  }
}
