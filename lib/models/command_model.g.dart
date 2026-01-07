// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'command_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
