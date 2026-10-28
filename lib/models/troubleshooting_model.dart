// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

part 'troubleshooting_model.g.dart';

@JsonSerializable()
class TroubleshootingStep {
  @JsonKey(defaultValue: 1)
  final int step_number;

  @JsonKey(defaultValue: "")
  final String title;

  @JsonKey(defaultValue: "")
  final String command;

  @JsonKey(defaultValue: "")
  final String description;

  TroubleshootingStep({
    required this.step_number,
    required this.title,
    required this.command,
    required this.description,
  });

  factory TroubleshootingStep.fromJson(Map<String, dynamic> json) =>
      _$TroubleshootingStepFromJson(json);

  Map<String, dynamic> toJson() => _$TroubleshootingStepToJson(this);
}

@JsonSerializable()
class TroubleshootingGuide {
  @JsonKey(defaultValue: "")
  final String id;

  @JsonKey(defaultValue: "")
  final String title_ar;

  @JsonKey(defaultValue: "")
  final String title_en;

  @JsonKey(defaultValue: "system")
  final String category;

  @JsonKey(defaultValue: "build")
  final String icon;

  @JsonKey(defaultValue: "")
  final String description_ar;

  @JsonKey(defaultValue: "info")
  final String severity;

  @JsonKey(defaultValue: [])
  final List<TroubleshootingStep> diagnostic_steps;

  @JsonKey(defaultValue: [])
  final List<TroubleshootingStep> solutions;

  @JsonKey(defaultValue: [])
  final List<String> pro_tips;

  TroubleshootingGuide({
    required this.id,
    required this.title_ar,
    required this.title_en,
    required this.category,
    required this.icon,
    required this.description_ar,
    this.severity = "info",
    this.diagnostic_steps = const [],
    this.solutions = const [],
    this.pro_tips = const [],
  });

  factory TroubleshootingGuide.fromJson(Map<String, dynamic> json) =>
      _$TroubleshootingGuideFromJson(json);

  Map<String, dynamic> toJson() => _$TroubleshootingGuideToJson(this);
}

@JsonSerializable()
class TroubleshootingResponse {
  @JsonKey(defaultValue: [])
  final List<TroubleshootingGuide> guides;

  TroubleshootingResponse({
    required this.guides,
  });

  factory TroubleshootingResponse.fromJson(Map<String, dynamic> json) =>
      _$TroubleshootingResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TroubleshootingResponseToJson(this);
}

