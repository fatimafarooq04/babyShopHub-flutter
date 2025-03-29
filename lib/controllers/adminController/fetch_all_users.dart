import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class FetchAllUsers extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> userList = <Map<String, dynamic>>[].obs;
  RxMap<String, dynamic> selectedUser = <String,dynamic>{}.obs;
  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      QuerySnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('user').get();
      if (userDoc.docs.isEmpty) {
        log('No user found');
      } else {
        userList.assignAll(userDoc.docs.map((doc) => doc.data()).toList());
        log('${userList.length}');
      }
    } catch (e) {
      log('Error $e');
    }
  }
}
