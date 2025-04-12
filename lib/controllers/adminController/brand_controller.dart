import 'dart:convert';
import 'dart:developer';

import 'package:babyshop/models/brand_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class BrandController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  // image pick
  final ImagePicker picker = ImagePicker();
  RxList<XFile> selectedImage = <XFile>[].obs;
  Future<void> pickImage() async {
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage.add(image);
      update();
    }
  }

  // cloudniary method
  Future<String?> cloudinary(Uint8List img) async {
    final cloudName = 'dfyc5objf';
    final preset = 'imagePreset';
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );
    final request = http.MultipartRequest('Post', url);
    request.fields['upload_preset'] = preset;
    request.files.add(
      http.MultipartFile.fromBytes('file', img, filename: 'brand.jpg'),
    );
    final response = await request.send();
    final resBody = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      final data = json.decode(resBody);
      return data['secure_url'];
    } else {
      log('Cloudinary upload failed: $resBody');
    }
    return '';
  }

  // add brand method
  Future<void> addBrand(String name) async {
    try {
      EasyLoading.show(status: 'Please wait');
      final imgBytes = await selectedImage.first.readAsBytes();
      String? uploadUrl = await cloudinary(imgBytes);
      if (uploadUrl == null) return;
      BrandModel brandModel = BrandModel(id: '', name: name, image: uploadUrl);
      DocumentReference docref = await firestore
          .collection('Brands')
          .add(brandModel.toMap());
      await docref.update({'id': docref.id});
      selectedImage.clear();
      EasyLoading.dismiss();
      fetchBrands();
    } catch (e) {
      EasyLoading.dismiss();

      log('$e');
    }
  }

  RxList<BrandModel> brandList = <BrandModel>[].obs;
  Rx<BrandModel?> selectedBrand = Rx<BrandModel?>(null);
  Future<void> fetchBrands() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await firestore.collection('Brands').get();
      brandList.assignAll(
        snapshot.docs.map((b) => BrandModel.fromMap(b.data())).toList(),
      );
      // log('Brand fetch ${brandList.length}');
    } catch (e) {
      log('Error');
      log('$e');
    }
  }

  Future<void> editData(String id, String name, String existingImage) async {
    try {
      String imageUrl = existingImage;

      if (selectedImage.isNotEmpty) {
        final imgBytes = await selectedImage.first.readAsBytes();
        String? uploadedUrl = await cloudinary(imgBytes);
        if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
          imageUrl = uploadedUrl;
        }
      }

      await firestore.collection('Brands').doc(id).update({
        'brandName': name,
        'brandImage': imageUrl,
      });

      selectedImage.clear();
      fetchBrands(); // Refresh the list
    } catch (e) {
      log('$e');
    }
  }
}
