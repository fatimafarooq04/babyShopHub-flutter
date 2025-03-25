import 'dart:developer';

import 'package:babyshop/controllers/user_data_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../utilis/app_constants.dart';

class SigninController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<UserCredential?> signInMethod(String email, String password) async {
    try {
      EasyLoading.show(status: 'loading');
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final GetUserDataController userDataController =
          Get.find<GetUserDataController>();
      var userData = await userDataController.getUserData(
        userCredential.user!.uid,
      );
      // log('Fetched userData: $userData');

      if (userCredential.user != null) {
        if (userCredential.user!.emailVerified) {
          if (userData.isNotEmpty && userData[0]['role'] == 'admin') {
            Get.snackbar(
              'Login Successful',
              'Welcome back!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppConstants.buttonBg,
              colorText: Colors.white,
            );
            EasyLoading.dismiss();
            Get.toNamed('/admin');
          } else {
            Get.snackbar(
              'Login Successful',
              'Welcome back!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppConstants.buttonBg,
              colorText: Colors.white,
            );
            EasyLoading.dismiss();
            Get.toNamed('/mainPage');
          }
        } else {
          EasyLoading.dismiss();

          Get.snackbar(
            'Email Not Verified',
            'Please verify your email before logging in.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppConstants.buttonBg,
            colorText: Colors.white,
          );
        }
      } else {
        EasyLoading.dismiss();

        Get.snackbar(
          'Error',
          'Try again',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppConstants.buttonBg,
          colorText: Colors.white,
        );
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        EasyLoading.dismiss();

        Get.snackbar(
          'Error',
          'No user found for this email.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppConstants.buttonBg,
          colorText: Colors.white,
        );
      } else if (e.code == 'invalid-credential') {
        EasyLoading.dismiss();

        Get.snackbar(
          'Error',
          'Incorrect password or email. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppConstants.buttonBg,
          colorText: Colors.white,
        );
      } else {
        EasyLoading.dismiss();

        log('$e.message');
        Get.snackbar(
          'Error',
          e.message ?? 'An unexpected error occurred.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppConstants.buttonBg,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      EasyLoading.dismiss();

      log('Error during login: $e');
      Get.snackbar(
        'Error',
        'Login failed. Please check your credentials.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppConstants.buttonBg,
        colorText: Colors.white,
      );
      return null;
    }
  }
}
