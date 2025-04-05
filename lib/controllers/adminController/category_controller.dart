import 'dart:convert';
import 'dart:developer';
import 'package:babyshop/models/category_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class Categoryadd extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<CategoryModel> categoryList = <CategoryModel>[].obs;
  // for dropdown category like to fetch category in product page
  Rx<CategoryModel?> selectedCategory = Rx<CategoryModel?>(null);


  // image picker
  final ImagePicker picker = ImagePicker();
  RxList<XFile> selectImage = <XFile>[].obs;
  void selectedImage() async {
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectImage.add(image);
      update();
    }
  }

  //  image to cloudinary
  Future<String?> imageCloudinary(Uint8List imgBytes) async {
    final cloudName = 'dfyc5objf';
    final preset = 'imagePreset';
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );
    final request = http.MultipartRequest('Post', url);
    request.fields['upload_preset'] = preset;
    request.files.add(
      http.MultipartFile.fromBytes('file', imgBytes, filename: 'category.jpg'),
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
  }

  //  Add category and store Firestore ID
Future<void> categoryAdd(String categoryName) async {
  try {
    final imgBytes = await selectImage.first.readAsBytes();
    String? uploadedImageUrl = await imageCloudinary(imgBytes);
    if (uploadedImageUrl == null) return;

    final category = CategoryModel(
      id: '',
      categoryName: categoryName,
      categoryImage: uploadedImageUrl,
    );

    DocumentReference docRef = await _firestore
        .collection('Category')
        .add(category.toMap());

    await docRef.update({'id': docRef.id});
    selectImage.clear();

    fetchCategory();
  } catch (e) {
    log('Error adding category: $e');
  }
}


  // Fetch categories
  Future<void> fetchCategory() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('Category').get();

      categoryList.assignAll(
        snapshot.docs.map((doc) => CategoryModel.fromMap(doc.data())).toList(),
      );

      log("Categories fetched: ${categoryList.length}");
    } catch (e) {
      log('Error fetching categories: $e');
    }
  }

  Future<void> editCategory(String id, String categoryNew,String categoryNewImage ) async {
    try {
      await _firestore.collection('Category').doc(id).update({
        'categoryName': categoryNew,
        'categoryImage':categoryNewImage
      });
      fetchCategory();
    } catch (e) {
      log('Error $e');
    }
  }
}
