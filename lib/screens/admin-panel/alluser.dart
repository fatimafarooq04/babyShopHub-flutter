import 'package:babyshop/controllers/adminController/fetch_all_users.dart';
import 'package:babyshop/screens/admin-panel/adminCustom%20Widget/drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Alluser extends StatefulWidget {
  const Alluser({super.key});

  @override
  State<Alluser> createState() => _AlluserState();
}

class _AlluserState extends State<Alluser> {
  FetchAllUsers fetchAllUsers = Get.find<FetchAllUsers>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('Users Count: ${fetchAllUsers.userList.length}')),
      ),
      drawer: AppDrawer(),
      body: Obx(
        () =>
            fetchAllUsers.userList.isEmpty
                ? Center(child: Text('No user found'))
                : ListView.builder(
                  itemCount: fetchAllUsers.userList.length,
                  itemBuilder: (context, index) {
                    var user = fetchAllUsers.userList[index];
                    return ListTile(
                      title: Text(user['username'] ?? 'No name'),
                      subtitle: Text(user['email'] ?? 'No Email'),
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      trailing: IconButton(
                        onPressed: () {
                          showModal(user);
                        },
                        icon: Icon(Icons.remove_red_eye),
                      ),
                    );
                  },
                ),
      ),
    );
  }

  void showModal(Map<String, dynamic> user) {
    fetchAllUsers.selectedUser.value = user;

    Get.dialog(
      AlertDialog(
        title: Text('User register info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('User name: ${user["username"]},'),
            Text('email :${user['email']}'),
            Text('email :${user['email']}'),
          ],
        ),
      ),
    );
  }
}
