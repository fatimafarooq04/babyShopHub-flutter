import 'package:babyshop/controllers/authControllers/get_current_user_controller.dart';
import 'package:babyshop/utilis/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final userController = Get.find<GetCurrentUserController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Drawer(
        backgroundColor: const Color.fromARGB(137, 179, 136, 235),
        elevation: 4,
        shadowColor: AppConstants.outline,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text('Username: ${userController.userName}'),
              accountEmail: Text('Email: ${userController.userEmail}'),
              currentAccountPicture: CircleAvatar(
                backgroundImage:
                    userController.userProfile != null
                        ? NetworkImage(userController.userProfile)
                        : null,
                child:
                    userController.firebaseUser.value?.photoURL == null
                        ? Icon(Icons.person, size: 40)
                        : null,
              ),
            ),
            ListTile(
              title: Text('Fetch Register User'),
              onTap: () {
                Get.toNamed('/allUser');
              },
            ),
            ListTile(
              title: Text('Category'),
              onTap: () {
                Get.toNamed('/category');
              },
            ),
          ],
        ),
      );
    });
  }
}
