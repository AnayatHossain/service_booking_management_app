class SkillModel {
  final String name;
  final SubCategoryModel subCategory;

  SkillModel({
    required this.name,
    required this.subCategory,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      name: json['name'] ?? "",
      subCategory: SubCategoryModel.fromJson(json['subCategory'] ?? {}),
    );
  }
}

class SubCategoryModel {
  final String name;

  SubCategoryModel({
    required this.name,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      name: json['name'] ?? "",
    );
  }
}
