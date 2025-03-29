import 'dart:developer';
import 'package:babyshop/models/category_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class Categoryadd extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Ensure type safety in RxList
  RxList<CategoryModel> categoryList = <CategoryModel>[].obs;

  // ✅ Fix: Add category and store Firestore ID
  Future<void> categoryAdd(String categoryName) async {
    try {
      DocumentReference docRef = await _firestore.collection('Category').add({
        'categoryName': categoryName,
      });

      // Update document to include its ID
      await docRef.update({'id': docRef.id});

      log('Category added successfully with ID: ${docRef.id}');
      fetchCategory(); // Refresh category list
    } catch (e) {
      log('Error adding category: $e');
    }
  }

  // ✅ Fix: Fetch categories and include Firestore ID
  Future<void> fetchCategory() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('Category').get();

      categoryList.assignAll(
        snapshot.docs.map((doc) => CategoryModel.fromMap(doc.data())).toList(),
      );

      log("Categories fetched: ${categoryList.length}");
    } catch (e) {
      log('Error fetching categories: $e');
    }
  }
}
