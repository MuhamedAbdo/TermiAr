import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/category_model.dart';
import '../models/command_model.dart';
import '../models/quiz_model.dart';

class DataService {
  static Future<CategoriesResponse> loadCategories() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/categories.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      return CategoriesResponse.fromJson(jsonMap);
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  static Future<CommandsResponse> loadCommands() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/commands_bank.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      
      // Log each command ID for debugging
      if (jsonMap['commands'] != null) {
        final commandsList = jsonMap['commands'] as List;
        for (int i = 0; i < commandsList.length; i++) {
          final command = commandsList[i] as Map<String, dynamic>;
          final commandId = command['id'];
          print('Loading command ID: $commandId');
        }
      }
      
      return CommandsResponse.fromJson(jsonMap);
    } catch (e) {
      // More detailed error logging
      print('Error loading commands: $e');
      print('Stack trace: ${StackTrace.current}');
      throw Exception('Failed to load commands: $e');
    }
  }

  static Future<LearningQuizResponse> loadQuizData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/learning_quiz.json');
      if (jsonString.isEmpty) {
        return LearningQuizResponse(
          questions: [],
          daily_tips: [],
        );
      }
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      return LearningQuizResponse.fromJson(jsonMap);
    } catch (e) {
      // Return empty response if file doesn't exist or is empty
      return LearningQuizResponse(
        questions: [],
        daily_tips: [],
      );
    }
  }

  static Future<List<CommandModel>> searchCommands(String query) async {
    try {
      final commandsResponse = await loadCommands();
      final allCommands = commandsResponse.commands;
      
      if (query.isEmpty) {
        return allCommands;
      }
      
      final lowerQuery = query.toLowerCase();
      return allCommands.where((command) {
        return command.command.toLowerCase().contains(lowerQuery) ||
               command.name_ar.toLowerCase().contains(lowerQuery) ||
               command.description.toLowerCase().contains(lowerQuery) ||
               command.syntax.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search commands: $e');
    }
  }

  static Future<List<CommandModel>> getCommandsByCategory(String categoryId) async {
    try {
      final commandsResponse = await loadCommands();
      return commandsResponse.commands
          .where((command) => command.category_id == categoryId)
          .toList();
    } catch (e) {
      throw Exception('Failed to get commands by category: $e');
    }
  }
}
