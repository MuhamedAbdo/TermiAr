// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'troubleshooting_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TroubleshootingStep _$TroubleshootingStepFromJson(Map<String, dynamic> json) =>
    TroubleshootingStep(
      step_number: (json['step_number'] as num?)?.toInt() ?? 1,
      title: json['title'] as String? ?? '',
      command: json['command'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );

Map<String, dynamic> _$TroubleshootingStepToJson(
  TroubleshootingStep instance,
) => <String, dynamic>{
  'step_number': instance.step_number,
  'title': instance.title,
  'command': instance.command,
  'description': instance.description,
};

TroubleshootingGuide _$TroubleshootingGuideFromJson(
  Map<String, dynamic> json,
) => TroubleshootingGuide(
  id: json['id'] as String? ?? '',
  title_ar: json['title_ar'] as String? ?? '',
  title_en: json['title_en'] as String? ?? '',
  category: json['category'] as String? ?? 'system',
  icon: json['icon'] as String? ?? 'build',
  description_ar: json['description_ar'] as String? ?? '',
  severity: json['severity'] as String? ?? 'info',
  diagnostic_steps:
      (json['diagnostic_steps'] as List<dynamic>?)
          ?.map((e) => TroubleshootingStep.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  solutions:
      (json['solutions'] as List<dynamic>?)
          ?.map((e) => TroubleshootingStep.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  pro_tips:
      (json['pro_tips'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
);

Map<String, dynamic> _$TroubleshootingGuideToJson(
  TroubleshootingGuide instance,
) => <String, dynamic>{
  'id': instance.id,
  'title_ar': instance.title_ar,
  'title_en': instance.title_en,
  'category': instance.category,
  'icon': instance.icon,
  'description_ar': instance.description_ar,
  'severity': instance.severity,
  'diagnostic_steps': instance.diagnostic_steps,
  'solutions': instance.solutions,
  'pro_tips': instance.pro_tips,
};

TroubleshootingResponse _$TroubleshootingResponseFromJson(
  Map<String, dynamic> json,
) => TroubleshootingResponse(
  guides:
      (json['guides'] as List<dynamic>?)
          ?.map((e) => TroubleshootingGuide.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$TroubleshootingResponseToJson(
  TroubleshootingResponse instance,
) => <String, dynamic>{'guides': instance.guides};
