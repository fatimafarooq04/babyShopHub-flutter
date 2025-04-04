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
    // form key for validation
    GlobalKey<FormState> formkey = GlobalKey<FormState>();
    TextEditingController productName = TextEditingController();
    TextEditingController productDesc = TextEditingController();
    TextEditingController productPrice = TextEditingController();

    Get.dialog(
      Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: AlertDialog(
              title: Text('Add product'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    Form(
                      key: formkey,
                      child: Column(
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
                          // Obx(()=>DropdownButton<CategoryModel>(
                          //   // value: category.,
                          //   items: [], onChanged: (value) {}),),
                          Custombutton(
                            onPressed: () {
                              productController.pickImage();
                            },
                            text: 'Select images',

                            width: 200,
                          ),
                          spacer(),
                          SizedBox(
                            height: 150,
                            child: Obx(
                              () =>
                                  productController.finalImages.isNotEmpty
                                      ? GridView.builder(
                                        shrinkWrap: true,
                                        physics: ClampingScrollPhysics(),
                                        itemCount:
                                            productController
                                                .finalImages
                                                .length,
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              crossAxisSpacing: 4,
                                              mainAxisSpacing: 4,
                                            ),
                                        itemBuilder: (context, index) {
                                          return CircleAvatar(
                                            radius: 20,
                                            backgroundImage: NetworkImage(
                                              productController
                                                  .finalImages[index]
                                                  .path,
                                            ),
                                          );
                                        },
                                      )
                                      : Center(
                                        child: Text('No images selected'),
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
                    if (formkey.currentState!.validate()) {
                      // Add Product Logic
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.buttonBg,
                  ),
                  child: Text(
                    'Add product',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
