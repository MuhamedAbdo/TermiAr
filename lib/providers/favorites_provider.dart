import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider extends ChangeNotifier {
  static const String _favoritesKey = 'favorites';
  static const String _favoritesMetadataKey = 'favorites_metadata';

  Set<int> _favoriteCommandIds = {};
  Map<int, String> _favoriteTags = {};
  Map<int, int> _favoriteDates = {};
  bool _isInitialized = false;

  Set<int> get favoriteCommandIds => _favoriteCommandIds;
  Map<int, String> get favoriteTags => _favoriteTags;
  Map<int, int> get favoriteDates => _favoriteDates;
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

      // Load metadata (tags and timestamps) in a backward-compatible manner
      final metadataRaw = prefs.getString(_favoritesMetadataKey);
      if (metadataRaw != null && metadataRaw.isNotEmpty) {
        try {
          final Map<String, dynamic> decoded = jsonDecode(metadataRaw);
          _favoriteTags = {};
          _favoriteDates = {};
          decoded.forEach((key, val) {
            final id = int.tryParse(key);
            if (id != null && val is Map<String, dynamic>) {
              if (val['tag'] != null && (val['tag'] as String).trim().isNotEmpty) {
                _favoriteTags[id] = (val['tag'] as String).trim();
              }
              if (val['added_at'] != null && val['added_at'] is int) {
                _favoriteDates[id] = val['added_at'] as int;
              }
            }
          });
        } catch (e) {
          debugPrint('Error parsing favorites metadata: $e');
        }
      }
    } catch (e) {
      debugPrint('WEB DEBUG: Error loading favorites: $e');
      _favoriteCommandIds = {};
      _favoriteTags = {};
      _favoriteDates = {};
    } finally {
      _isInitialized = true;
      debugPrint(
        'WEB DEBUG: Initialization complete, favorites count: ${_favoriteCommandIds.length}',
      );
      notifyListeners();
    }
  }

  Future<void> _saveMetadata() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> data = {};
      for (final id in _favoriteCommandIds) {
        data[id.toString()] = {
          if (_favoriteTags.containsKey(id)) 'tag': _favoriteTags[id],
          'added_at': _favoriteDates[id] ?? DateTime.now().millisecondsSinceEpoch,
        };
      }
      await prefs.setString(_favoritesMetadataKey, jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving favorites metadata: $e');
    }
  }

  Future<void> toggleFavorite(int commandId, {String? tag}) async {
    debugPrint('Toggling favorite for command ID: $commandId');

    if (_favoriteCommandIds.contains(commandId)) {
      _favoriteCommandIds.remove(commandId);
      _favoriteTags.remove(commandId);
      _favoriteDates.remove(commandId);
      debugPrint('Removed from favorites');
    } else {
      _favoriteCommandIds.add(commandId);
      _favoriteDates[commandId] = DateTime.now().millisecondsSinceEpoch;
      if (tag != null && tag.trim().isNotEmpty) {
        _favoriteTags[commandId] = tag.trim();
      }
      debugPrint('Added to favorites');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _favoritesKey,
        _favoriteCommandIds.map((id) => id.toString()).toList(),
      );
      await _saveMetadata();
      debugPrint('Saved to storage successfully');
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }

    notifyListeners();
  }

  String? getCommandTag(int commandId) {
    return _favoriteTags[commandId];
  }

  int getCommandAddedDate(int commandId) {
    return _favoriteDates[commandId] ?? 0;
  }

  Future<void> setCommandTag(int commandId, String? tag) async {
    if (!_favoriteCommandIds.contains(commandId)) return;

    if (tag == null || tag.trim().isEmpty) {
      _favoriteTags.remove(commandId);
    } else {
      _favoriteTags[commandId] = tag.trim();
    }

    await _saveMetadata();
    notifyListeners();
  }

  List<String> getAvailableTags() {
    final tags = _favoriteTags.values.toSet().toList();
    tags.sort();
    return tags;
  }

  bool isFavorite(int commandId) {
    return _favoriteCommandIds.contains(commandId);
  }

  Future<void> clearAllFavorites() async {
    debugPrint('Clearing all favorites');
    _favoriteCommandIds.clear();
    _favoriteTags.clear();
    _favoriteDates.clear();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoritesKey);
      await prefs.remove(_favoritesMetadataKey);
      debugPrint('Cleared from storage successfully');
    } catch (e) {
      debugPrint('Error clearing favorites: $e');
    }

    notifyListeners();
  }
}
