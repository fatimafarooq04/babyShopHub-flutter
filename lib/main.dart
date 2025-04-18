import 'package:babyshop/controllers/adminController/brand_controller.dart';
import 'package:babyshop/controllers/adminController/category_controller.dart';
import 'package:babyshop/controllers/adminController/fetch_all_users.dart';
import 'package:babyshop/controllers/adminController/order_controller.dart';
import 'package:babyshop/controllers/adminController/product_controller.dart';
import 'package:babyshop/controllers/authControllers/get_current_user_controller.dart';
import 'package:babyshop/controllers/authControllers/session_controller.dart';
import 'package:babyshop/controllers/userControllers/bottom_nav_controller.dart';
import 'package:babyshop/controllers/devicetoken_controller.dart';
import 'package:babyshop/controllers/authControllers/forgot_password.dart';
import 'package:babyshop/controllers/authControllers/google_signin_controller.dart';
import 'package:babyshop/controllers/authControllers/signin_controller.dart';
import 'package:babyshop/controllers/authControllers/signup_controller.dart';
import 'package:babyshop/controllers/authControllers/user_data_controller.dart';
import 'package:babyshop/firebase_options.dart';
import 'package:babyshop/utilis/app_routes.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage.init(); // for session
  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

  Get.put(SessionController());
  // Initialize the user controller
  Get.put(GoogleSigninController());
  Get.put(SignupController());
  Get.put(SigninController());
  Get.put(ForgotPasswordController());
  Get.put(DevicetokenController());
  Get.put(GetUserDataController());
  Get.put(BottomNavController());
  Get.put(GetCurrentUserController());

  // initialize the admin panel controller
  Get.put(FetchAllUsers());
  Get.put(Categoryadd());
  Get.put(ProductController());
  Get.put(BrandController());
  Get.put(OrderController());

  runApp(DevicePreview(enabled: !kReleaseMode, builder: (context) => MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute: '/',
      getPages: AppRoutes.pages,
      // loader initialize
      builder: EasyLoading.init(),
    );
  }
}
