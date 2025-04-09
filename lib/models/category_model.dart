// class CategoryModel {
//   String id;
//   final String categoryName;
//   final String categoryImage;

//   CategoryModel({
//     required this.id,
//     required this.categoryName,
//     required this.categoryImage,
//   });

// factory CategoryModel.fromMap(Map<String, dynamic> json) {
//   return CategoryModel(
//     id: json['id'],
//     categoryName: json['categoryName'],
//     categoryImage: json['categoryImage'],
//   );
// }
// Map<String, dynamic> toMap() {
//   return {
//     'id': id,
//     'categoryName': categoryName,
//     'categoryImage': categoryImage,
//   };
// }
// }

import 'package:babyshop/models/base_model.dart';

class CategoryModel extends BaseModel {
  CategoryModel({required super.id, required super.name, required super.image});

  factory CategoryModel.fromMap(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['categoryName'],
      image: json['categoryImage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'categoryName': name, 'categoryImage': image};
  }
}
