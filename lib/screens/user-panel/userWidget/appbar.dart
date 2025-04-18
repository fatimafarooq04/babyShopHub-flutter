import 'package:babyshop/controllers/authControllers/get_current_user_controller.dart';
import 'package:babyshop/controllers/authControllers/session_controller.dart';
import 'package:babyshop/controllers/userControllers/bottom_nav_controller.dart';
import 'package:babyshop/screens/user-panel/userWidget/custombutton.dart';
import 'package:babyshop/utilis/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  // final BottomNavController controller;
  final RxInt selectedIndex;

  CustomAppBar({
    // required this.controller,
    required this.selectedIndex,
  });
  final BottomNavController controller = Get.put(BottomNavController());

  // final SessionController sessionController = Get.find<SessionController>();
  GetCurrentUserController currentUserController =
      Get.find<GetCurrentUserController>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showToast(String message) {
    Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT);
  }

  //function when click on cart product will be add in the CartItems table start
  Future<void> _handleAddToCart(Map<String, dynamic> product) async {
    final currentUser = _auth.currentUser;
    print("Product details: $product");
    print("Product ID: ${product['id']}");

    if (currentUser == null) {
      Get.toNamed('/Signup');
      //        final String? productId = product['id']?.toString();

      // if (productId == null || productId!.isEmpty) {
      //   _showToast('Product ID is missing');
      //   return;
      // }
      // Get.toNamed('/Signin', arguments: {'redirect': '/ClothesScreen', 'productId': product['id']});

      return;
    }

    try {
      // Check if product already exists in the cart for this user
      final existing =
          await _firestore
              .collection('CartItems')
              .where('UserID', isEqualTo: currentUser.uid)
              .where(
                'ProuductName',
                isEqualTo: product['name'],
              ) // match by name
              .get();

      if (existing.docs.isNotEmpty) {
        // Product exists, update quantity
        final doc = existing.docs.first;
        final currentQty = doc['Quentity'] ?? 1;
        await doc.reference.update({'Quentity': currentQty + 1});
      } else {
        // Product doesn't exist, add new entry
        await _firestore.collection('CartItems').add({
          'BrandID': product['brandId'],
          'CatID': product['categoryId'],
          'Price': product['price'],
          'ProductImage': product['image'],
          'ProuductName': product['name'],
          'Quentity': 1,
          'UserID': currentUser.uid,
        });
      }

      _showToast("Product added to cart");
    } catch (e) {
      _showToast("Failed to add to cart: $e");
    }
  }
  //function when click on cart product will be add in the CartItems table end

  //function when click on heart product will be add in the Wishlist table  start

  Future<void> _handleAddToWishList(Map<String, dynamic> product) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      Get.toNamed('/Signup');
      return;
    }

    try {
      // Check if product already exists in the cart for this user
      final existing =
          await _firestore
              .collection('WishList')
              .where('UserID', isEqualTo: currentUser.uid)
              .where(
                'ProuductName',
                isEqualTo: product['name'],
              ) // match by name
              .get();

      if (existing.docs.isNotEmpty) {
        _showToast("Product already in the WishliList");
      } else {
        // Product doesn't exist, add new entry
        await _firestore.collection('WishList').add({
          'BrandID': product['brandId'],
          'CatID': product['categoryId'],
          'Price': product['price'],
          'ProductImage': product['image'],
          'ProuductName': product['name'],
          'Quentity': 1,
          'UserID': currentUser.uid,
        });
        _showToast("Product added to Wish List");
      }
    } catch (e) {
      _showToast("Failed to add to Wish List: $e");
    }
  }

  //function when click on heart product will be add in the Wishlist table  end
  void _openDrawer(BuildContext context, String type) async {
    final user = FirebaseAuth.instance.currentUser;

    List<QueryDocumentSnapshot> docs = [];

    if (user != null && (type == 'cart' || type == 'WishList')) {
      final snapshot =
          await FirebaseFirestore.instance
              .collection(type == 'cart' ? 'CartItems' : 'WishList')
              .where('UserID', isEqualTo: user.uid)
              .get();

      docs = snapshot.docs;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        if (user == null || docs.isEmpty) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.5,
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text(
                type == 'cart'
                    ? 'No item in your cart'
                    : 'No item in your WishList',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
          );
        }

        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.5,
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;

                        double price =
                            double.tryParse(data['Price'].toString()) ?? 0.0;
                        int quantity = data['Quentity'] ?? 1;
                        double totalPrice = price * quantity;

                        return ListTile(
                          leading: Image.network(
                            data['ProductImage'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(data['ProuductName']),
                          subtitle:
                              type == 'WishList'
                                  ? null
                                  : Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.remove_circle_outline),
                                        onPressed: () async {
                                          if (quantity > 1) {
                                            quantity--;
                                            totalPrice = price * quantity;
                                            await doc.reference.update({
                                              'Quentity': quantity,
                                              'TotalPrice': totalPrice,
                                            });
                                            final updatedSnapshot =
                                                await FirebaseFirestore.instance
                                                    .collection('CartItems')
                                                    .where(
                                                      'UserID',
                                                      isEqualTo: user!.uid,
                                                    )
                                                    .get();
                                            setState(() {
                                              docs = updatedSnapshot.docs;
                                            });
                                          }
                                        },
                                      ),
                                      Text(
                                        '$quantity',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.add_circle_outline),
                                        onPressed: () async {
                                          quantity++;
                                          totalPrice = price * quantity;
                                          await doc.reference.update({
                                            'Quentity': quantity,
                                            'TotalPrice': totalPrice,
                                          });
                                          final updatedSnapshot =
                                              await FirebaseFirestore.instance
                                                  .collection('CartItems')
                                                  .where(
                                                    'UserID',
                                                    isEqualTo: user!.uid,
                                                  )
                                                  .get();
                                          setState(() {
                                            docs = updatedSnapshot.docs;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                          trailing:
                              type == 'WishList'
                                  ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextButton(
                                        onPressed: () async {
                                          await FirebaseFirestore.instance
                                              .collection('CartItems')
                                              .add({
                                                'UserID': user!.uid,
                                                'ProductImage':
                                                    data['ProductImage'],
                                                'ProuductName':
                                                    data['ProuductName'],
                                                'Price': data['Price'],
                                                'BrandID': data['BrandID'],
                                                'CatID': data['CatID'],
                                                'Quentity': 1,
                                                'TotalPrice':
                                                    double.tryParse(
                                                      data['Price'].toString(),
                                                    ) ??
                                                    0.0,
                                              });

                                          await doc.reference.delete();

                                          final updatedSnapshot =
                                              await FirebaseFirestore.instance
                                                  .collection('WishLish')
                                                  .where(
                                                    'UserID',
                                                    isEqualTo: user.uid,
                                                  )
                                                  .get();

                                          setState(() {
                                            docs = updatedSnapshot.docs;
                                          });
                                        },
                                        child: Text("Move to Cart"),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.green,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.close,
                                          color: Colors.red,
                                        ),
                                        onPressed: () async {
                                          await doc.reference.delete();
                                          setState(() {
                                            docs.removeAt(index);
                                          });
                                        },
                                      ),
                                    ],
                                  )
                                  : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '₹${totalPrice.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      IconButton(
                                        icon: Icon(
                                          Icons.close,
                                          color: Colors.red,
                                        ),
                                        onPressed: () async {
                                          await doc.reference.delete();
                                          setState(() {
                                            docs.removeAt(index);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                        );
                      },
                    ),
                  ),

                  // 🔽 ADDED CHECKOUT BUTTON
                  if (type == 'cart')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final currentUser = FirebaseAuth.instance.currentUser;

                          if (currentUser != null) {
                            final userId = currentUser.uid;
                            final firestore = FirebaseFirestore.instance;

                            // Fetch cart items first
                            final cartQuery =
                                await firestore
                                    .collection('CartItems')
                                    .where('UserID', isEqualTo: userId)
                                    .get();

                            final cartItems =
                                cartQuery.docs
                                    .map((doc) => {'id': doc.id, ...doc.data()})
                                    .toList();

                            // Navigate to checkout page with cart items
                            Get.toNamed(
                              'CheckoutPage',
                              arguments: {
                                'cartItems': cartItems,
                                'userId': userId,
                              },
                            );
                          }
                        },

                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Proceed to Checkout',

                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppConstants.buttonBg,

      title: SvgPicture.network(
        "https://images.ctfassets.net/dvf03q5b4rnw/6n4pfghgiGacCYkeg5M8Gc/aa0f131417aff2e41c11c963417ba548/babyshop_logo.svg?w=537&h=173&q=80", // SVG image URL
        height: 40,
        width: 40,
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.home_outlined),
          onPressed: () {
            controller.selectedIndex.value = 0;
            Get.toNamed('/mainPage');
          },
        ),

        StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseAuth.instance.currentUser != null
                  ? FirebaseFirestore.instance
                      .collection('WishList')
                      .where(
                        'UserID',
                        isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                      )
                      .snapshots()
                  : Stream.empty(),
          builder: (context, snapshot) {
            int itemCount = 0;
            if (snapshot.hasData) {
              itemCount = snapshot.data!.docs.length;
            }

            return Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.favorite_border),
                  onPressed: () => _openDrawer(context, 'WishList'),
                ),
                if (itemCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$itemCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),

        StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseAuth.instance.currentUser != null
                  ? FirebaseFirestore.instance
                      .collection('CartItems')
                      .where(
                        'UserID',
                        isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                      )
                      .snapshots()
                  : Stream.empty(),
          builder: (context, snapshot) {
            int itemCount = 0;
            if (snapshot.hasData) {
              itemCount = snapshot.data!.docs.length;
            }

            return Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.shopping_cart_outlined),
                  onPressed: () => _openDrawer(context, 'cart'),
                ),
                if (itemCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$itemCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        Obx(() {
          return currentUserController.currentUserData.isNotEmpty
              ? IconButton(
                icon: Icon(Icons.logout),
                onPressed: () {
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
              )
              : IconButton(
                icon: Icon(Icons.person_outline),
                onPressed: () {
                  Future.delayed(Duration(milliseconds: 300), () {
                    Get.toNamed('/Signup');
                  });
                },
              );
        }),
      ],
    );
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: BoxConstraints(minWidth: 16, minHeight: 16),
      child: Text(
        '$count',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
