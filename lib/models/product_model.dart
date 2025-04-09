class ProductModel {
  final String id;
  final String productName;
  final String productDescription;
  final String price;
  final String? salePrice;
  final String categoryId;
  final String brandId;
  final List<String> productImages;

  ProductModel({
    required this.id,
    required this.productName,
    required this.productDescription,
    required this.price,
    this.salePrice,
    required this.categoryId,
    required this.brandId,
    required this.productImages,
  });
  factory ProductModel.fromMap(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      productName: json['productName'],
      productDescription: json['productDescription'],
      price: json['price'],
      salePrice: json['salePrice'],
      categoryId: json['categoryId'],
      brandId:json['brandId'],
      productImages: List<String>.from(json['productImages']),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productName': productName,
      'productDescription': productDescription,
      'price': price,
      'salePrice': salePrice,
      'categoryId': categoryId,
      'brandId':brandId,
      'productImages': productImages,
    };
  }
}
