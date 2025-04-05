import 'dart:io';

import 'package:babyshop/controllers/adminController/category_controller.dart';
import 'package:babyshop/controllers/adminController/product_controller.dart';
import 'package:babyshop/models/category_model.dart';
import 'package:babyshop/screens/admin-panel/Category.dart';
import 'package:babyshop/screens/admin-panel/adminCustom%20Widget/drawer.dart';
import 'package:babyshop/screens/user-panel/userWidget/custombutton.dart';
import 'package:babyshop/screens/user-panel/userWidget/ui_helper.dart';
import 'package:babyshop/utilis/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';

class Product extends StatefulWidget {
  const Product({super.key});

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  // find product controller
  ProductController productController = Get.find<ProductController>();
  Categoryadd category = Get.find<Categoryadd>();
  @override
  void initState() {
    super.initState();
    category.fetchCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Products',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppConstants.buttonBg,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // call add dialog
          showDialog();
        },
        backgroundColor: AppConstants.buttonBg,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // add product dialog
  void showDialog() {
    GlobalKey<FormState> formkey = GlobalKey<FormState>();
    TextEditingController productName = TextEditingController();
    TextEditingController productDesc = TextEditingController();
    TextEditingController productPrice = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Add Product'),
        content: SizedBox(
          width: 600, // Makes dialog wide on web
          child: SingleChildScrollView(
            child: Form(
              key: formkey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  getTextFormField(
                    productName,
                    'Add product name',
                    validator:
                        MultiValidator([
                          RequiredValidator(
                            errorText: 'This field is required',
                          ),
                        ]).call,
                  ),
                  spacer(),
                  getTextFormField(
                    productDesc,
                    'Add product description',
                    validator:
                        MultiValidator([
                          RequiredValidator(
                            errorText: 'This field is required',
                          ),
                        ]).call,
                  ),
                  spacer(),
                  getTextFormField(
                    productPrice,
                    'Add product price',
                    validator:
                        MultiValidator([
                          RequiredValidator(
                            errorText: 'This field is required',
                          ),
                          PatternValidator(
                            r'^\d+(\.\d{1,2})?$',
                            errorText: 'Enter a valid price',
                          ),
                        ]).call,
                  ),
                  spacer(),

                  // Category Dropdown
                  Obx(() {
                    return category.categoryList.isEmpty
                        ? Text('No category found')
                        : Container(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButton<CategoryModel>(
                            isExpanded: true,
                            value:
                                category.selectedCategory.value ??
                                category.categoryList.first,
                            items:
                                category.categoryList.map((cate) {
                                  return DropdownMenuItem<CategoryModel>(
                                    value: cate,
                                    child: Text(cate.categoryName),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              category.selectedCategory.value = value;
                            },
                            underline: SizedBox(),
                          ),
                        );
                  }),

                  spacer(),

                  Custombutton(
                    onPressed: () {
                      productController.pickImage();
                    },
                    text: 'Select Images',
                    width: 200,
                  ),

                  spacer(),

                  // ✅ Image grid with fixed height
                  Obx(() {
                    return productController.finalImages.isNotEmpty
                        ? SizedBox(
                          height: 150,
                          child: GridView.builder(
                            itemCount: productController.finalImages.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 4,
                                  mainAxisSpacing: 4,
                                ),
                            itemBuilder: (context, index) {
                              final imageFile =
                                  productController.finalImages[index];
                              return CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(imageFile.path),
                              );
                            },
                          ),
                        )
                        : Text('No images selected');
                  }),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              if (formkey.currentState!.validate()) {
                // Submit form
                print("Add Product logic here");
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.buttonBg,
            ),
            child: Text('Add Product', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
