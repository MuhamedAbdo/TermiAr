// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'command_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommandExample _$CommandExampleFromJson(Map<String, dynamic> json) =>
    CommandExample(
      command: json['command'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );

Map<String, dynamic> _$CommandExampleToJson(CommandExample instance) =>
    <String, dynamic>{
      'command': instance.command,
      'description': instance.description,
    };

CommandOption _$CommandOptionFromJson(Map<String, dynamic> json) =>
    CommandOption(
      flag: json['flag'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );

Map<String, dynamic> _$CommandOptionToJson(CommandOption instance) =>
    <String, dynamic>{
      'flag': instance.flag,
      'description': instance.description,
    };

CommandModel _$CommandModelFromJson(Map<String, dynamic> json) => CommandModel(
  id: (json['id'] as num?)?.toInt() ?? 0,
  category_id: json['category_id'] as String? ?? '',
  command: json['command'] as String? ?? '',
  syntax: json['syntax'] as String? ?? '',
  level: json['level'] as String? ?? '',
  name_ar: json['name_ar'] as String? ?? '',
  description: json['description'] as String? ?? '',
  how_to_use: json['how_to_use'] as String? ?? '',
  can_copy: json['can_copy'] as bool? ?? false,
  examples:
      (json['examples'] as List<dynamic>?)
          ?.map((e) => CommandExample.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  options:
      (json['options'] as List<dynamic>?)
          ?.map((e) => CommandOption.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  distros:
      (json['distros'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  risk_level: json['risk_level'] as String? ?? 'low',
  warning: json['warning'] as String? ?? '',
  keywords:
      (json['keywords'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  expected_result: json['expected_result'] as String? ?? '',
  common_errors: json['common_errors'] as String? ?? '',
);

Map<String, dynamic> _$CommandModelToJson(CommandModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category_id': instance.category_id,
      'command': instance.command,
      'syntax': instance.syntax,
      'level': instance.level,
      'name_ar': instance.name_ar,
      'description': instance.description,
      'how_to_use': instance.how_to_use,
      'can_copy': instance.can_copy,
      'examples': instance.examples,
      'options': instance.options,
      'distros': instance.distros,
      'risk_level': instance.risk_level,
      'warning': instance.warning,
      'keywords': instance.keywords,
      'expected_result': instance.expected_result,
      'common_errors': instance.common_errors,
    };

CommandsResponse _$CommandsResponseFromJson(Map<String, dynamic> json) =>
    CommandsResponse(
      commands:
          (json['commands'] as List<dynamic>?)
              ?.map((e) => CommandModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$CommandsResponseToJson(CommandsResponse instance) =>
    <String, dynamic>{'commands': instance.commands};
