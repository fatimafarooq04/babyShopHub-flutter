import 'package:flutter/material.dart';
import 'package:babyshop/utilis/app_constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("My Profile"),
        backgroundColor: AppConstants.buttonBg,
      ),
      body: Center(
        child: Text(
          "Welcome to your profile!",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
