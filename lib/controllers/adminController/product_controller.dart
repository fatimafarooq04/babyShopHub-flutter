import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:babyshop/models/product_model.dart';

class ProductController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxList<XFile> finalImages = <XFile>[].obs;
  final ImagePicker picker = ImagePicker();
  RxList<ProductModel> productsList = <ProductModel>[].obs;

  // Pick image function
  Future<void> pickImage() async {
    final List<XFile> selectedImage = await picker.pickMultiImage();
    if (selectedImage.isNotEmpty) {
      finalImages.assignAll(selectedImage);
    }
  }

  // Upload image to Cloudinary
  Future<String?> imageCloudinary(Uint8List imgBytes) async {
    try {
      final cloudName = 'dfyc5objf';
      final preset = 'imagePreset';
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', url);
      request.fields['upload_preset'] = preset;
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imgBytes,
          filename: 'product_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );

      final response = await request.send();
      final resBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(resBody);
        return data['secure_url'];
      } else {
        log('Cloudinary upload failed: $resBody');
        return null;
      }
    } catch (e) {
      log('Error uploading to Cloudinary: $e');
      return null;
    }
  }

  // Helper method to upload multiple images
  Future<List<String>> _uploadImages(List<XFile> images) async {
    List<String> imageUrls = [];
    for (var image in images) {
      final bytes = await image.readAsBytes();
      String? uploadedImageUrl = await imageCloudinary(bytes);
      if (uploadedImageUrl != null) {
        imageUrls.add(uploadedImageUrl);
      }
    }
    return imageUrls;
  }

  // Add product to Firestore
  Future<void> productAdd(
    String productName,
    String productDescription,
    String productPrice,
    String salePrice,
    String categoryId,
    String brandId,
    RxList<XFile> productImages,
  ) async {
    try {
      EasyLoading.show(status: 'Please wait');
      if (productName.isNotEmpty &&
          productDescription.isNotEmpty &&
          productPrice.isNotEmpty &&
          categoryId.isNotEmpty &&
          brandId.isNotEmpty &&
          productImages.isNotEmpty) {
        List<String> imageUrls = await _uploadImages(productImages);

        ProductModel productModel = ProductModel(
          id: '',
          productName: productName,
          productDescription: productDescription,
          price: productPrice,
          salePrice: salePrice,
          categoryId: categoryId,
          brandId: brandId,
          productImages: imageUrls,
        );

        final docRef = await _firestore
            .collection('products')
            .add(productModel.toMap());

        await _firestore.collection('products').doc(docRef.id).update({
          'id': docRef.id,
        });

        await fetchProducts();
        EasyLoading.dismiss();
        Get.snackbar("Success", "Product added successfully");
      } else {
        EasyLoading.dismiss();
        Get.snackbar('Required', 'All fields are required');
      }
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }

  // Fetch all products
  Future<void> fetchProducts() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('products').get();
      productsList.assignAll(
        snapshot.docs
            .map(
              (fp) => ProductModel.fromMap(fp.data() as Map<String, dynamic>),
            )
            .toList(),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch products: $e');
    }
  }

  // Update product in Firestore
  Future<void> updateProduct(
    String productId,
    String name,
    String description,
    String price,
    String salePrice,
    String categoryId,
    String brandId,
    List<XFile> newImages, {
    bool keepExistingImages = true,
  }) async {
    try {
      EasyLoading.show(status: 'Updating product...');

      // Get the current product
      final currentProduct = productsList.firstWhere((p) => p.id == productId);

      // Upload new images if any
      List<String> newImageUrls = [];
      if (newImages.isNotEmpty) {
        newImageUrls = await _uploadImages(newImages);
      }

      // Prepare the updated product data
      final updatedProduct = ProductModel(
        id: productId,
        productName: name,
        productDescription: description,
        price: price,
        salePrice: salePrice,
        categoryId: categoryId,
        brandId: brandId,
        productImages:
            keepExistingImages
                ? [...currentProduct.productImages, ...newImageUrls]
                : newImageUrls,
      );

      // Update in Firestore
      await _firestore
          .collection('products')
          .doc(productId)
          .update(updatedProduct.toMap());

      // Update local list
      final index = productsList.indexWhere((p) => p.id == productId);
      if (index != -1) {
        productsList[index] = updatedProduct;
        productsList.refresh();
      }
      await fetchProducts();

      EasyLoading.dismiss();
      Get.back(); 
      Get.snackbar('Success', 'Product updated successfully');
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar('Error', 'Failed to update product: ${e.toString()}');
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      EasyLoading.show(status: 'Deleting product...');
      await _firestore.collection('products').doc(productId).delete();

      // Remove from local list
      productsList.removeWhere((p) => p.id == productId);
      productsList.refresh();

      EasyLoading.dismiss();
      Get.snackbar('Success', 'Product deleted successfully');
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar('Error', 'Failed to delete product: $e');
    }
  }
}
