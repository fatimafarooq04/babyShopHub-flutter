
import 'package:babyshop/controllers/userControllers/bottom_nav_controller.dart';
import 'package:babyshop/utilis/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  void initState() {
    super.initState();
    categoryId = Get.arguments['categoryId'];
    print("Fetching for categoryId: '$categoryId'");
    fetchClothesByCategory();
  }

  Future<void> fetchClothesByCategory() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('categoryId', isEqualTo: categoryId)
          .get();

      print("Found documents: ${querySnapshot.docs.length}");

      allClothes = querySnapshot.docs.map((doc) {
        final productImages = doc['productImages'];
        String imageUrl = '';
        if (productImages is List && productImages.isNotEmpty) {
          imageUrl = productImages[0];
        } else if (productImages is String) {
          imageUrl = productImages;
        }

        return {
          'name': doc['productName'],
          'image': imageUrl,
          'id': doc.id,
        };
      }).toList();

      setState(() {
        filteredClothes = allClothes;
      });

      if (querySnapshot.docs.isEmpty) {
        print("No products found for this category. Trying fallback fetch...");

        // Fallback test fetch for all products (optional)
        final fallbackSnapshot = await FirebaseFirestore.instance
            .collection('product')
            .get();
        print("Fallback total products: ${fallbackSnapshot.docs.length}");
      }
    } catch (e) {
      print("Error fetching clothes: $e");
    }
  }

  void filterSearch(String query) {
    setState(() {
      filteredClothes = allClothes
          .where((cloth) =>
              cloth['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showToast(String message) {
    Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT);
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
          IconButton(
            icon: Icon(Icons.person_outline),
            onPressed: () {
              controller.selectedIndex.value = 2;
              Get.toNamed('/Signup');
            },
          ),
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
              child: filteredClothes.isEmpty
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
                                      onPressed: () =>
                                          _showToast("Added to Wishlist"),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.shopping_cart,
                                        color: Colors.black,
                                      ),
                                      onPressed: () =>
                                          _showToast("Added to Cart"),
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
