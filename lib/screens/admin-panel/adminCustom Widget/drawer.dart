import 'package:babyshop/controllers/authControllers/get_current_user_controller.dart';
import 'package:babyshop/screens/admin-panel/adminCustom%20Widget/uihelper.dart';
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
                backgroundColor: Colors.grey.shade300,
                backgroundImage: NetworkImage(userController.profileImg.value),
              ),
            ),
            // custom widget
            getListTile(Icons.dashboard, 'Dashboard', () {
              Get.toNamed('/admin');
            }),
            Divider(),
            getListTile(Icons.person, 'Register user', () {
              Get.toNamed('/allUser');
            }),
            Divider(),

            getListTile(Icons.category, 'Category', () {
              Get.toNamed('/category');
            }),
            Divider(),
            getListTile(Icons.production_quantity_limits, 'Product', () {
              Get.toNamed('/product');
            }),
          ],
        ),
      );
    });
  }
}
