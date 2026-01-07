import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_model.dart';
import '../services/data_service.dart';

class DailyTipService {
  static const String _lastUpdateKey = 'daily_tip_last_update';
  static const String _shownTipsKey = 'daily_tip_shown_ids';
  static const String _currentTipKey = 'daily_tip_current_id';

  static Future<DailyTip?> getDailyTip() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final quizData = await DataService.loadQuizData();
      
      // Fallback if no tips available
      if (quizData.daily_tips == null || quizData.daily_tips!.isEmpty) {
        return null;
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final lastUpdateStr = prefs.getString(_lastUpdateKey);
      final lastUpdate = lastUpdateStr != null 
          ? DateTime.parse(lastUpdateStr)
          : DateTime(2000); // Very old date for first run

      // If it's a new day, select a new tip
      if (today.isAfter(lastUpdate)) {
        return await _selectNewTip(prefs, quizData.daily_tips!);
      } else {
        // Return the current tip for today
        return await _getCurrentTip(prefs, quizData.daily_tips!);
      }
    } catch (e) {
      print('Error getting daily tip: $e');
      return null;
    }
  }

  static Future<DailyTip?> _selectNewTip(
    SharedPreferences prefs, 
    List<DailyTip> allTips
  ) async {
    // Get list of shown tip IDs
    final shownIdsStr = prefs.getStringList(_shownTipsKey) ?? [];
    final shownIds = shownIdsStr.map((id) => int.tryParse(id) ?? 0).toSet();

    // Get available tips (not shown yet)
    final availableTips = allTips.where((tip) => !shownIds.contains(tip.id)).toList();

    DailyTip selectedTip;
    List<int> newShownIds;

    if (availableTips.isEmpty) {
      // All tips have been shown, reset and shuffle all
      final shuffledTips = List<DailyTip>.from(allTips)..shuffle(Random());
      selectedTip = shuffledTips.first;
      newShownIds = [selectedTip.id];
    } else {
      // Select randomly from available tips
      final random = Random();
      selectedTip = availableTips[random.nextInt(availableTips.length)];
      newShownIds = [...shownIds, selectedTip.id];
    }

    // Save the new state
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    await prefs.setString(_lastUpdateKey, today.toIso8601String());
    await prefs.setStringList(_shownTipsKey, newShownIds.map((id) => id.toString()).toList());
    await prefs.setInt(_currentTipKey, selectedTip.id);

    return selectedTip;
  }

  static Future<DailyTip?> _getCurrentTip(
    SharedPreferences prefs,
    List<DailyTip> allTips
  ) async {
    final currentTipId = prefs.getInt(_currentTipKey);
    if (currentTipId == null) {
      // Fallback: select a random tip
      return _selectNewTip(prefs, allTips);
    }

    try {
      return allTips.firstWhere((tip) => tip.id == currentTipId);
    } catch (e) {
      // Tip not found, select a new one
      return _selectNewTip(prefs, allTips);
    }
  }

  static Future<void> resetDailyTips() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastUpdateKey);
    await prefs.remove(_shownTipsKey);
    await prefs.remove(_currentTipKey);
  }

  static String get fallbackTip => "استكشف خفايا لينكس وطور مهاراتك اليوم!";
}
