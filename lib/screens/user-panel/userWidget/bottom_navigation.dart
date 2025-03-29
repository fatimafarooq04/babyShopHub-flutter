import 'package:babyshop/controllers/userControllers/bottom_nav_controller.dart';
import 'package:babyshop/utilis/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BottomNavController>();

    return Obx(
      () => BottomNavigationBar(
        elevation: 4,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppConstants.buttonBg,
        currentIndex: controller.selectedIndex.value,
        selectedItemColor: Colors.white,
        unselectedItemColor: const Color.fromARGB(123, 255, 255, 255),
        onTap: controller.changeIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Align(
              alignment: Alignment.center,
              child: Icon(Icons.home_outlined),
            ),
            activeIcon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.login_outlined),
            activeIcon: Icon(Icons.login),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
