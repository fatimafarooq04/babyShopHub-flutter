import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class GetCurrentUserController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Rx<User?> firebaseUser = Rx<User?>(FirebaseAuth.instance.currentUser);
  RxMap<String, dynamic> currentUserData = <String, dynamic>{}.obs;

  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    auth.authStateChanges().listen((User? user) {
      firebaseUser.value = user;
      if (user != null) {
        fetchCurrentUser(user.uid);
        box.write('uid', user.uid);
      } else {
        currentUserData.clear(); // Clear data on logout
      }
    });
  }

  // image picker
  final ImagePicker picker = ImagePicker();
  RxList<XFile> selectImage = <XFile>[].obs;
  void selectedImage() async {
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectImage.add(image);
      update();
    } else {
      selectImage.clear();
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
      http.MultipartFile.fromBytes('file', imgBytes, filename: 'profile.jpg'),
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

  Future<void> fetchCurrentUser(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await firestore.collection('user').doc(userId).get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        currentUserData.value = data; // Store full data
      } else {
        currentUserData.clear(); // No user found
      }
    } catch (e) {
      print('Error fetching user: $e');
    }
  }

  Future<void> updateProfile({
    required String username,
    // required String email,
    required String password,
    required String number,
    required String address,
  }) async {
    try {
      String? imageUrl = currentUserData['profileimg'];

      // If user selected a new image
      if (selectImage.isNotEmpty) {
        Uint8List imgBytes = await selectImage.first.readAsBytes();
        final uploadedUrl = await imageCloudinary(imgBytes);
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        }
      }
      EasyLoading.show(status: 'Please wait');
      await firestore.collection('user').doc(userId).update({
        'username': username,
        // 'email': email,
        'password': password,
        'num': number,
        'address': address,
        'profileimg': imageUrl,
      });
      EasyLoading.dismiss();
      // Refresh local data
      await fetchCurrentUser(userId);

      Get.back(); // Close dialog
      Get.snackbar('Success', 'Profile updated successfully');
      selectImage.clear(); // Clear the selected image
    } catch (e) {
      EasyLoading.dismiss();

      log('Error updating profile: $e');
      Get.snackbar('Error', 'Failed to update profile');
    }
  }

  String get userId => firebaseUser.value?.uid ?? '';
}
