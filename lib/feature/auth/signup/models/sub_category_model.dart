class SubCategoryResponse {
  final int statusCode;
  final bool success;
  final String message;
  final List<SubCategory> data;

  SubCategoryResponse({
    required this.statusCode,
    required this.success,
    required this.message,
    required this.data,
  });

  factory SubCategoryResponse.fromJson(Map<String, dynamic> json) {
    return SubCategoryResponse(
      statusCode: json["statusCode"],
      success: json["success"],
      message: json["message"],
      data: (json["data"] as List)
          .map((item) => SubCategory.fromJson(item))
          .toList(),
    );
  }
}

class SubCategory {
  final String name;
  final List<Skill> skills;

  SubCategory({
    required this.name,
    required this.skills,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      name: json["name"] ?? "",
      skills: (json["skills"] as List)
          .map((skill) => Skill.fromJson(skill))
          .toList(),
    );
  }
}

class Skill {
  final String name;

  Skill({
    required this.name,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      name: json["name"] ?? "",
    );
  }
}
