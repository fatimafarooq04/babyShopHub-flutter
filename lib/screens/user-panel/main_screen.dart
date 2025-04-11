import 'package:babyshop/controllers/authControllers/get_current_user_controller.dart';
import 'package:babyshop/controllers/authControllers/session_controller.dart';
import 'package:babyshop/screens/user-panel/profile_screen.dart';
import 'package:babyshop/utilis/app_constants.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:babyshop/controllers/userControllers/bottom_nav_controller.dart';
import 'package:babyshop/controllers/authControllers/user_data_controller.dart';
import 'package:babyshop/screens/user-panel/home_screen.dart';
import 'package:get_storage/get_storage.dart';

import 'package:babyshop/screens/user-panel/shop_screen.dart';
import 'package:babyshop/screens/user-panel/userWidget/bottom_navigation.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final BottomNavController controller = Get.put(BottomNavController());

  final List<Widget> pages = [HomeScreen(), ShopScreen(), ProfileScreen()];

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

  final List<Map<String, String>> allBrands = [
    {
      'name': 'pampers',
      'image':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcShRCcZPLCQwHUDHyLu1VOHJ3WwNbePcAU_Sg&s',
    },
    {
      'name': 'baccha party',
      'image':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQy36flaOfx5XH6-8nrR9ynipQc5rbM7XxlsA&s',
    },
    {
      'name': 'bonapapa',
      'image':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQe3bxjfCE_eE-PY1MTRaMyKmGk1OiEz4-wyeotHu06uT51jUHQnBApsTmX0VZNFJRH8KQ&usqp=CAU',
    },
  ];

  final TextEditingController searchController = TextEditingController();
  String? uid;
  String? username;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    filteredBrands = allBrands;
    filteredCategories = allCategories;
    final box = GetStorage();
    uid = box.read('user id is $uid');
    username = box.read('user name is $username');
    print(currentUserController.userId);
    print(currentUserController.userName);
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

  void _openDrawer(String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text(
              type == 'cart'
                  ? 'No item in your cart'
                  : 'No item in your wishlist',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
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
          IconButton(
            icon: Icon(Icons.favorite_border),
            onPressed: () => _openDrawer('wishlist'),
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined),
            onPressed: () => _openDrawer('cart'),
          ),

          // 👇 This is the reactive part
          // AppBar reactive logic
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
                    // controller.selectedIndex.value = 2;  // Update the index
                    // Navigate to the signup page
                    Future.delayed(Duration(milliseconds: 300), () {
                      Get.toNamed(
                        '/Signup',
                      ); // Ensure navigation after index update
                    });
                  },
                );
          }),
        ],
      ),

      // appBar: AppBar(

      //   title: Text('Babyshophub'),
      //   backgroundColor: AppConstants.buttonBg,
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.home_outlined),
      //       onPressed: () {
      //         controller.selectedIndex.value = 0; // Navigate to home
      //         Get.toNamed('/mainPage'); // Navigate to the SignUp page
      //       },
      //     ),
      //     IconButton(
      //       icon: Icon(Icons.favorite_border),
      //       onPressed: () => _openDrawer('wishlist'),
      //     ),
      //     IconButton(
      //       icon: Icon(Icons.shopping_cart_outlined),
      //       onPressed: () => _openDrawer('cart'),
      //     ),
      //     IconButton(
      //       icon: Icon(Icons.person_outline),
      //       onPressed: () {
      //         controller.selectedIndex.value = 2; // Navigate to profile/sign-in
      //         Get.toNamed('/Signup'); // Navigate to the SignUp page
      //       },
      //     ),
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
                              return Card(
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
                        final categoryName =
                            filteredCategories[index]; // Use filteredCategories
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
                                    // print("Tapped on $name");
                                    // print("Tapped on $id");
                                    // Get.toNamed('/ClothesScreen');
                                    Get.toNamed(
                                      '/ClothesScreen',
                                      arguments: {
                                        'categoryId': id,
                                      }, // pass the categoryId
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
