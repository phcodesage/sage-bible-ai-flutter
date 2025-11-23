import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Search History Service
/// 
/// Manages recent search queries with local persistence
class SearchHistoryService {
  static const String _keySearchHistory = 'search_history';
  static const int _maxHistoryItems = 10;

  final SharedPreferences _prefs;

  SearchHistoryService(this._prefs);

  /// Get recent searches
  List<String> getRecentSearches() {
    final json = _prefs.getString(_keySearchHistory);
    if (json == null) return [];

    try {
      final List<dynamic> list = jsonDecode(json);
      return list.cast<String>();
    } catch (e) {
      return [];
    }
  }

  /// Add search to history
  Future<void> addSearch(String query) async {
    if (query.trim().isEmpty) return;

    final searches = getRecentSearches();
    
    // Remove if already exists
    searches.remove(query);
    
    // Add to beginning
    searches.insert(0, query);
    
    // Keep only max items
    if (searches.length > _maxHistoryItems) {
      searches.removeRange(_maxHistoryItems, searches.length);
    }
    
    await _saveSearches(searches);
  }

  /// Remove specific search
  Future<void> removeSearch(String query) async {
    final searches = getRecentSearches();
    searches.remove(query);
    await _saveSearches(searches);
  }

  /// Clear all search history
  Future<void> clearHistory() async {
    await _prefs.remove(_keySearchHistory);
  }

  /// Save searches to storage
  Future<void> _saveSearches(List<String> searches) async {
    final json = jsonEncode(searches);
    await _prefs.setString(_keySearchHistory, json);
  }
}
