import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/category_model.dart';
import '../models/command_model.dart';
import '../models/quiz_model.dart';

class DataService {
  static CategoriesResponse? _cachedCategories;
  static CommandsResponse? _cachedCommands;
  static LearningQuizResponse? _cachedQuizData;

  static void clearCache() {
    _cachedCategories = null;
    _cachedCommands = null;
    _cachedQuizData = null;
  }

  static Future<CategoriesResponse> loadCategories() async {
    if (_cachedCategories != null) {
      return _cachedCategories!;
    }

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/categories.json',
      );
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _cachedCategories = CategoriesResponse.fromJson(jsonMap);
      return _cachedCategories!;
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  static Future<CommandsResponse> loadCommands() async {
    if (_cachedCommands != null) {
      return _cachedCommands!;
    }

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/commands_bank.json',
      );
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _cachedCommands = CommandsResponse.fromJson(jsonMap);
      return _cachedCommands!;
    } catch (e) {
      debugPrint('Error loading commands: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      throw Exception('Failed to load commands: $e');
    }
  }

  static Future<LearningQuizResponse> loadQuizData() async {
    if (_cachedQuizData != null) {
      return _cachedQuizData!;
    }

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/learning_quiz.json',
      );
      if (jsonString.isEmpty) {
        _cachedQuizData = LearningQuizResponse(questions: [], daily_tips: []);
        return _cachedQuizData!;
      }
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _cachedQuizData = LearningQuizResponse.fromJson(jsonMap);
      return _cachedQuizData!;
    } catch (e) {
      _cachedQuizData = LearningQuizResponse(questions: [], daily_tips: []);
      return _cachedQuizData!;
    }
  }

  /// تطبيع النصوص للبحث مع معالجة الفروق الإملائية في اللغة العربية وحالات الأحرف الإنجليزية
  static String normalizeText(String input) {
    var text = input.trim().toLowerCase();
    // إزالة التشكيل (الحركات)
    text = text.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');
    // إزالة التطويل (الكشيدة)
    text = text.replaceAll('ـ', '');
    // توحيد أشكال الألف (أ، إ، آ، ٱ -> ا)
    text = text.replaceAll(RegExp(r'[أإآٱ]'), 'ا');
    // توحيد التاء المربوطة والهاء (ة -> ه)
    text = text.replaceAll('ة', 'ه');
    // توحيد الياء والألف المقصورة (ى -> ي)
    text = text.replaceAll('ى', 'ي');
    return text;
  }

  static Future<List<CommandModel>> searchCommands(
    String query, {
    String? categoryId,
    String? distro,
    String? level,
  }) async {
    try {
      final commandsResponse = await loadCommands();
      final allCommands = commandsResponse.commands;

      final normalizedQuery = normalizeText(query);
      final hasQuery = normalizedQuery.isNotEmpty;

      return allCommands.where((command) {
        // 1. تصفية القسم (Category Filter)
        if (categoryId != null &&
            categoryId.isNotEmpty &&
            categoryId != 'all') {
          if (command.category_id != categoryId) return false;
        }

        // 2. تصفية مستوى الصعوبة (Difficulty Level Filter)
        if (level != null && level.isNotEmpty && level != 'all') {
          if (command.level != level) return false;
        }

        // 3. تصفية التوزيعة (Distribution Filter)
        if (distro != null && distro.isNotEmpty && distro != 'all') {
          final normDistroFilter = normalizeText(distro);

          // التحقق من قائمة التوزيعات المحددة في الأمر
          final inDistrosList = command.distros.any((d) {
            final nd = normalizeText(d);
            return nd.contains(normDistroFilter) ||
                nd.contains('universal') ||
                nd.contains('جميع');
          });

          // التحقق من فئة التوزيعة (عائلة دبيان أو ريد هات أو عام)
          bool inDistroFamily = false;
          if (normDistroFilter.contains('debian') ||
              normDistroFilter.contains('دبيان') ||
              normDistroFilter.contains('ubuntu') ||
              normDistroFilter.contains('اوبنتو')) {
            inDistroFamily = command.category_id == 'debian_family' ||
                command.category_id == 'universal';
          } else if (normDistroFilter.contains('redhat') ||
              normDistroFilter.contains('ريد هات') ||
              normDistroFilter.contains('fedora') ||
              normDistroFilter.contains('فيدورا')) {
            inDistroFamily = command.category_id == 'redhat_family' ||
                command.category_id == 'universal';
          } else if (normDistroFilter.contains('universal') ||
              normDistroFilter.contains('مشترك') ||
              normDistroFilter.contains('عام')) {
            inDistroFamily = command.category_id == 'universal';
          }

          if (!inDistrosList && !inDistroFamily) return false;
        }

        // إذا لم يكن هناك نص للبحث، يتم الاكتفاء بالفلاتر
        if (!hasQuery) return true;

        // مطابقة اسم الأمر الإنجليزي (تطابق تام أو جزئي)
        if (normalizeText(command.command).contains(normalizedQuery)) {
          return true;
        }

        // مطابقة الاسم العربي
        if (normalizeText(command.name_ar).contains(normalizedQuery)) {
          return true;
        }

        // مطابقة الوصف
        if (normalizeText(command.description).contains(normalizedQuery)) {
          return true;
        }

        // مطابقة الصياغة
        if (normalizeText(command.syntax).contains(normalizedQuery)) {
          return true;
        }

        // مطابقة كيفية الاستخدام
        if (normalizeText(command.how_to_use).contains(normalizedQuery)) {
          return true;
        }

        // مطابقة الكلمات المفتاحية (Keywords)
        for (final kw in command.keywords) {
          if (normalizeText(kw).contains(normalizedQuery)) return true;
        }

        // مطابقة الخيارات والمعاملات (Options flags & descriptions)
        for (final opt in command.options) {
          if (normalizeText(opt.flag).contains(normalizedQuery) ||
              normalizeText(opt.description).contains(normalizedQuery)) {
            return true;
          }
        }

        // مطابقة الأمثلة العملية (Examples)
        for (final ex in command.examples) {
          if (normalizeText(ex.command).contains(normalizedQuery) ||
              normalizeText(ex.description).contains(normalizedQuery)) {
            return true;
          }
        }

        // مطابقة التوزيعات
        for (final d in command.distros) {
          if (normalizeText(d).contains(normalizedQuery)) return true;
        }

        return false;
      }).toList();
    } catch (e) {
      throw Exception('Failed to search commands: $e');
    }
  }

  static Future<List<CommandModel>> getCommandsByCategory(
    String categoryId,
  ) async {
    try {
      final commandsResponse = await loadCommands();
      final filteredCommands = commandsResponse.commands
          .where((command) => command.category_id == categoryId)
          .toList();

      // Sort commands by level: 'مبتدئ' -> 'متوسط' -> 'متقدم'
      final levelOrder = {'مبتدئ': 1, 'متوسط': 2, 'متقدم': 3};
      filteredCommands.sort((a, b) {
        final levelA = levelOrder[a.level] ?? 999;
        final levelB = levelOrder[b.level] ?? 999;
        return levelA.compareTo(levelB);
      });

      return filteredCommands;
    } catch (e) {
      throw Exception('Failed to get commands by category: $e');
    }
  }
}
