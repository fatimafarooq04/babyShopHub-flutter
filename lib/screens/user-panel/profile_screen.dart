import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:babyshop/controllers/adminController/order_controller.dart';
import 'package:babyshop/controllers/authControllers/get_current_user_controller.dart';
import 'package:babyshop/screens/user-panel/userWidget/custombutton.dart';
import 'package:babyshop/screens/user-panel/userWidget/ui_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  OrderController orderController = Get.find<OrderController>();

  GetCurrentUserController currentUserController =
      Get.find<GetCurrentUserController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body:
          currentUserController.userId.isEmpty
              ? Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Custombutton(
                            onPressed: () {
                              Get.toNamed('/Signup');
                            },
                            text: 'Sign Up',
                          ),
                          const SizedBox(width: 10),
                          const Text('Or'),
                          const SizedBox(width: 10),
                          Custombutton(
                            onPressed: () {
                              Get.toNamed('/Signin');
                            },
                            text: 'Sign In',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              : Obx(
                () => Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Column(
                    children: [
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(
                                currentUserController
                                        .currentUserData['profileimg'] ??
                                    '',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  currentUserController
                                          .currentUserData['username'] ??
                                      '',
                                  style: const TextStyle(fontSize: 20),
                                ),
                                Custombutton(
                                  onPressed: () {
                                    editProfile();
                                  },
                                  text: 'Edit profile',
                                  width: 200,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      spacer(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Custombutton(
                              onPressed: () {
                                orderTrack(
                                  currentUserController.currentUserData['id'],
                                );
                                log(
                                  '${currentUserController.currentUserData['id']}',
                                );
                              },
                              text: 'Order track',
                              icon: Icons.checklist_rounded,
                              width: 150,
                            ),
                            spacer(),
                            Custombutton(
                              onPressed: () {
                                orderHistory(
                                  currentUserController.currentUserData['id'],
                                );
                              },
                              text: 'Order history',
                              icon: Icons.history,
                              width: 150,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  void editProfile() async {
    TextEditingController name = TextEditingController(
      text: currentUserController.currentUserData['username'] ?? '',
    );
    // TextEditingController email = TextEditingController(
    //   text: currentUserController.currentUserData['email'] ?? '',
    // );
    TextEditingController pass = TextEditingController(
      text: currentUserController.currentUserData['password'] ?? '',
    );
    TextEditingController num = TextEditingController(
      text: currentUserController.currentUserData['num'] ?? '',
    );
    TextEditingController add = TextEditingController(
      text: currentUserController.currentUserData['address'] ?? '',
    );

    final String? initialImage =
        currentUserController.currentUserData['profileimg'];

    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                spacer(),
                GestureDetector(
                  onTap: () {
                    currentUserController.selectedImage();
                  },
                  child: Obx(() {
                    if (currentUserController.selectImage.isNotEmpty) {
                      return FutureBuilder<Uint8List>(
                        future:
                            currentUserController.selectImage.first
                                .readAsBytes(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircleAvatar(
                              radius: 50,
                              child: CircularProgressIndicator(),
                            );
                          }
                          return CircleAvatar(
                            radius: 50,
                            backgroundImage: MemoryImage(snapshot.data!),
                          );
                        },
                      );
                    } else if (initialImage != null &&
                        initialImage.isNotEmpty) {
                      return CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(initialImage),
                      );
                    } else {
                      return const CircleAvatar(
                        radius: 50,
                        child: Icon(Icons.add_a_photo),
                      );
                    }
                  }),
                ),
                spacer(),
                getTextFormField(name, 'Username'),
                spacer(),
                // getTextFormField(email, 'Email'),
                spacer(),
                getTextFormField(pass, 'Password'),
                spacer(),
                getTextFormField(num, 'Number'),
                spacer(),
                getTextFormField(add, 'Address'),
                spacer(),
                Custombutton(
                  text: "Save",
                  onPressed: () {
                    currentUserController.updateProfile(
                      username: name.text.trim(),
                      // email: email.text.trim(),
                      password: pass.text.trim(),
                      number: num.text.trim(),
                      address: add.text.trim(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void orderTrack(String userId) async {
    // Fetch orders (make sure it's up to date)
    await orderController.fetchOrders();

    // Filter orders by current user ID
    final userOrders =
        orderController.orders
            .where((order) => order['orderData']['userId'] == userId)
            .toList();

    Get.dialog(
      AlertDialog(
        title: const Text('Order Tracking'),
        content:
            userOrders.isEmpty
                ? const Text('No orders found for this user.')
                : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: userOrders.length,
                    itemBuilder: (context, index) {
                      final order = userOrders[index];
                      final statusHistory = List<Map<String, dynamic>>.from(
                        order['orderData']['statusHistory'] ?? [],
                      );
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order ID: ${order['orderId']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Current Status: ${order['orderData']['status'] ?? "Unknown"}',
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Status History:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              ...statusHistory.reversed.toList().asMap().entries.map((
                                entry,
                              ) {
                                final index = entry.key;
                                final statusEntry = entry.value;
                                final status = statusEntry['status'];
                                final timestamp = statusEntry['timestamp'];
                                final date =
                                    timestamp != null
                                        ? (timestamp is Timestamp
                                            ? timestamp.toDate()
                                            : (timestamp is DateTime
                                                ? timestamp
                                                : DateTime.now()))
                                        : DateTime.now();

                                final isCurrent =
                                    index ==
                                    0; // First item after reversing = current

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color:
                                            isCurrent
                                                ? Colors.purple
                                                : Colors.grey,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '$status at ${date.toLocal().toString().split('.')[0]}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color:
                                                isCurrent
                                                    ? Colors.purple
                                                    : Colors.grey,
                                            fontWeight:
                                                isCurrent
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  void orderHistory(String userId) async {
    // Fetch all orders
    await orderController.fetchOrders();

    // Filter completed or cancelled orders for current user
    final historyOrders =
        orderController.orders
            .where(
              (order) =>
                  order['orderData']['userId'] == userId &&
                  (order['orderData']['status'] == 'Delivered' ||
                      order['orderData']['status'] == 'Cancelled'),
            )
            .toList();

    Get.dialog(
      AlertDialog(
        title: const Text('Order History'),
        content:
            historyOrders.isEmpty
                ? const Text('No order history found.')
                : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: historyOrders.length,
                    itemBuilder: (context, index) {
                      final order = historyOrders[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order ID: ${order['orderId']}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('Status: ${order['orderData']['status']}'),
                            Text(
                              'Date: ${order['orderData']['timestamp'] != null ? (order['orderData']['timestamp'] as Timestamp).toDate().toLocal().toString().split(' ')[0] : 'Unknown'}',
                            ),
                            if (order['orderData']['status'] == 'Delivered')
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () {
                                    showProductSelectionDialog(context, order);
                                  },
                                  icon: Icon(Icons.star, color: Colors.purple),
                                  label: const Text("Rate Product"),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  void showProductSelectionDialog(
    BuildContext context,
    Map<String, dynamic> order,
  ) {
    List<dynamic>? products = order['orderData']['cartItems'];

    if (products == null || products.isEmpty) {
      Get.defaultDialog(
        title: "No Products",
        content: const Text("No product found for this order."),
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text("Select Product to Review"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(product['ProductImage'] ?? ''),
                ),
                title: Text(product['ProuductName'] ?? 'Unnamed Product'),
                subtitle: Text("Price: Rs. ${product['Price'] ?? 'N/A'}"),
                trailing: const Icon(Icons.star_border, color: Colors.purple),
                onTap: () {
                  Get.back(); // close dialog
                  showRatingDialog(context, order['orderId'], product);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void showRatingDialog(
    BuildContext context,
    String orderId,
    Map<String, dynamic> product,
  ) {
    double rating = 3;
    TextEditingController reviewController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Rate: ${product['title']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(product['image'], width: 100, height: 100),
            const SizedBox(height: 10),
            StatefulBuilder(
              builder:
                  (context, setState) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          Icons.star,
                          color: index < rating ? Colors.purple : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            rating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
            ),
            TextField(
              controller: reviewController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Write your review...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('product_reviews')
                  .add({
                    'orderId': orderId,
                    'userId': currentUserController.userId,
                    'productId': product['id'],
                    'productTitle': product['title'],
                    'rating': rating,
                    'review': reviewController.text.trim(),
                    'timestamp': Timestamp.now(),
                  });

              Get.back();
              Get.snackbar(
                "Thanks!",
                "Review submitted for ${product['title']}",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green.shade100,
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
