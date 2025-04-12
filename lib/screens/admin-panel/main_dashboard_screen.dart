import 'package:babyshop/controllers/authControllers/session_controller.dart';
import 'package:babyshop/screens/admin-panel/adminCustom%20Widget/drawer.dart';
import 'package:babyshop/utilis/app_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  SessionController sessionController = Get.find<SessionController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.buttonBg,
        title: const Text(
          'Admin Panel',
          style: TextStyle(color: Colors.white, fontSize: 26),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              sessionController.logout();
              FirebaseAuth.instance.signOut();

              Get.snackbar(
                'Logged out',
                'You have been signed out.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppConstants.buttonBg,
                colorText: Colors.white,
              );
              Get.toNamed('/Signup');
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      drawer: const AppDrawer(),
    );
  }
}
