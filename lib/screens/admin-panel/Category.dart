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
                          leading: CircleAvatar(child: Text('${index + 1}')),
                          title: Text(
                            category.categoryName,
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
  void showAddCategoryDialog() {
    TextEditingController categoryname = TextEditingController();
    // add category function
    void addCategory() {
      String categoryName = categoryname.text.trim();
      if (categoryName.isNotEmpty) {
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
          'Category name cannot be empty',
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
        title: Text(
          'Add Category',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: getTextFormField(categoryname, 'Enter category name'),
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
            child: Text('Add category', style: TextStyle(color: Colors.white)),
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
    categoryEdit.text = category.categoryName;
    void editData() async {
      var newCategory = categoryEdit.text.trim();
      if (newCategory.isNotEmpty) {
        await categoryadd.editCategory(categoryId, newCategory);
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
        content: getTextFormField(categoryEdit, 'Category'),
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
