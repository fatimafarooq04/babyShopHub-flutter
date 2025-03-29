class CategoryModel {
  String id;
  final String categoryName;

  CategoryModel({required this.id, required this.categoryName});

  factory CategoryModel.fromMap(Map<String, dynamic> json) {
    return CategoryModel(id: json['id'], categoryName: json['categoryName']);
  }
  Map<String, dynamic> toMap() {
    return {'id': id, 'categoryName': categoryName};
  }
}
