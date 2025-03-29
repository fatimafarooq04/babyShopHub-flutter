import 'dart:async';

import 'package:babyshop/utilis/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // wait for 5 sec navigate to next page
    super.initState();
    Timer(Duration(seconds: 5), () {
      Get.toNamed('/mainPage');
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
