import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider extends ChangeNotifier {
  static const String _favoritesKey = 'favorites';
  Set<int> _favoriteCommandIds = {};
  bool _isInitialized = false;

  Set<int> get favoriteCommandIds => _favoriteCommandIds;
  bool get isInitialized => _isInitialized;

  FavoritesProvider() {
    Future.microtask(() => _loadFavorites());
  }

  Future<void> _loadFavorites() async {
    try {
      debugPrint('WEB DEBUG: Starting favorites initialization');
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('WEB DEBUG: SharedPreferences timeout - using empty favorites');
          throw Exception('SharedPreferences timeout');
        },
      );
      final favoritesList = prefs.getStringList(_favoritesKey) ?? [];
      debugPrint('Loading favorites from storage: $favoritesList');
      _favoriteCommandIds = favoritesList.map((id) => int.parse(id)).toSet();
      debugPrint('Parsed favorite IDs: $_favoriteCommandIds');
    } catch (e) {
      debugPrint('WEB DEBUG: Error loading favorites: $e');
      _favoriteCommandIds = {};
    } finally {
      _isInitialized = true;
      debugPrint(
        'WEB DEBUG: Initialization complete, favorites count: ${_favoriteCommandIds.length}',
      );
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(int commandId) async {
    debugPrint('Toggling favorite for command ID: $commandId');
    debugPrint('Current favorites before toggle: $_favoriteCommandIds');

    if (_favoriteCommandIds.contains(commandId)) {
      _favoriteCommandIds.remove(commandId);
      debugPrint('Removed from favorites');
    } else {
      _favoriteCommandIds.add(commandId);
      debugPrint('Added to favorites');
    }

    debugPrint('Updated favorites: $_favoriteCommandIds');

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _favoritesKey,
        _favoriteCommandIds.map((id) => id.toString()).toList(),
      );
      debugPrint('Saved to storage successfully');
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }

    notifyListeners();
  }

  bool isFavorite(int commandId) {
    return _favoriteCommandIds.contains(commandId);
  }

  Future<void> clearAllFavorites() async {
    debugPrint('Clearing all favorites');
    _favoriteCommandIds.clear();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoritesKey);
      debugPrint('Cleared from storage successfully');
    } catch (e) {
      debugPrint('Error clearing favorites: $e');
    }

    notifyListeners();
  }
}
