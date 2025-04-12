import 'dart:typed_data';

import 'package:babyshop/controllers/adminController/brand_controller.dart';
import 'package:babyshop/screens/admin-panel/adminCustom%20Widget/drawer.dart';
import 'package:babyshop/screens/user-panel/userWidget/custombutton.dart';
import 'package:babyshop/screens/user-panel/userWidget/ui_helper.dart';
import 'package:babyshop/utilis/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Brand extends StatefulWidget {
  const Brand({super.key});

  @override
  State<Brand> createState() => _BrandState();
}

class _BrandState extends State<Brand> {
  BrandController brandController = Get.find<BrandController>();
  @override
  void initState() {
    super.initState();
    brandController.fetchBrands();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            'Brands ${brandController.brandList.length}',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),

        centerTitle: true,
        backgroundColor: AppConstants.buttonBg,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: AppDrawer(),
      body: Obx(
        () =>
            brandController.brandList.isEmpty
                ? Center(
                  child: Text(
                    'no brand found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                )
                : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: brandController.brandList.length,
                    itemBuilder: (context, index) {
                      var brand = brandController.brandList[index];
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
                              brand.image.isNotEmpty
                                  ? CircleAvatar(
                                    radius: 40,
                                    backgroundImage: NetworkImage(brand.image),
                                  )
                                  : Icon(Icons.branding_watermark),
                          title: Text(
                            brand.name.isNotEmpty ? brand.name : 'no Name',
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              editData(brand.id);
                            },
                            icon: Icon(Icons.edit),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addBrandDialog();
        },
        backgroundColor: AppConstants.buttonBg,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void addBrandDialog() {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    TextEditingController brandName = TextEditingController();
    void addData() async {
      String brandname = brandName.text.trim();
      if (brandname.isEmpty && brandController.selectedImage.isEmpty) {
        Get.snackbar(
          'Error',
          'Category name or image missing',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppConstants.buttonBg,
          colorText: Colors.white,
        );
      } else {
        brandController.addBrand(brandname);
        Get.snackbar(
          'Added',
          'Brand name added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppConstants.buttonBg,
          colorText: Colors.white,
        );
      }
    }

    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add brand',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  spacer(),
                  GestureDetector(
                    onTap: () {
                      brandController.pickImage();
                    },
                    child: Obx(
                      () => CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            brandController.selectedImage.isNotEmpty
                                ? NetworkImage(
                                  brandController.selectedImage.first.path,
                                )
                                : null,
                        child:
                            brandController.selectedImage.isEmpty
                                ? Icon(Icons.add_a_photo)
                                : null,
                      ),
                    ),
                  ),
                  spacer(),
                  getTextFormField(brandName, 'Brand name'),
                  spacer(),
                  Custombutton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {}
                      addData();
                    },
                    text: 'Add brand',
                    width: 150,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void editData(String brandId) async {
    var brand = brandController.brandList.firstWhere((b) => b.id == brandId);
    TextEditingController brandName = TextEditingController(text: brand.name);
    final String? initialImage = brand.image.isNotEmpty ? brand.image : null;

    // Clear any previously selected images
    brandController.selectedImage.clear();
    void editData() async {
      var brand = brandName.text.trim();
      if (brand.isNotEmpty) {
        await brandController.editData(
          brandId,
          brand,
          initialImage ??
              '', // existing image to be replaced if new one is selected
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
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit Brand',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Form(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      getTextFormField(brandName, 'Brand name'),
                      spacer(),
                      GestureDetector(
                        onTap: brandController.pickImage,
                        child: Obx(
                          () => FutureBuilder<Uint8List?>(
                            future:
                                brandController.selectedImage.isNotEmpty
                                    ? brandController.selectedImage.first
                                        .readAsBytes()
                                    : null,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircleAvatar(
                                  radius: 50,
                                  child: CircularProgressIndicator(),
                                );
                              }

                              return CircleAvatar(
                                radius: 50,
                                backgroundImage:
                                    brandController.selectedImage.isNotEmpty
                                        ? MemoryImage(
                                          snapshot.data!,
                                        ) // New image
                                        : (initialImage != null
                                            ? NetworkImage(
                                              initialImage,
                                            ) // Existing image
                                            : null),
                                child:
                                    brandController.selectedImage.isEmpty &&
                                            initialImage == null
                                        ? Icon(Icons.add_a_photo)
                                        : null,
                              );
                            },
                          ),
                        ),
                      ),
                      spacer(),
                      Custombutton(
                        onPressed: () {
                          // Call your update function here
                          editData();
                        },
                        text: 'Update Brand',
                        width: 200,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
