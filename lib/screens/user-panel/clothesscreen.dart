import 'package:babyshop/controllers/authControllers/session_controller.dart';
import 'package:babyshop/controllers/userControllers/bottom_nav_controller.dart';
import 'package:babyshop/utilis/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class ClothesScreen extends StatefulWidget {
  @override
  _ClothesScreenState createState() => _ClothesScreenState();
}

class _ClothesScreenState extends State<ClothesScreen> {
  late String categoryId;
  List<Map<String, dynamic>> allClothes = [];
  List<Map<String, dynamic>> filteredClothes = [];

  final TextEditingController searchController = TextEditingController();
  final BottomNavController controller = Get.put(BottomNavController());
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SessionController sessionController = Get.find<SessionController>();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    categoryId = Get.arguments['categoryId'];
    fetchClothesByCategory();
  }

  Future<void> fetchClothesByCategory() async {
    try {
      final querySnapshot =
          await _firestore
              .collection('products')
              .where('categoryId', isEqualTo: categoryId)
              .get();

      allClothes =
          querySnapshot.docs.map((doc) {
            final productImages = doc['productImages'];
            String imageUrl =
                (productImages is List && productImages.isNotEmpty)
                    ? productImages[0]
                    : (productImages is String)
                    ? productImages
                    : '';

            return {
              'id': doc.id,
              'name': doc['productName'],
              'image': imageUrl,
              'brandId': doc['brandId'],
              'categoryId': doc['categoryId'],
              'price': doc['price'],
              'description': doc['productDescription'],
            };
          }).toList();

      setState(() {
        filteredClothes = allClothes;
      });
    } catch (e) {
      print("Error fetching clothes: $e");
    }
  }

  void filterSearch(String query) {
    setState(() {
      filteredClothes =
          allClothes
              .where(
                (cloth) =>
                    cloth['name'].toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  void _showToast(String message) {
    Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT);
  }

  //function when click on cart product will be add in the CartItems table start

  Future<void> _handleAddToCart(Map<String, dynamic> product) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      Get.toNamed('/Signup');
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
        // Product exists, showToast
        // final doc = existing.docs.first;
        // final currentQty = doc['Quentity'] ?? 1;
        // await doc.reference.update({'Quentity': currentQty + 1});
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

  void _openDrawer(String type) async {
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '₹${totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 10),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
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
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Babyshophub'),
        backgroundColor: AppConstants.buttonBg,
        actions: [
          IconButton(
            icon: Icon(Icons.home_outlined),
            onPressed: () {
              controller.selectedIndex.value = 0;
              Get.toNamed('/mainPage');
            },
          ),
          // IconButton(
          //   icon: Icon(Icons.favorite_border),
          //   onPressed: () => _openDrawer('WishList'),
          // ),
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
                    onPressed: () => _openDrawer('WishList'),
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
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
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
                    onPressed: () => _openDrawer('cart'),
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
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
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
            return sessionController.isLoggedIn.value
                ? IconButton(
                  icon: Icon(Icons.logout),
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
      ),

      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: searchController,
                onChanged: filterSearch,
                decoration: InputDecoration(
                  hintText: 'Search product...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child:
                  filteredClothes.isEmpty
                      ? Center(child: Text("No products found"))
                      : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2 / 3,
                        ),
                        itemCount: filteredClothes.length,
                        itemBuilder: (context, index) {
                          final cloth = filteredClothes[index];
                          return Card(
                            color: Colors.white,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      cloth['image'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Column(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.favorite_border,
                                          color: Colors.black,
                                        ),
                                        onPressed:
                                            () => _handleAddToWishList(cloth),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.shopping_cart,
                                          color: Colors.black,
                                        ),
                                        onPressed:
                                            () => _handleAddToCart(cloth),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      borderRadius: BorderRadius.vertical(
                                        bottom: Radius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      cloth['name'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
