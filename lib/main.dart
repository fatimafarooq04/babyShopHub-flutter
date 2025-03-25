import 'package:babyshop/controllers/bottom_nav_controller.dart';
import 'package:babyshop/controllers/devicetoken_controller.dart';
import 'package:babyshop/controllers/forgot_password.dart';
import 'package:babyshop/controllers/google_signin_controller.dart';
import 'package:babyshop/controllers/signin_controller.dart';
import 'package:babyshop/controllers/signup_controller.dart';
import 'package:babyshop/controllers/user_data_controller.dart';
import 'package:babyshop/firebase_options.dart';
import 'package:babyshop/utilis/app_routes.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // create instances for controller
  Get.put(GoogleSigninController());
  Get.put(SignupController());
  Get.put(SigninController());
  Get.put(ForgotPasswordController());
  Get.put(DevicetokenController());
  Get.put(GetUserDataController());
  Get.put(BottomNavController());
  runApp(DevicePreview(enabled: !kReleaseMode, builder: (context) => MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(primarySwatch: Colors.pink),
      initialRoute: '/',
      getPages: AppRoutes.pages,
      builder: EasyLoading.init(),
    );
  }
}
