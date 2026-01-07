import 'package:json_annotation/json_annotation.dart';

part 'command_model.g.dart';

@JsonSerializable()
class CommandModel {
  // نستخدم @JsonKey لإعطاء قيمة افتراضية في حال كان الحقل Null في الـ JSON
  @JsonKey(defaultValue: 0)
  final int id;
  
  @JsonKey(defaultValue: "")
  final String category_id;
  
  @JsonKey(defaultValue: "")
  final String command;
  
  @JsonKey(defaultValue: "")
  final String syntax;
  
  @JsonKey(defaultValue: "")
  final String level;
  
  @JsonKey(defaultValue: "")
  final String name_ar;
  
  @JsonKey(defaultValue: "")
  final String description;
  
  @JsonKey(defaultValue: "")
  final String how_to_use;
  
  @JsonKey(defaultValue: false)
  final bool can_copy;

  CommandModel({
    required this.id,
    required this.category_id,
    required this.command,
    required this.syntax,
    required this.level,
    required this.name_ar,
    required this.description,
    required this.how_to_use,
    required this.can_copy,
  });

  factory CommandModel.fromJson(Map<String, dynamic> json) =>
      _$CommandModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommandModelToJson(this);
}

@JsonSerializable()
class CommandsResponse {
  @JsonKey(defaultValue: [])
  final List<CommandModel> commands;

  CommandsResponse({
    required this.commands,
  });

  factory CommandsResponse.fromJson(Map<String, dynamic> json) =>
      _$CommandsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CommandsResponseToJson(this);
}