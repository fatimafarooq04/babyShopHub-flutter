// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';

// class SessionController extends GetxController {

//   final RxBool isLoggedIn = false.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     checkLoginStatus();
//   }

//   void checkLoginStatus() {
//     final box = GetStorage();
//     isLoggedIn.value = box.hasData('uid');
//   }

//   void logout() {
//     final box = GetStorage();
//     box.erase();
//     isLoggedIn.value = false;
//   }

//   void login(String uid) {
//     final box = GetStorage();
//     box.write('uid', uid);
//     isLoggedIn.value = true;
//   }
// }

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SessionController extends GetxController {
  final RxBool isLoggedIn = false.obs;

  final RxString userId = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString userName = ''.obs;
  final RxString userImageUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
    loadSessionData();
  }

  void checkLoginStatus() {
    final box = GetStorage();
    isLoggedIn.value = box.hasData('uid');
  }

  void loadSessionData() {
    final box = GetStorage();

    userId.value = box.read('uid') ?? '';
    userEmail.value = box.read('email') ?? '';
    userName.value = box.read('username') ?? '';
    userImageUrl.value = box.read('profileimg') ?? '';
  }

  void logout() {
    final box = GetStorage();
    box.erase();
    isLoggedIn.value = false;

    // Clear local values
    userId.value = '';
    userEmail.value = '';
    userName.value = '';
    userImageUrl.value = '';
  }

  void login(String uid) {
    final box = GetStorage();
    box.write('uid', uid);
    isLoggedIn.value = true;

    userId.value = uid;
  }

  void printSessionDetails() {
    print(' Session Info:');
    print('UID: ${userId.value}');
    print('Email: ${userEmail.value}');
    print('Username: ${userName.value}');
    print('Profile Image: ${userImageUrl.value}');
    print('Logged In: ${isLoggedIn.value}');
  }

}
