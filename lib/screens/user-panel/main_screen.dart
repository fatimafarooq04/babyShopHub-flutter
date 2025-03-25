import 'package:babyshop/controllers/bottom_nav_controller.dart';
import 'package:babyshop/controllers/google_signin_controller.dart';
import 'package:babyshop/screens/user-panel/home_screen.dart';
import 'package:babyshop/screens/user-panel/profile_screen.dart';
import 'package:babyshop/screens/user-panel/shop_screen.dart';
import 'package:babyshop/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  GoogleSigninController googleSigninController = Get.put(
    GoogleSigninController(),
  );
  final BottomNavController controller = Get.put(BottomNavController());

  final List<Widget> pages = [HomeScreen(), ShopScreen(), ProfileScreen()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Babyshophub')),
      body: Obx(() => pages[controller.selectedIndex.value]),
      bottomNavigationBar: BottomNavigation(),
    );
  }
}
