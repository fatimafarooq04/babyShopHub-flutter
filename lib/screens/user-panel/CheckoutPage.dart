import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;
  double totalPrice = 0.0;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments;
    if (args != null) {
      cartItems = List<Map<String, dynamic>>.from(args['cartItems']);
      var userId = args['userId'];

      calculateTotalPrice();
      deleteCartItems(userId);
    }

    fetchUserInfo();
  }

  Future<void> deleteCartItems(String userId) async {
    final firestore = FirebaseFirestore.instance;
    final cartQuery =
        await firestore
            .collection('CartItems')
            .where('UserID', isEqualTo: userId)
            .get();

    for (var doc in cartQuery.docs) {
      await firestore.collection('CartItems').doc(doc.id).delete();
    }

    print("Cart items deleted after being passed to CheckoutPage.");
  }

  Future<void> fetchUserInfo() async {
    if (user != null) {
      final doc =
          await firestore
              .collection("user")
              .doc(user!.uid)
              .get(); // corrected here
      if (doc.exists) {
        final data = doc.data()!;
        print("User Info: $data");
        nameController.text = data['username'] ?? '';
        emailController.text = data['email'] ?? '';
        phoneController.text = data['num'] ?? '';
        addressController.text = data['address'] ?? '';
        setState(() {}); // refresh UI
      } else {
        print("User document does not exist");
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchCartItems() async {
    if (user != null) {
      final querySnapshot =
          await firestore
              .collection('CartItems')
              .where('UserID', isEqualTo: user!.uid)
              .get();

      setState(() {
        cartItems = querySnapshot.docs.map((doc) => doc.data()).toList();
      });
    }
  }

  void calculateTotalPrice() {
    totalPrice = 0.0;
    for (var item in cartItems) {
      double price = double.tryParse(item['Price'].toString()) ?? 0.0;
      int quantity = int.tryParse(item['Quentity'].toString()) ?? 1;
      totalPrice += price * quantity;
    }
  }

  // Future<void> placeOrder() async {
  //   if (user != null) {
  //     await firestore.collection("Orders").add({
  //       "UserID": user!.uid,
  //       "username": nameController.text,
  //       "email": emailController.text,
  //       "phone": phoneController.text,
  //       "address": addressController.text,
  //       "cartItems": cartItems,
  //       "totalPrice": totalPrice,
  //       "createdAt": Timestamp.now(),
  //     });

  //     print("Order placed for user: ${user!.uid}");
  //   }
  // }

  void placeOrder() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null || cartItems.isEmpty) {
      print("User not logged in or cart is empty.");
      return;
    }

    final userId = currentUser.uid;

    // Calculate total price (assuming Price is stored as string and valid number)
    double totalPrice = 0;
    for (var item in cartItems) {
      final price = double.tryParse(item['Price'].toString()) ?? 0;
      final quantity = int.tryParse(item['Quentity'].toString()) ?? 1;
      totalPrice += price * quantity;
    }

    // Create order object with added address and phone fields
    final orderData = {
      'userId': userId,
      'cartItems': cartItems,
      'totalPrice': totalPrice,
      'timestamp': DateTime.now(),
      'status': 'Pending', // Status set to Pending
      'statusHistory': [
        {
          'status': 'Pending',
          'timestamp': DateTime.now(), // Add timestamp here
        },
      ],
      'address': addressController.text, // Add address from the controller
      'phone': phoneController.text, // Add phone from the controller
    };

    try {
      await firestore.collection("Orders").add(orderData);
      Get.toNamed('/mainPage');
      // print("Order placed successfully.");
      // Optional: show confirmation or navigate away
      Get.snackbar("Success", "Order placed successfully");
    } catch (e) {
      // print("Error placing order: $e");
      Get.snackbar("Error", "Failed to place order");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your Information",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Name"),
                    ),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: "Email"),
                    ),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: "Phone"),
                    ),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(labelText: "Address"),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Your Cart",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    ...cartItems.map(
                      (item) => Card(
                        child: ListTile(
                          leading: Image.network(
                            item['ProductImage'],
                            width: 50,
                            height: 50,
                          ),
                          title: Text(item['ProuductName']),
                          subtitle: Text(
                            "Price: ${item['Price']} • Quantity: ${item['Quentity']}",
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Total: \$${totalPrice.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: placeOrder,
                      child: const Text("Place Order"),
                    ),
                  ],
                ),
              ),
    );
  }
}
