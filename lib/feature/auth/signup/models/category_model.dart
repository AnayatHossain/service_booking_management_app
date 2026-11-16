class CategoryResponse {
  final int statusCode;
  final bool success;
  final String message;
  final List<CategoryModel> data;

  CategoryResponse({
    required this.statusCode,
    required this.success,
    required this.message,
    required this.data,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      statusCode: json["statusCode"],
      success: json["success"],
      message: json["message"],
      data: (json["data"] as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList(),
    );
  }
}

class CategoryModel {
  final String name;
  final List<SubCategoryModel> subCategories;

  CategoryModel({
    required this.name,
    required this.subCategories,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      name: json["name"] ?? "",
      subCategories: (json["subCategories"] as List)
          .map((e) => SubCategoryModel.fromJson(e))
          .toList(),
    );
  }
}

class SubCategoryModel {
  final String name;

  SubCategoryModel({required this.name});

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      name: json["name"] ?? "",
    );
  }
}
