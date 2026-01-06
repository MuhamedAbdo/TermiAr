import 'package:json_annotation/json_annotation.dart';

part 'command_model.g.dart';

@JsonSerializable()
class CommandModel {
  final int id;
  final String category_id;
  final String command;
  final String syntax;
  final String level;
  final String name_ar;
  final String description;
  final String how_to_use;
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
  final List<CommandModel> commands;

  CommandsResponse({
    required this.commands,
  });

  factory CommandsResponse.fromJson(Map<String, dynamic> json) =>
      _$CommandsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CommandsResponseToJson(this);
}
