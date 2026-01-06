import 'package:json_annotation/json_annotation.dart';

part 'category_model.g.dart';

@JsonSerializable()
class CategoryModel {
  final String id;
  final String name_ar;
  final String name_en;
  final String icon;
  final String description;

  CategoryModel({
    required this.id,
    required this.name_ar,
    required this.name_en,
    required this.icon,
    required this.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);
}

@JsonSerializable()
class CategoriesResponse {
  final List<CategoryModel> categories;

  CategoriesResponse({
    required this.categories,
  });

  factory CategoriesResponse.fromJson(Map<String, dynamic> json) =>
      _$CategoriesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CategoriesResponseToJson(this);
}
