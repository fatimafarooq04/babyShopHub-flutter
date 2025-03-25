import 'package:babyshop/controllers/devicetoken_controller.dart';
import 'package:babyshop/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class SignupController extends GetxController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  // signup function
  Future<UserCredential?> signUp(
    String email,
    String name,
    String password,
  ) async {
    try {
      EasyLoading.show(status: 'Please wait');
      UserCredential credential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      await credential.user!.sendEmailVerification();
      // get device token controller
      final DevicetokenController devicetokenController =
          Get.find<DevicetokenController>();
      // get the device token
      await devicetokenController.getDeviceToken();
      UserModel userModel = UserModel(
        id: credential.user!.uid,
        username: name,
        email: email,
        profileimg:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRBGcM6Pr04EvVjbkfVmNnXQoFHU_Y3NxbaNQ&s',
        userDeviceToken: devicetokenController.deviceToken.value,
        role: 'user',
        password: password,
        createdOn: DateTime.now(),
      );
      _firebaseFirestore
          .collection('user')
          .doc(credential.user!.uid)
          .set(userModel.toMap());
      EasyLoading.dismiss();
      return credential;
    } on FirebaseAuthException {
      EasyLoading.dismiss();
      rethrow;
    }
  }

  // toggle icon password fields var
  var isPasswordVisible = true.obs;
  var isConfirmPasswordVisible = true.obs;

  // signup form validation

  String? validateUsername(String username) {
    if (username.isEmpty) {
      return "Username cannot be empty";
    }
    return null;
  }

  String? validateEmail(String emailValidate) {
    if (emailValidate.isEmpty) {
      return 'Email cannot be empty';
    } else if (!GetUtils.isEmail(emailValidate)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password cannot be empty';
    } else if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String confirmPassword, String Password) {
    if (confirmPassword.isEmpty) {
      return 'Confirm Password cannot be empty';
    } else if (confirmPassword != Password) {
      return 'Passwords do not match';
    }
    return null;
  }
}
