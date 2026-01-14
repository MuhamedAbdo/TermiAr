import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider extends ChangeNotifier {
  static const String _favoritesKey = 'favorites';
  Set<int> _favoriteCommandIds = {};
  bool _isInitialized = false;

  Set<int> get favoriteCommandIds => _favoriteCommandIds;
  bool get isInitialized => _isInitialized;

  FavoritesProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesList = prefs.getStringList(_favoritesKey) ?? [];
      print('Loading favorites from storage: $favoritesList');
      _favoriteCommandIds = favoritesList.map((id) => int.parse(id)).toSet();
      print('Parsed favorite IDs: $_favoriteCommandIds');
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error loading favorites: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(int commandId) async {
    print('Toggling favorite for command ID: $commandId');
    print('Current favorites before toggle: $_favoriteCommandIds');

    if (_favoriteCommandIds.contains(commandId)) {
      _favoriteCommandIds.remove(commandId);
      print('Removed from favorites');
    } else {
      _favoriteCommandIds.add(commandId);
      print('Added to favorites');
    }

    print('Updated favorites: $_favoriteCommandIds');

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _favoritesKey,
        _favoriteCommandIds.map((id) => id.toString()).toList(),
      );
      print('Saved to storage successfully');
    } catch (e) {
      print('Error saving favorites: $e');
    }

    notifyListeners();
  }

  bool isFavorite(int commandId) {
    return _favoriteCommandIds.contains(commandId);
  }

  Future<void> clearAllFavorites() async {
    print('Clearing all favorites');
    _favoriteCommandIds.clear();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoritesKey);
      print('Cleared from storage successfully');
    } catch (e) {
      print('Error clearing favorites: $e');
    }

    notifyListeners();
  }
}
