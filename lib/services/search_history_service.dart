import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryService {
  static const String _searchHistoryKey = 'search_history';
  static const String _searchSuggestionsKey = 'search_suggestions';
  static const int _maxHistoryItems = 10;
  static const int _maxSuggestions = 5;

  /// Add a search query to history
  Future<void> addSearchQuery(String query) async {
    if (query.trim().isEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();
    final history = await getSearchHistory();
    
    // Remove if already exists to avoid duplicates
    history.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
    
    // Add to front
    history.insert(0, query.trim());
    
    // Keep only the most recent items
    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }
    
    await prefs.setString(_searchHistoryKey, jsonEncode(history));
  }

  /// Get search history
  Future<List<String>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_searchHistoryKey);
    
    if (historyJson == null) return [];
    
    try {
      final List<dynamic> historyList = jsonDecode(historyJson);
      return historyList.cast<String>();
    } catch (e) {
      return [];
    }
  }

  /// Clear search history
  Future<void> clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_searchHistoryKey);
  }

  /// Remove a specific search query from history
  Future<void> removeSearchQuery(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getSearchHistory();
    
    history.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
    
    await prefs.setString(_searchHistoryKey, jsonEncode(history));
  }

  /// Get search suggestions based on current query
  Future<List<String>> getSearchSuggestions(String query) async {
    if (query.trim().isEmpty) return [];
    
    final history = await getSearchHistory();
    final suggestions = <String>[];
    
    final queryLower = query.toLowerCase();
    
    // Find history items that start with the query
    for (final item in history) {
      if (item.toLowerCase().startsWith(queryLower) && 
          item.toLowerCase() != queryLower) {
        suggestions.add(item);
      }
    }
    
    // Find history items that contain the query
    for (final item in history) {
      if (item.toLowerCase().contains(queryLower) && 
          item.toLowerCase() != queryLower &&
          !suggestions.contains(item)) {
        suggestions.add(item);
      }
    }
    
    // Get stored suggestions
    final storedSuggestions = await _getStoredSuggestions();
    for (final suggestion in storedSuggestions) {
      if (suggestion.toLowerCase().contains(queryLower) && 
          suggestion.toLowerCase() != queryLower &&
          !suggestions.contains(suggestion)) {
        suggestions.add(suggestion);
      }
    }
    
    return suggestions.take(_maxSuggestions).toList();
  }

  /// Get popular/common search suggestions
  Future<List<String>> _getStoredSuggestions() async {
    final prefs = await SharedPreferences.getInstance();
    final suggestionsJson = prefs.getString(_searchSuggestionsKey);
    
    if (suggestionsJson == null) {
      // Return default suggestions if none stored
      return [
        'kitchen',
        'bathroom',
        'bedroom',
        'living room',
        'plumbing',
        'electrical',
        'contractor',
        'repair',
        'renovation',
        'maintenance',
      ];
    }
    
    try {
      final List<dynamic> suggestionsList = jsonDecode(suggestionsJson);
      return suggestionsList.cast<String>();
    } catch (e) {
      return [];
    }
  }

  /// Update stored suggestions (could be called when processing search results)
  Future<void> updateStoredSuggestions(List<String> suggestions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_searchSuggestionsKey, jsonEncode(suggestions));
  }
}