import 'dart:developer';

import 'package:babyshop/controllers/devicetoken_controller.dart';
import 'package:babyshop/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';


  // google signin controller 
class GoogleSigninController extends GetxController {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  final GoogleSignIn googleSignIn = GoogleSignIn(
    signInOption: SignInOption.standard,
    clientId:
        "943196912822-eod54qv62d480gpkg0n584j2gjg6mplt.apps.googleusercontent.com",
  );
//  Method for signin with google 
  Future<void> googleSignInAccount() async {
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithPopup(googleProvider);
      User? user = userCredential.user;
// check if user is not null then signin
      if (user != null) {
        EasyLoading.show(status: 'loading');
        log("Signed in as: ${user.email}");

        //  Call Device Token Controller
        final DevicetokenController devicetokenController =
            Get.find<DevicetokenController>();

        //  Get the device token
        await devicetokenController.getDeviceToken();
        // call model 
        UserModel userModel = UserModel(
          id: user.uid,
          username: user.displayName.toString(),
          email: user.email.toString(),
          password: null,
          role: 'user',
          profileimg:
              user.photoURL ??
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRBGcM6Pr04EvVjbkfVmNnXQoFHU_Y3NxbaNQ&s',
          createdOn: DateTime.now(),
          userDeviceToken: devicetokenController.deviceToken.value,
        );
// add data to database with model 

        await firebaseFirestore
            .collection('user')
            .doc(user.uid)
            .set(userModel.toMap(), SetOptions(merge: true));

        Get.snackbar('Signin', "Sign In successfully");
        EasyLoading.dismiss();
        await Get.toNamed('/mainPage');
      }
    } catch (e) {
      EasyLoading.dismiss();
      log("Google Sign-In Error: $e");
    }
  }

  Future<void> signout() async {
    try {
      await googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
      Get.toNamed('/Signin');
    } catch (e) {
      log('Error $e');
    }
  }
}
