import 'dart:async';
import 'dart:developer';

import 'package:babyshop/utilis/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final box = GetStorage();

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      String? uid = box.read('uid');

      if (uid != null && uid.isNotEmpty) {
        log("User is already logged in. UID: $uid");
        Get.offNamed('/mainPage'); 
      } else {
        log("User not logged in.");
        Get.offNamed('/mainPage');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryColor,
      body: Container(child: splashIcon()),
    );
  }

  Widget splashIcon() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(child: Lottie.asset('assets/images/splash-screen.json')),
        Text(
          AppConstants.appName,
          style: TextStyle(
            fontSize: 26,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
