// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

part 'command_model.g.dart';

@JsonSerializable()
class CommandExample {
  @JsonKey(defaultValue: "")
  final String command;

  @JsonKey(defaultValue: "")
  final String description;

  CommandExample({
    required this.command,
    required this.description,
  });

  factory CommandExample.fromJson(Map<String, dynamic> json) =>
      _$CommandExampleFromJson(json);

  Map<String, dynamic> toJson() => _$CommandExampleToJson(this);
}

@JsonSerializable()
class CommandOption {
  @JsonKey(defaultValue: "")
  final String flag;

  @JsonKey(defaultValue: "")
  final String description;

  CommandOption({
    required this.flag,
    required this.description,
  });

  factory CommandOption.fromJson(Map<String, dynamic> json) =>
      _$CommandOptionFromJson(json);

  Map<String, dynamic> toJson() => _$CommandOptionToJson(this);
}

@JsonSerializable()
class CommandModel {
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

  @JsonKey(defaultValue: [])
  final List<CommandExample> examples;

  @JsonKey(defaultValue: [])
  final List<CommandOption> options;

  @JsonKey(defaultValue: [])
  final List<String> distros;

  @JsonKey(defaultValue: "low")
  final String risk_level; // low, moderate, high

  @JsonKey(defaultValue: "")
  final String warning;

  @JsonKey(defaultValue: [])
  final List<String> keywords;

  @JsonKey(defaultValue: "")
  final String expected_result;

  @JsonKey(defaultValue: "")
  final String common_errors;

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
    this.examples = const [],
    this.options = const [],
    this.distros = const [],
    this.risk_level = "low",
    this.warning = "",
    this.keywords = const [],
    this.expected_result = "",
    this.common_errors = "",
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
