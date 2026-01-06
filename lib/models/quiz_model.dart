import 'package:json_annotation/json_annotation.dart';

part 'quiz_model.g.dart';

@JsonSerializable()
class QuizQuestion {
  final int id;
  final String question_ar;
  final String question_en;
  final List<String> options;
  final int correct_answer_index;
  final String explanation_ar;
  final String explanation_en;

  QuizQuestion({
    required this.id,
    required this.question_ar,
    required this.question_en,
    required this.options,
    required this.correct_answer_index,
    required this.explanation_ar,
    required this.explanation_en,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) =>
      _$QuizQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$QuizQuestionToJson(this);
}

@JsonSerializable()
class DailyTip {
  final int id;
  final String tip_ar;
  final String tip_en;
  final String category_id;

  DailyTip({
    required this.id,
    required this.tip_ar,
    required this.tip_en,
    required this.category_id,
  });

  factory DailyTip.fromJson(Map<String, dynamic> json) =>
      _$DailyTipFromJson(json);

  Map<String, dynamic> toJson() => _$DailyTipToJson(this);
}

@JsonSerializable()
class LearningQuizResponse {
  final List<QuizQuestion>? questions;
  final List<DailyTip>? daily_tips;

  LearningQuizResponse({
    this.questions,
    this.daily_tips,
  });

  factory LearningQuizResponse.fromJson(Map<String, dynamic> json) =>
      _$LearningQuizResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LearningQuizResponseToJson(this);
}
