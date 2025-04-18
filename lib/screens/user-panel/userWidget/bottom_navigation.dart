// import 'package:babyshop/controllers/userControllers/bottom_nav_controller.dart';
// import 'package:babyshop/utilis/app_constants.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class BottomNavigation extends StatelessWidget {
//   const BottomNavigation({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<BottomNavController>();

//     return Obx(
//       () => BottomNavigationBar(
//         elevation: 4,
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: AppConstants.buttonBg,
//         currentIndex: controller.selectedIndex.value,
//         selectedItemColor: Colors.white,
//         unselectedItemColor: const Color.fromARGB(123, 255, 255, 255),
//         onTap: controller.changeIndex,
//         items: const [
//           // BottomNavigationBarItem(
//           //   icon: Align(
//           //     alignment: Alignment.center,
//           //     child: Icon(Icons.home_outlined),
//           //   ),
//           //   activeIcon: Icon(Icons.home_filled),
//           //   label: 'Home',
//           // ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.login_outlined),
//             activeIcon: Icon(Icons.login),
//             label: 'product',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.search_outlined),
//             activeIcon: Icon(Icons.search),
//             label: 'Search',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person_outline),
//             activeIcon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.login_outlined),
//             activeIcon: Icon(Icons.login),
//             label: 'Profile',
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:babyshop/controllers/userControllers/bottom_nav_controller.dart';
// import 'package:babyshop/utilis/app_constants.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class BottomNavigation extends StatelessWidget {
//   const BottomNavigation({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<BottomNavController>();

//     return Obx(
//       () => BottomNavigationBar(
//         elevation: 2,
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: AppConstants.buttonBg,
//         currentIndex: controller.selectedIndex.value,
//         selectedItemColor: Colors.white,
//         unselectedItemColor: const Color.fromARGB(123, 255, 255, 255),
//         onTap: controller.changeIndex,
//         items: const [
//           // BottomNavigationBarItem(
//           //   icon: Align(
//           //     alignment: Alignment.center,
//           //     child: Icon(Icons.home_outlined),
//           //   ),
//           //   activeIcon: Icon(Icons.home_filled),
//           //   label: 'Home',
//           // ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.login_outlined),
//             activeIcon: Icon(Icons.login),
//             label: 'product',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.search_outlined),
//             activeIcon: Icon(Icons.search),
//             label: 'Search',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person_outline),
//             activeIcon: Icon(Icons.person),
//             label: 'Profile',
//           ),

//         ],
//       ),
//     );
//   }
// }

import 'package:babyshop/controllers/authControllers/get_current_user_controller.dart';
import 'package:babyshop/controllers/userControllers/bottom_nav_controller.dart';
// import 'package:babyshop/controllers/userControllers/session_controller.dart';
import 'package:babyshop/utilis/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  @override
  Widget build(BuildContext context) {
    GetCurrentUserController currentUserController =
        Get.find<GetCurrentUserController>();
    final controller = Get.find<BottomNavController>();
    // final session = Get.find<SessionController>();

    return Obx(
      () => BottomNavigationBar(
        elevation: 2,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppConstants.buttonBg,
        currentIndex: controller.selectedIndex.value,
        selectedItemColor: Colors.white,
        unselectedItemColor: const Color.fromARGB(123, 255, 255, 255),
        onTap: controller.changeIndex,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'shop',
          ),

          BottomNavigationBarItem(
            icon:
                currentUserController.currentUserData['profileimg'] != null
                    ? CircleAvatar(
                      radius: 14,
                      backgroundImage: NetworkImage(
                        currentUserController.currentUserData['profileimg'],
                      ),
                      backgroundColor: Colors.transparent,
                    )
                    : const Icon(Icons.person),
            activeIcon:
                currentUserController.currentUserData['profileimg'] != null
                    ? CircleAvatar(
                      radius: 14,
                      backgroundImage: NetworkImage(
                        currentUserController.currentUserData['profileimg'] ??
                            '',
                      ),
                      backgroundColor: Colors.transparent,
                    )
                    : const Icon(Icons.person),
          label: currentUserController.currentUserData['username'] != null &&
       currentUserController.currentUserData['username'].toString().isNotEmpty
    ? currentUserController.currentUserData['username']
    : 'Profile',

          ),
        ],
      ),
    );
  }
}
