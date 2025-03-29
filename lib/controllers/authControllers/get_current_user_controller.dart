import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

// Controller to get current user information when signin

class GetCurrentUserController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Rx<User?> firebaseUser = Rx<User?>(FirebaseAuth.instance.currentUser);
  Rx<String> userName = ''.obs;
  @override
  void onInit() {
    super.onInit();
    auth.authStateChanges().listen((User? user) {
      firebaseUser.value = user;
      if (user != null) {
        fetchCurrentUser(user.uid);
      }
    });
  }

  Future<void> fetchCurrentUser(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await firestore.collection('user').doc(userId).get();
      if (userDoc.exists) {
        userName.value = userDoc['username'] ?? 'No name';
      }
    } catch (e) {
      log('Error $e');
    }
  }

  String get userId => firebaseUser.value?.uid ?? "";
  String get userEmail => firebaseUser.value?.email ?? "No Email";
  dynamic get userProfile => firebaseUser.value?.photoURL ?? "No Picture";
}
