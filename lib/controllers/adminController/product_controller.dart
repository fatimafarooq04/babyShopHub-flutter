import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:babyshop/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ProductController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxList<XFile> finalImages = <XFile>[].obs;

  final ImagePicker picker = ImagePicker();

  // Pick image function
  Future<void> pickImage() async {
    // Select multiple images
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
          filename: 'category_${DateTime.now().millisecondsSinceEpoch}.jpg',
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
        List<String> imageUrls = [];

        // Upload each image to Cloudinary
        for (var image in productImages) {
          final bytes = await image.readAsBytes();
          String? uploadedImageUrl = await imageCloudinary(bytes);

          if (uploadedImageUrl == null) {
            return;
          }

          imageUrls.add(uploadedImageUrl);
        }

        // Create the product model
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

        // Save the product to Firestore
        final docRef = await _firestore
            .collection('products')
            .add(productModel.toMap());

        // Update the ID in Firestore document
        await _firestore.collection('products').doc(docRef.id).update({
          'id': docRef.id,
        });
        EasyLoading.dismiss();
        Get.snackbar("Success", "Product uploaded successfully");
      } else {
        EasyLoading.dismiss();

        Get.snackbar('Required', 'All fields are required');
      }
    } catch (e) {
      EasyLoading.dismiss();

      log('Error: $e');
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }

  RxList<ProductModel> productsList = <ProductModel>[].obs;
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
      log('${productsList.length}');
    } catch (e) {
      log('$e');
    }
  }
}
