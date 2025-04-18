import 'dart:typed_data';

import 'package:babyshop/controllers/adminController/category_controller.dart';
import 'package:babyshop/screens/admin-panel/adminCustom%20Widget/drawer.dart';
import 'package:babyshop/screens/user-panel/userWidget/ui_helper.dart';
import 'package:babyshop/utilis/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Category extends StatefulWidget {
  const Category({super.key});

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  Categoryadd categoryadd = Get.find<Categoryadd>();
  @override
  void initState() {
    super.initState();
    categoryadd.fetchCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            // show total category length
            'Total Categories ${categoryadd.categoryList.length}',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        backgroundColor: AppConstants.buttonBg,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: AppDrawer(),
      body: Obx(
        () =>
            categoryadd.categoryList.isEmpty
                ? Center(
                  child: Text(
                    'No categories found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                )
                : Padding(
                  padding: EdgeInsets.all(12.0),
                  child: ListView.builder(
                    itemCount: categoryadd.categoryList.length,
                    itemBuilder: (context, index) {
                      var category = categoryadd.categoryList[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          leading:
                              category.image.isNotEmpty
                                  ? CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      category.image,
                                    ),
                                  )
                                  : Icon(Icons.person),
                          title: Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              editCategory(category.id);
                            },
                            icon: Icon(Icons.edit),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      ),
      // right bottom add icon
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddCategoryDialog();
        },
        backgroundColor: AppConstants.buttonBg,
        child: Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // add dialog when add button click
  void showAddCategoryDialog() async {
    TextEditingController categoryname = TextEditingController();
    // add category function
    void addCategory() {
      String categoryName = categoryname.text.trim();
      if (categoryName.isNotEmpty && categoryadd.selectImage.isNotEmpty) {
        categoryadd.categoryAdd(categoryName);
        Get.back();
        Get.snackbar(
          'Category added',
          'Category added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppConstants.buttonBg,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Category name or image missing',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppConstants.buttonBg,
          colorText: Colors.white,
        );
      }
    }

    // add category dialog
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Form(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'Add Category',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                categoryadd.selectedImage();
              },
              child: Obx(
                () => CircleAvatar(
                  radius: 40,
                  backgroundImage:
                      categoryadd.selectImage.isNotEmpty
                          ? NetworkImage(categoryadd.selectImage.first.path)
                          : null,
                  child:
                      categoryadd.selectImage.isEmpty
                          ? Icon(Icons.add_a_photo)
                          : null,
                ),
              ),
            ),
            getTextFormField(categoryname, 'Enter category name'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              addCategory();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.secondarycolor,
            ),
            child: Column(
              children: [
                Text('Add category', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // End add category dialog

  // Edit category dialog
  void editCategory(String categoryId) {
    TextEditingController categoryEdit = TextEditingController();
    var category = categoryadd.categoryList.firstWhere(
      (c) => c.id == categoryId,
    );
    categoryEdit.text = category.name;
    final String? intitalImage =
        category.image.isNotEmpty ? category.image : null;
    // log('$intitalImage');
    void editData() async {
      var newCategory = categoryEdit.text.trim();
      if (newCategory.isNotEmpty) {
        await categoryadd.editCategory(
          categoryId,
          newCategory,
          categoryadd.selectImage.isNotEmpty
              ? categoryadd.selectImage.first.path
              : intitalImage.toString(),
        );
        Get.back();
        Get.snackbar(
          'Category Update',
          'Category updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppConstants.buttonBg,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Category not updated',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppConstants.buttonBg,
          colorText: Colors.white,
        );
      }
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Edit Category',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: categoryadd.selectedImage,
              child: Obx(
                () => FutureBuilder<Uint8List?>(
                  future:
                      categoryadd.selectImage.isNotEmpty
                          ? categoryadd.selectImage.first.readAsBytes()
                          : null,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircleAvatar(
                        radius: 50,
                        child: CircularProgressIndicator(),
                      );
                    }

                    return CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          categoryadd.selectImage.isNotEmpty
                              ? MemoryImage(
                                snapshot.data!,
                              ) 
                              : (intitalImage != null
                                  ? NetworkImage(
                                    intitalImage,
                                  ) 
                                  : null),
                      child:
                          categoryadd.selectImage.isEmpty &&
                                  intitalImage == null
                              ? Icon(Icons.add_a_photo)
                              : null,
                    );
                  },
                ),
              ),
            ),
            spacer(),
            getTextFormField(categoryEdit, 'Category'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('cancel', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              editData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.secondarycolor,
            ),
            child: Text('Edit Category', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
