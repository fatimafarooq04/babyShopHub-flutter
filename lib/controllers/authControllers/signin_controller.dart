// import 'dart:developer';

// import 'package:babyshop/controllers/authControllers/user_data_controller.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:get/get.dart';

// import '../../utilis/app_constants.dart';

// // signin controller with email
// class SigninController extends GetxController {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // Method for signin controller
//   Future<UserCredential?> signInMethod(String email, String password) async {
//     try {
//       // loader
//       EasyLoading.show(status: 'loading');
//       // signin with credential
//       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       // get user data controller to check if user exist or not for signin
//       final GetUserDataController userDataController =
//           Get.find<GetUserDataController>();
//       // store id in var
//       var userData = await userDataController.getUserData(
//         userCredential.user!.uid,
//       );
//       // log('Fetched userData: $userData');
//       // check if user is not null
//       if (userCredential.user != null) {
//         // check if email is verfied
//         if (userCredential.user!.emailVerified) {
//           // check if role is admin then go to admin dashboard
//           if (userData.isNotEmpty && userData[0]['role'] == 'admin') {
//             Get.snackbar(
//               'Login Successful',
//               'Welcome back!',
//               snackPosition: SnackPosition.BOTTOM,
//               backgroundColor: AppConstants.buttonBg,
//               colorText: Colors.white,
//             );
//             EasyLoading.dismiss();
//             Get.toNamed('/admin');
//           } else {
//             // by default role is user then go to user panel 
//             Get.snackbar(
//               'Login Successful',
//               'Welcome back!',
//               snackPosition: SnackPosition.BOTTOM,
//               backgroundColor: AppConstants.buttonBg,
//               colorText: Colors.white,
//             );
//             EasyLoading.dismiss();
//             Get.toNamed('/mainPage');
//           }
//         } else {
//           EasyLoading.dismiss();

//           Get.snackbar(
//             'Email Not Verified',
//             'Please verify your email before logging in.',
//             snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: AppConstants.buttonBg,
//             colorText: Colors.white,
//           );
//         }
//       } else {
//         EasyLoading.dismiss();

//         Get.snackbar(
//           'Error',
//           'Try again',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: AppConstants.buttonBg,
//           colorText: Colors.white,
//         );
//       }
//       return userCredential;
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'invalid-email') {
//         EasyLoading.dismiss();

//         Get.snackbar(
//           'Error',
//           'No user found for this email.',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: AppConstants.buttonBg,
//           colorText: Colors.white,
//         );
//       } else if (e.code == 'invalid-credential') {
//         EasyLoading.dismiss();

//         Get.snackbar(
//           'Error',
//           'Incorrect password or email. Please try again.',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: AppConstants.buttonBg,
//           colorText: Colors.white,
//         );
//       } else {
//         EasyLoading.dismiss();

//         log('$e.message');
//         Get.snackbar(
//           'Error',
//           e.message ?? 'An unexpected error occurred.',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: AppConstants.buttonBg,
//           colorText: Colors.white,
//         );
//       }
//     } catch (e) {
//       EasyLoading.dismiss();

//       log('Error during login: $e');
//       Get.snackbar(
//         'Error',
//         'Login failed. Please check your credentials.',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: AppConstants.buttonBg,
//         colorText: Colors.white,
//       );
//       return null;
//     }
//     return null;
//   }
// }



import 'dart:developer';

import 'package:babyshop/controllers/authControllers/session_controller.dart';
import 'package:babyshop/controllers/authControllers/user_data_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../utilis/app_constants.dart';

// signin controller with email
class SigninController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method for signin controller
  Future<UserCredential?> signInMethod(String email, String password) async {
    try {
      // loader
      EasyLoading.show(status: 'loading');
      // signin with credential
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // get user data controller to check if user exist or not for signin
      final GetUserDataController userDataController =
          Get.find<GetUserDataController>();
      final box = GetStorage(); // GetStorage instance

      // store id in var
      var userData = await userDataController.getUserData(
        userCredential.user!.uid,
      );
      // log('Fetched userData: $userData');
      // check if user is not null
      if (userCredential.user != null) {
        // check if email is verfied
        if (userCredential.user!.emailVerified) {
          // check if role is admin then go to admin dashboard
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
            //store values in session for user
Get.find<SessionController>().login(userCredential.user!.uid);
            box.write('uid', userCredential.user!.uid);
            box.write('email', userCredential.user!.email);
            box.write('username', userData[0]['username']); // from Firestore
            box.write('profileimg', userData[0]['profileimg']); // from Firestor
            // ✅ Notify SessionController
            //store values in session for user
            // by default role is user then go to user panel
            Get.snackbar(
              'Login Successful',
              'Welcome back!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppConstants.buttonBg,
              colorText: Colors.white,
            );
            EasyLoading.dismiss();
            // Get.toNamed('/mainPage');
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