import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:babyshop/controllers/adminController/product_controller.dart';
import 'package:babyshop/controllers/adminController/category_controller.dart';
import 'package:babyshop/models/category_model.dart';
import 'package:babyshop/screens/admin-panel/adminCustom%20Widget/drawer.dart';
import 'package:babyshop/utilis/app_constants.dart';
import 'package:babyshop/screens/user-panel/userWidget/custombutton.dart';
import 'package:babyshop/screens/user-panel/userWidget/ui_helper.dart';

class Product extends StatefulWidget {
  const Product({super.key});

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
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
          // Call add dialog
          showDialog();
        },
        backgroundColor: AppConstants.buttonBg,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Add product dialog
  void showDialog() {
    GlobalKey<FormState> formkey = GlobalKey<FormState>();
    TextEditingController productName = TextEditingController();
    TextEditingController productDesc = TextEditingController();
    TextEditingController productPrice = TextEditingController();
    TextEditingController productsalePrice = TextEditingController();
    void add() {
      String categoryId =
          category.selectedCategory.value?.id ??
          (category.categoryList.isNotEmpty
              ? category.categoryList.first.id
              : '');
      ; // Get category ID
      productController.productAdd(
        productName.text.trim(),
        productDesc.text.trim(),
        productPrice.text.trim(),
        productsalePrice.text.trim(),
        categoryId,

        productController.finalImages,
      );
    }

    Get.dialog(
      AlertDialog(
        title: Text('Add Product'),
        content: SizedBox(
          width: 600,
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
                  getTextFormField(
                    productsalePrice,
                    'Add product sale price',
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
                            border: Border.all(color: AppConstants.outline),
                            color: Color.fromARGB(36, 154, 82, 255),
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

                  // Image Selection
                  Custombutton(
                    onPressed: () {
                      productController.pickImage();
                    },
                    text: 'Select Images',
                    width: 200,
                  ),

                  spacer(),

                  // Display selected images
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
                // Call productAdd function with category ID
                add();
                Get.back();
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
