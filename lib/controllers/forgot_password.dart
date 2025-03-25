import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../utilis/app_constants.dart';

class ForgotPasswordController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> forgotPassword(String email) async {
    try {
      EasyLoading.show(status: 'Please wait');
      await _auth.sendPasswordResetEmail(email: email);
      EasyLoading.dismiss();
      Get.snackbar(
        'Email sent',
        'Email send to this user $email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppConstants.buttonBg,
        colorText: Colors.white,
      );
      Future.delayed(Duration(seconds: 3), () {
        Get.toNamed('/Signin');
      });
    } on FirebaseAuthException catch (e) {
      EasyLoading.dismiss();

      log('Error $e');
      Get.snackbar(
        'Error',
        'Error! Try again',

        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppConstants.buttonBg,
        colorText: Colors.white,
      );
    }
  }
}
