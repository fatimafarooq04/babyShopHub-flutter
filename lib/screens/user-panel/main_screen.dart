import 'package:babyshop/controllers/authControllers/get_current_user_controller.dart';
import 'package:babyshop/controllers/authControllers/session_controller.dart';
import 'package:babyshop/screens/user-panel/AllProducts.dart';
import 'package:babyshop/screens/user-panel/profile_screen.dart';
import 'package:babyshop/screens/user-panel/userWidget/appbar.dart';
import 'package:babyshop/utilis/app_constants.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:babyshop/controllers/userControllers/bottom_nav_controller.dart';
import 'package:babyshop/controllers/authControllers/user_data_controller.dart';
import 'package:babyshop/screens/user-panel/home_screen.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:babyshop/screens/user-panel/userWidget/bottom_navigation.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final BottomNavController controller = Get.put(BottomNavController());
  final List<Widget> pages = [HomeScreen(), AllProducts(), ProfileScreen()];
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<String> allCategories = [];
  List<String> filteredCategories = [];
  List<Map<String, String>> filteredBrands = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SessionController sessionController = Get.find<SessionController>();
  GetCurrentUserController currentUserController =
      Get.find<GetCurrentUserController>();

  final List<String> bannerImages = [
    'https://c8.alamy.com/comp/2J81EAN/baby-shop-banner-with-clothes-2J81EAN.jpg',
    'https://static.vecteezy.com/system/resources/thumbnails/049/469/349/small/cute-babywear-and-toys-banner-background-copy-space-plush-bears-onesies-image-backdrop-empty-pure-infant-fashion-parenting-blog-babyhood-concept-composition-top-view-copyspace-photo.jpg',
    'https://d1csarkz8obe9u.cloudfront.net/posterpreviews/baby-shop-flyers-design-template-47cfd3b4f8f77a91549c90ca262bd131.jpg?ts=1640792865',
  ];

  List<Map<String, String>> allBrands = [];

  final TextEditingController searchController = TextEditingController();
  String? uid;
  String? username;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchBrands();
    // print(currentUserController.userId);
  }

  void _fetchCategories() async {
    final snapshot = await _firestore.collection('Category').get();
    final categoryNames =
        snapshot.docs.map((doc) => doc['categoryName'] as String).toList();

    setState(() {
      allCategories = categoryNames;
      filteredCategories = allCategories;
    });
  }

  void _fetchBrands() async {
    final snapshot = await _firestore.collection('Brands').get();
    final brandData =
        snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'name': doc['brandName'] as String,
            'image': doc['brandImage'] as String,
          };
        }).toList();

    setState(() {
      allBrands = brandData;
      filteredBrands = allBrands;
    });
  }

  void filterSearch(String query) {
    setState(() {
      // Filter brands
      filteredBrands =
          allBrands
              .where(
                (brand) =>
                    brand['name']!.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();

      // Filter categories
      filteredCategories =
          allCategories
              .where(
                (category) =>
                    category.toLowerCase().contains(query.toLowerCase()),
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
    return Scaffold(
      appBar: CustomAppBar(selectedIndex: controller.selectedIndex),

      //  AppBar(
      //   backgroundColor: AppConstants.buttonBg,

      //   title: SvgPicture.network(
      //     "https://images.ctfassets.net/dvf03q5b4rnw/6n4pfghgiGacCYkeg5M8Gc/aa0f131417aff2e41c11c963417ba548/babyshop_logo.svg?w=537&h=173&q=80", // SVG image URL
      //     height: 40,
      //     width: 40,
      //   ),
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.home_outlined),
      //       onPressed: () {
      //         controller.selectedIndex.value = 0;
      //         Get.toNamed('/mainPage');
      //       },
      //     ),

      //     StreamBuilder<QuerySnapshot>(
      //       stream:
      //           FirebaseAuth.instance.currentUser != null
      //               ? FirebaseFirestore.instance
      //                   .collection('WishList')
      //                   .where(
      //                     'UserID',
      //                     isEqualTo: FirebaseAuth.instance.currentUser!.uid,
      //                   )
      //                   .snapshots()
      //               : Stream.empty(),
      //       builder: (context, snapshot) {
      //         int itemCount = 0;
      //         if (snapshot.hasData) {
      //           itemCount = snapshot.data!.docs.length;
      //         }

      //         return Stack(
      //           children: [
      //             IconButton(
      //               icon: Icon(Icons.favorite_border),
      //               onPressed: () => _openDrawer('WishList'),
      //             ),
      //             if (itemCount > 0)
      //               Positioned(
      //                 right: 6,
      //                 top: 6,
      //                 child: Container(
      //                   padding: EdgeInsets.all(2),
      //                   decoration: BoxDecoration(
      //                     color: Colors.red,
      //                     borderRadius: BorderRadius.circular(10),
      //                   ),
      //                   constraints: BoxConstraints(
      //                     minWidth: 16,
      //                     minHeight: 16,
      //                   ),
      //                   child: Text(
      //                     '$itemCount',
      //                     style: TextStyle(
      //                       color: Colors.white,
      //                       fontSize: 10,
      //                       fontWeight: FontWeight.bold,
      //                     ),
      //                     textAlign: TextAlign.center,
      //                   ),
      //                 ),
      //               ),
      //           ],
      //         );
      //       },
      //     ),

      //     StreamBuilder<QuerySnapshot>(
      //       stream:
      //           FirebaseAuth.instance.currentUser != null
      //               ? FirebaseFirestore.instance
      //                   .collection('CartItems')
      //                   .where(
      //                     'UserID',
      //                     isEqualTo: FirebaseAuth.instance.currentUser!.uid,
      //                   )
      //                   .snapshots()
      //               : Stream.empty(),
      //       builder: (context, snapshot) {
      //         int itemCount = 0;
      //         if (snapshot.hasData) {
      //           itemCount = snapshot.data!.docs.length;
      //         }

      //         return Stack(
      //           children: [
      //             IconButton(
      //               icon: Icon(Icons.shopping_cart_outlined),
      //               onPressed: () => _openDrawer('cart'),
      //             ),
      //             if (itemCount > 0)
      //               Positioned(
      //                 right: 6,
      //                 top: 6,
      //                 child: Container(
      //                   padding: EdgeInsets.all(2),
      //                   decoration: BoxDecoration(
      //                     color: Colors.red,
      //                     borderRadius: BorderRadius.circular(10),
      //                   ),
      //                   constraints: BoxConstraints(
      //                     minWidth: 16,
      //                     minHeight: 16,
      //                   ),
      //                   child: Text(
      //                     '$itemCount',
      //                     style: TextStyle(
      //                       color: Colors.white,
      //                       fontSize: 10,
      //                       fontWeight: FontWeight.bold,
      //                     ),
      //                     textAlign: TextAlign.center,
      //                   ),
      //                 ),
      //               ),
      //           ],
      //         );
      //       },
      //     ),
      //     Obx(() {
      //       return sessionController.isLoggedIn.value
      //           ? IconButton(
      //             icon: Icon(Icons.logout),
      //             onPressed: () {
      //               sessionController.logout();
      //               FirebaseAuth.instance.signOut();
      //               Get.snackbar(
      //                 'Logged out',
      //                 'You have been signed out.',
      //                 snackPosition: SnackPosition.BOTTOM,
      //                 backgroundColor: AppConstants.buttonBg,
      //                 colorText: Colors.white,
      //               );
      //               Get.toNamed('/Signup');
      //             },
      //           )
      //           : IconButton(
      //             icon: Icon(Icons.person_outline),
      //             onPressed: () {
      //               Future.delayed(Duration(milliseconds: 300), () {
      //                 Get.toNamed('/Signup');
      //               });
      //             },
      //           );
      //     }),
      //   ],
      // ),
      body: Obx(() {
        if (controller.selectedIndex.value == 0) {
          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: searchController,
                    onChanged: filterSearch,
                    decoration: InputDecoration(
                      hintText: 'Search categories...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: 200,
                  child: CarouselSlider(
                    options: CarouselOptions(
                      autoPlay: true,
                      viewportFraction: 1.0,
                      aspectRatio: 16 / 9,
                    ),
                    items:
                        bannerImages.map((imageUrl) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 200,
                            ),
                          );
                        }).toList(),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Top Brands',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  height: 90,
                  child:
                      filteredBrands.isNotEmpty
                          ? ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: filteredBrands.length,
                            itemBuilder: (context, index) {
                              final brand = filteredBrands[index];

                              return GestureDetector(
                                onTap: () {
                                  final brandName = brand['name'];
                                  final brandId =
                                      brand['id']; // will now be available
                                  print(
                                    "Tapped on brand: $brandName (ID: $brandId)",
                                  );
                                  Get.toNamed(
                                    '/BrandsScreen',
                                    arguments: {'brandId': brandId},
                                  );
                                },

                                child: Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  margin: EdgeInsets.only(right: 16.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      brand['image']!,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                          : Center(child: Text("No brands found")),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Browse Categories',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
                FutureBuilder<QuerySnapshot>(
                  future: _firestore.collection('Category').get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No categories found'));
                    }

                    final categories = snapshot.data!.docs;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount:
                          filteredCategories
                              .length, // Use filteredCategories here
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 3 / 4,
                      ),
                      itemBuilder: (context, index) {
                        final categoryName = filteredCategories[index];
                        final category = categories.firstWhere(
                          (category) =>
                              category['categoryName'] == categoryName,
                        );
                        final name = category['categoryName'];
                        final image = category['categoryImage'];
                        final id = category['id'];

                        return Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  image,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.black.withOpacity(0.3),
                                ),
                              ),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    print("Tapped on $name");
                                    print("Tapped on $id");
                                    Get.toNamed(
                                      '/ClothesScreen',
                                      arguments: {'categoryId': id},
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppConstants.buttonBg,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Text(
                                    name,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                SizedBox(height: 20),
              ],
            ),
          );
        } else {
          return pages[controller.selectedIndex.value];
        }
      }),
      bottomNavigationBar: BottomNavigation(),
    );
  }
}
