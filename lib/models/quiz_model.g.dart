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
);

Map<String, dynamic> _$LearningQuizResponseToJson(
  LearningQuizResponse instance,
) => <String, dynamic>{
  'questions': instance.questions,
  'daily_tips': instance.daily_tips,
};
