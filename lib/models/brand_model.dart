import 'package:babyshop/models/base_model.dart';

class BrandModel extends BaseModel {
  BrandModel({required super.id, required super.name, required super.image});

  factory BrandModel.fromMap(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'],
      name: json['brandName'],
      image: json['brandImage'],
    );
  }
  Map<String, dynamic> toMap() {
    return {'id': id, 'brandName': name, 'brandImage': image};
  }
}
