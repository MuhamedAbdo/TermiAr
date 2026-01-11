// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizQuestion _$QuizQuestionFromJson(Map<String, dynamic> json) => QuizQuestion(
  id: (json['id'] as num?)?.toInt() ?? 0,
  question_ar: json['question_ar'] as String? ?? '',
  question_en: json['question_en'] as String? ?? '',
  options:
      (json['options'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  correct_answer_index: (json['correct_answer_index'] as num?)?.toInt() ?? 0,
  explanation_ar: json['explanation_ar'] as String? ?? '',
  explanation_en: json['explanation_en'] as String? ?? '',
  distro: json['distro'] as String? ?? '',
);

Map<String, dynamic> _$QuizQuestionToJson(QuizQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question_ar': instance.question_ar,
      'question_en': instance.question_en,
      'options': instance.options,
      'correct_answer_index': instance.correct_answer_index,
      'explanation_ar': instance.explanation_ar,
      'explanation_en': instance.explanation_en,
      'distro': instance.distro,
    };

DailyTip _$DailyTipFromJson(Map<String, dynamic> json) => DailyTip(
  id: (json['id'] as num?)?.toInt() ?? 0,
  tip_ar: json['tip_ar'] as String? ?? '',
  tip_en: json['tip_en'] as String? ?? '',
  category_id: json['category_id'] as String? ?? '',
);

Map<String, dynamic> _$DailyTipToJson(DailyTip instance) => <String, dynamic>{
  'id': instance.id,
  'tip_ar': instance.tip_ar,
  'tip_en': instance.tip_en,
  'category_id': instance.category_id,
};

QuizInfo _$QuizInfoFromJson(Map<String, dynamic> json) => QuizInfo(
  title: json['title'] as String? ?? '',
  description: json['description'] as String? ?? '',
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => QuizCategory.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  totalQuestionsPerQuiz: (json['totalQuestionsPerQuiz'] as num?)?.toInt() ?? 15,
);

Map<String, dynamic> _$QuizInfoToJson(QuizInfo instance) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'categories': instance.categories,
  'totalQuestionsPerQuiz': instance.totalQuestionsPerQuiz,
};

QuizCategory _$QuizCategoryFromJson(Map<String, dynamic> json) => QuizCategory(
  id: json['id'] as String? ?? '',
  name_ar: json['name_ar'] as String? ?? '',
  name_en: json['name_en'] as String? ?? '',
);

Map<String, dynamic> _$QuizCategoryToJson(QuizCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name_ar': instance.name_ar,
      'name_en': instance.name_en,
    };

LearningQuizResponse _$LearningQuizResponseFromJson(
  Map<String, dynamic> json,
) => LearningQuizResponse(
  questions:
      (json['questions'] as List<dynamic>?)
          ?.map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  daily_tips:
      (json['daily_tips'] as List<dynamic>?)
          ?.map((e) => DailyTip.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  quizInfo: json['quiz_info'] == null
      ? null
      : QuizInfo.fromJson(json['quiz_info'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LearningQuizResponseToJson(
  LearningQuizResponse instance,
) => <String, dynamic>{
  'questions': instance.questions,
  'daily_tips': instance.daily_tips,
  'quiz_info': instance.quizInfo,
};
