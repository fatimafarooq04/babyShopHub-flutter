import 'package:babyshop/utilis/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({super.key});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? productId;
  Map<String, dynamic>? productData;
  String brandName = '';
  String categoryName = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    productId = Get.arguments['productId'];
    print("Fetched product ID for product detailpage: $productId");

    if (productId != null) {
      fetchProductDetails();
    } else {
      print(" No productId found in arguments");
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchProductDetails() async {
    try {
      final productDoc =
          await _firestore.collection('products').doc(productId).get();

      if (productDoc.exists) {
        productData = productDoc.data();
        final brandId = productData?['brandId'];
        final categoryId = productData?['categoryId'];

        print(" Brand ID: $brandId");
        print(" Category ID: $categoryId");

        final brandDoc =
            await _firestore.collection('Brands').doc(brandId).get();
        final categoryDoc =
            await _firestore.collection('Category').doc(categoryId).get();

        print("Brand exists: ${brandDoc.exists}");
        print("Category exists: ${categoryDoc.exists}");

        setState(() {
          brandName = brandDoc.exists ? brandDoc['brandName'] : 'Unknown Brand';
          categoryName =
              categoryDoc.exists
                  ? categoryDoc['categoryName']
                  : 'Unknown Category';
          isLoading = false;
        });
      } else {
        print(" Product not found for ID: $productId");
        setState(() => isLoading = false);
      }
    } catch (e, stackTrace) {
      print("Error in fetchProductDetails: $e");
      print(" Stack trace:\n$stackTrace");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || productData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Product Details'),
          backgroundColor: AppConstants.buttonBg,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(productData!['productName'] ?? 'Product Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (productData!['productImages'] != null &&
                productData!['productImages'] is List &&
                productData!['productImages'].isNotEmpty)
              CarouselSlider(
                options: CarouselOptions(
                  height: 200,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: false,
                  viewportFraction: 0.9,
                ),
                items:
                    (productData!['productImages'] as List).map<Widget>((
                      imageUrl,
                    ) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          width: double.infinity,
                        ),
                      );
                    }).toList(),
              ),

            const SizedBox(height: 16),
            Text(
              productData!['productName'] ?? '',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text("Brand: $brandName", style: const TextStyle(fontSize: 16)),
            Text(
              "Category: $categoryName",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text("Price: \$${productData!['price']}"),
            // if (productData!['salePrice'] != null && productData!['salePrice'].isNotEmpty)
            //   Text("Sale Price: \$${productData!['salePrice']}", style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            Text(
              productData!['productDescription'] ?? '',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
