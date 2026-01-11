import 'package:json_annotation/json_annotation.dart';

part 'quiz_model.g.dart';

@JsonSerializable()
class QuizQuestion {
  @JsonKey(defaultValue: 0)
  final int id;

  @JsonKey(defaultValue: "")
  final String question_ar;

  @JsonKey(defaultValue: "")
  final String question_en;

  @JsonKey(defaultValue: [])
  final List<String> options;

  @JsonKey(defaultValue: 0)
  final int correct_answer_index;

  @JsonKey(defaultValue: "")
  final String explanation_ar;

  @JsonKey(defaultValue: "")
  final String explanation_en;

  @JsonKey(defaultValue: "")
  final String distro;

  QuizQuestion({
    required this.id,
    required this.question_ar,
    required this.question_en,
    required this.options,
    required this.correct_answer_index,
    required this.explanation_ar,
    required this.explanation_en,
    required this.distro,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) =>
      _$QuizQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$QuizQuestionToJson(this);
}

@JsonSerializable()
class DailyTip {
  @JsonKey(defaultValue: 0)
  final int id;

  @JsonKey(defaultValue: "")
  final String tip_ar;

  @JsonKey(defaultValue: "")
  final String tip_en;

  @JsonKey(defaultValue: "")
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
class QuizInfo {
  @JsonKey(defaultValue: "")
  final String title;

  @JsonKey(defaultValue: "")
  final String description;

  @JsonKey(defaultValue: [])
  final List<QuizCategory>? categories;

  @JsonKey(defaultValue: 15)
  final int totalQuestionsPerQuiz;

  QuizInfo({
    required this.title,
    required this.description,
    this.categories,
    required this.totalQuestionsPerQuiz,
  });

  factory QuizInfo.fromJson(Map<String, dynamic> json) =>
      _$QuizInfoFromJson(json);

  Map<String, dynamic> toJson() => _$QuizInfoToJson(this);
}

@JsonSerializable()
class QuizCategory {
  @JsonKey(defaultValue: "")
  final String id;

  @JsonKey(defaultValue: "")
  final String name_ar;

  @JsonKey(defaultValue: "")
  final String name_en;

  QuizCategory({
    required this.id,
    required this.name_ar,
    required this.name_en,
  });

  factory QuizCategory.fromJson(Map<String, dynamic> json) =>
      _$QuizCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$QuizCategoryToJson(this);
}

@JsonSerializable()
class LearningQuizResponse {
  @JsonKey(defaultValue: [])
  final List<QuizQuestion>? questions;

  @JsonKey(defaultValue: [])
  final List<DailyTip>? daily_tips;

  @JsonKey(name: 'quiz_info')
  final QuizInfo? quizInfo;

  LearningQuizResponse({this.questions, this.daily_tips, this.quizInfo});

  factory LearningQuizResponse.fromJson(Map<String, dynamic> json) =>
      _$LearningQuizResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LearningQuizResponseToJson(this);
}
