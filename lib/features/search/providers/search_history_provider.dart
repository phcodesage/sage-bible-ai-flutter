import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagebible/features/auth/providers/auth_provider.dart';
import 'package:sagebible/features/search/services/search_history_service.dart';

/// Search History Notifier
class SearchHistoryNotifier extends StateNotifier<List<String>> {
  final SearchHistoryService _service;

  SearchHistoryNotifier(this._service) : super([]) {
    _loadHistory();
  }

  /// Load search history
  void _loadHistory() {
    state = _service.getRecentSearches();
  }

  /// Add search to history
  Future<void> addSearch(String query) async {
    await _service.addSearch(query);
    _loadHistory();
  }

  /// Remove specific search
  Future<void> removeSearch(String query) async {
    await _service.removeSearch(query);
    _loadHistory();
  }

  /// Clear all history
  Future<void> clearHistory() async {
    await _service.clearHistory();
    state = [];
  }
}

/// Provider for SearchHistoryService
final searchHistoryServiceProvider = Provider<SearchHistoryService>((ref) {
  final prefs = ref.watch(storageServiceProvider).prefs;
  return SearchHistoryService(prefs);
});

/// Provider for SearchHistoryNotifier
final searchHistoryProvider = StateNotifierProvider<SearchHistoryNotifier, List<String>>((ref) {
  final service = ref.watch(searchHistoryServiceProvider);
  return SearchHistoryNotifier(service);
});
