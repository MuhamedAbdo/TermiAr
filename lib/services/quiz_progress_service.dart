import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class QuizProgressService {
  static const String _keyTotalAttempts = 'quiz_total_attempts';
  static const String _keyTotalQuestions = 'quiz_total_questions_answered';
  static const String _keyTotalCorrect = 'quiz_total_correct_answers';
  static const String _keyRecentHistory = 'quiz_recent_history';

  static String _categoryHighScoreKey(String categoryId) => 'quiz_highscore_$categoryId';

  /// جلب أعلى نتيجة لتصنيف معين
  static Future<int> getHighScore(String categoryId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_categoryHighScoreKey(categoryId)) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// حفظ نتيجة جلسة اختبار وتحديث أعلى نتيجة وسجل المحاولات
  /// يعيد true إذا حقق المستخدم رقماً قياسياً جديداً (New High Score)
  static Future<bool> saveQuizResult({
    required String categoryId,
    required String categoryNameAr,
    required int score,
    required int totalQuestions,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. فحص وتحديث أعلى نتيجة
      final currentHigh = prefs.getInt(_categoryHighScoreKey(categoryId)) ?? 0;
      bool isNewHighScore = false;
      if (score > currentHigh) {
        await prefs.setInt(_categoryHighScoreKey(categoryId), score);
        isNewHighScore = true;
      }

      // 2. تحديث العدادات العامة
      final totalAttempts = (prefs.getInt(_keyTotalAttempts) ?? 0) + 1;
      final totalQuestionsAnswered = (prefs.getInt(_keyTotalQuestions) ?? 0) + totalQuestions;
      final totalCorrect = (prefs.getInt(_keyTotalCorrect) ?? 0) + score;

      await prefs.setInt(_keyTotalAttempts, totalAttempts);
      await prefs.setInt(_keyTotalQuestions, totalQuestionsAnswered);
      await prefs.setInt(_keyTotalCorrect, totalCorrect);

      // 3. إضافة المحاولة إلى السجل الحديث (آخر 10 اختبارات)
      final historyRaw = prefs.getString(_keyRecentHistory);
      List<dynamic> historyList = [];
      if (historyRaw != null && historyRaw.isNotEmpty) {
        try {
          historyList = jsonDecode(historyRaw) as List<dynamic>;
        } catch (_) {}
      }

      final newRecord = {
        'category_id': categoryId,
        'category_name_ar': categoryNameAr,
        'score': score,
        'total': totalQuestions,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'is_high_score': isNewHighScore,
      };

      historyList.insert(0, newRecord);
      if (historyList.length > 10) {
        historyList = historyList.sublist(0, 10);
      }

      await prefs.setString(_keyRecentHistory, jsonEncode(historyList));
      return isNewHighScore;
    } catch (_) {
      return false;
    }
  }

  /// إحصائيات عامة للمستخدم
  static Future<Map<String, dynamic>> getOverallStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final totalAttempts = prefs.getInt(_keyTotalAttempts) ?? 0;
      final totalQuestions = prefs.getInt(_keyTotalQuestions) ?? 0;
      final totalCorrect = prefs.getInt(_keyTotalCorrect) ?? 0;

      double accuracy = 0.0;
      if (totalQuestions > 0) {
        accuracy = (totalCorrect / totalQuestions) * 100.0;
      }

      return {
        'total_attempts': totalAttempts,
        'total_questions': totalQuestions,
        'total_correct': totalCorrect,
        'accuracy': accuracy.round(),
      };
    } catch (_) {
      return {
        'total_attempts': 0,
        'total_questions': 0,
        'total_correct': 0,
        'accuracy': 0,
      };
    }
  }

  /// جلب سجل آخر الاختبارات المنجزة
  static Future<List<Map<String, dynamic>>> getRecentHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyRaw = prefs.getString(_keyRecentHistory);
      if (historyRaw != null && historyRaw.isNotEmpty) {
        final List<dynamic> list = jsonDecode(historyRaw);
        return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (_) {}
    return [];
  }

  /// إعادة تعيين وتصفير السجل
  static Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyTotalAttempts);
      await prefs.remove(_keyTotalQuestions);
      await prefs.remove(_keyTotalCorrect);
      await prefs.remove(_keyRecentHistory);
    } catch (_) {}
  }
}

