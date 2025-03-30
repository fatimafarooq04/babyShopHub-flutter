import 'dart:developer';
import 'package:babyshop/models/category_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class Categoryadd extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<CategoryModel> categoryList = <CategoryModel>[].obs;

  //  Add category and store Firestore ID
  Future<void> categoryAdd(String categoryName) async {
    try {
      DocumentReference docRef = await _firestore.collection('Category').add({
        'categoryName': categoryName,
      });

      // Update document to include its ID
      await docRef.update({'id': docRef.id});

      fetchCategory();
    } catch (e) {
      log('Error adding category: $e');
    }
  }

  // Fetch categories
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

  Future<void> editCategory(String id, String categoryNew) async {
    try {
      await _firestore.collection('Category').doc(id).update({
        'categoryName': categoryNew,
      });
      fetchCategory();
    } catch (e) {
      log('Error $e');
    }
  }
}
