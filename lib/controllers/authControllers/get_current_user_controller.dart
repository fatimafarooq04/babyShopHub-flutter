import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class GetCurrentUserController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Rx<User?> firebaseUser = Rx<User?>(FirebaseAuth.instance.currentUser);
  RxString userName = ''.obs;
  RxString profileImg = ''.obs;

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

  Future<List<Map<String, dynamic>>> fetchCurrentUser(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await firestore.collection('user').doc(userId).get();
      print("🔥 Fetching user from Firestore for ID: $userId");

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        print("✅ User Data: $userData");

        userName.value = userData['username'] ?? 'No name';
        profileImg.value = userData['profileimg'] ?? '';

        return [userData];
      }

      print("❌ User not found in Firestore");
      return [];
    } catch (e) {
      log('Error fetching user: $e');
      return [];
    }
  }

  String get userId => firebaseUser.value?.uid ?? "";
  String get userEmail => firebaseUser.value?.email ?? "No Email";
}
