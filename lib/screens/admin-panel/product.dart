import 'package:babyshop/controllers/adminController/brand_controller.dart';
import 'package:babyshop/models/brand_model.dart';
import 'package:babyshop/models/product_model.dart';
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
  BrandController brandController = Get.find<BrandController>();
  Categoryadd category = Get.find<Categoryadd>();

  @override
  void initState() {
    super.initState();
    productController.fetchProducts();
    category.fetchCategory();
    brandController.fetchBrands();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Obx(
          () => Text(
            'Products ${productController.productsList.length}',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        backgroundColor: AppConstants.buttonBg,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: AppDrawer(),
      body: Obx(
        () =>
            productController.productsList.isEmpty
                ? Center(
                  child: Text(
                    'No products found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                )
                : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListView.builder(
                    itemCount: productController.productsList.length,
                    itemBuilder: (context, index) {
                      var products = productController.productsList[index];
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
                              products.productImages.isEmpty
                                  ? Icon(Icons.branding_watermark)
                                  : CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      products.productImages.first,
                                    ),
                                  ),
                          title: Text(products.productName),
                          trailing: IconButton(
                            onPressed: () {
                              detailsDialog(products);
                            },
                            icon: Icon(Icons.remove_red_eye),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      ),
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
      // Get category ID
      String categoryId =
          category.selectedCategory.value?.id ??
          (category.categoryList.isNotEmpty
              ? category.categoryList.first.id
              : '');
      String brandid =
          brandController.selectedBrand.value?.id ??
          (brandController.brandList.isNotEmpty
              ? brandController.brandList.first.id
              : '');

      productController.productAdd(
        productName.text.trim(),
        productDesc.text.trim(),
        productPrice.text.trim(),
        productsalePrice.text.trim(),
        categoryId,
        brandid,
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
                  spacer(),
                  getTextFormField(productsalePrice, 'Add product sale price'),
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
                                    child: Text(cate.name),
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
                  Obx(
                    () =>
                        brandController.brandList.isEmpty
                            ? Text('No brand found')
                            : Container(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppConstants.outline),
                                color: Color.fromARGB(36, 154, 82, 255),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<BrandModel>(
                                isExpanded: true,
                                value:
                                    brandController.selectedBrand.value ??
                                    brandController.brandList.first,
                                items:
                                    brandController.brandList.map((b) {
                                      return DropdownMenuItem<BrandModel>(
                                        value: b,
                                        child: Text(b.name),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  brandController.selectedBrand.value = value;
                                },
                              ),
                            ),
                  ),
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
                if (productController.finalImages.isEmpty) {
                  Get.snackbar(
                    'Images Required',
                    'Please select at least one image',
                    backgroundColor: Colors.red.shade100,
                    colorText: Colors.black,
                  );
                } else {
                  add();
                  Get.back();
                }
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

  void detailsDialog(ProductModel product) {
    final brandName =
        brandController.brandList
            .firstWhereOrNull((b) => b.id == product.brandId)
            ?.name ??
        'Unknown';

    final categoryName =
        category.categoryList
            .firstWhereOrNull((c) => c.id == product.categoryId)
            ?.name ??
        'Unknown';

    Get.dialog(
      Dialog(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),

                // Image Section with Safe Error Handling
                if (product.productImages.isNotEmpty)
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: product.productImages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: _buildImageWidget(
                            product.productImages[index],
                          ),
                        );
                      },
                    ),
                  )
                else
                  _buildNoImagePlaceholder(),

                SizedBox(height: 16),
                _buildDetailRow("Description:", product.productDescription),
                SizedBox(height: 8),
                _buildDetailRow("Price:", product.price),
                SizedBox(height: 8),
                _buildDetailRow(
                  "Sale Price:",
                  product.salePrice ?? 'Not available',
                ),
                SizedBox(height: 8),
                _buildDetailRow("Category:", categoryName),
                SizedBox(height: 8),
                _buildDetailRow("Brand:", brandName),
                SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Close', style: TextStyle(color: Colors.red)),
                    ),
                    TextButton(
                      onPressed: () {
                        editProducts(product.id);
                      },
                      child: Text(
                        'Edit product',
                        style: TextStyle(color: AppConstants.buttonBg),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        productController.deleteProduct(product.id);
                      },
                      child: Text(
                        'Delete product',
                        style: TextStyle(color: AppConstants.buttonBg),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for image display with error handling
  Widget _buildImageWidget(String imageUrl) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper widget for error state
  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.grey[500]),
            SizedBox(height: 4),
            Text(
              'Image failed to load',
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for no images
  Widget _buildNoImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, color: Colors.grey[500]),
            SizedBox(height: 4),
            Text(
              'No images available',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for consistent detail rows
  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(width: 8),
        Flexible(child: Text(value)),
      ],
    );
  }

  void editProducts(String productId) async {
    // Find the product to edit
    final product = productController.productsList.firstWhere(
      (p) => p.id == productId,
      orElse:
          () => ProductModel(
            id: '',
            productName: '',
            productDescription: '',
            price: '',
            categoryId: '',
            brandId: '',
            productImages: [],
          ),
    );

    if (product.id.isEmpty) {
      Get.snackbar('Error', 'Product not found');
      return;
    }

    // Initialize controllers with current product values
    final productName = TextEditingController(text: product.productName);
    final productDesc = TextEditingController(text: product.productDescription);
    final productPrice = TextEditingController(text: product.price);
    final productSalePrice = TextEditingController(
      text: product.salePrice ?? '',
    );

    // Set current category and brand
    category.selectedCategory.value = category.categoryList.firstWhereOrNull(
      (c) => c.id == product.categoryId,
    );
    brandController.selectedBrand.value = brandController.brandList
        .firstWhereOrNull((b) => b.id == product.brandId);

    // Clear any previously selected images
    productController.finalImages.clear();

    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    void updateProduct() {
      if (formKey.currentState!.validate()) {
        productController.updateProduct(
          productId,
          productName.text.trim(),
          productDesc.text.trim(),
          productPrice.text.trim(),
          productSalePrice.text.trim(),
          category.selectedCategory.value?.id ?? '',
          brandController.selectedBrand.value?.id ?? '',
          productController.finalImages,
        );
        Get.back();
      }
    }

    Get.dialog(
      Dialog(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Product',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),

                  // Product Name
                  getTextFormField(
                    productName,
                    'Product name',
                    validator:
                        MultiValidator([
                          RequiredValidator(
                            errorText: 'This field is required',
                          ),
                        ]).call,
                  ),
                  spacer(),

                  // Product Description
                  getTextFormField(
                    productDesc,
                    'Product description',
                    validator:
                        MultiValidator([
                          RequiredValidator(
                            errorText: 'This field is required',
                          ),
                        ]).call,
                  ),
                  spacer(),

                  // Product Price
                  getTextFormField(
                    productPrice,
                    'Product price',
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

                  // Sale Price
                  getTextFormField(productSalePrice, 'Sale price (optional)'),
                  spacer(),

                  // Category Dropdown
                  Obx(() {
                    return category.categoryList.isEmpty
                        ? Text('No categories available')
                        : Container(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppConstants.outline),
                            color: Color.fromARGB(36, 154, 82, 255),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButton<CategoryModel>(
                            isExpanded: true,
                            value: category.selectedCategory.value,
                            items:
                                category.categoryList.map((cate) {
                                  return DropdownMenuItem<CategoryModel>(
                                    value: cate,
                                    child: Text(cate.name),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              category.selectedCategory.value = value;
                            },
                            hint: Text('Select category'),
                            underline: SizedBox(),
                          ),
                        );
                  }),
                  spacer(),

                  // Brand Dropdown
                  Obx(() {
                    return brandController.brandList.isEmpty
                        ? Text('No brands available')
                        : Container(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppConstants.outline),
                            color: Color.fromARGB(36, 154, 82, 255),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButton<BrandModel>(
                            isExpanded: true,
                            value: brandController.selectedBrand.value,
                            items:
                                brandController.brandList.map((brand) {
                                  return DropdownMenuItem<BrandModel>(
                                    value: brand,
                                    child: Text(brand.name),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              brandController.selectedBrand.value = value;
                            },
                            hint: Text('Select brand'),
                            underline: SizedBox(),
                          ),
                        );
                  }),
                  spacer(),

                  // Current Images
                  Text(
                    'Current Images:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  if (product.productImages.isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: product.productImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: _buildImageWidget(
                              product.productImages[index],
                            ),
                          );
                        },
                      ),
                    )
                  else
                    _buildNoImagePlaceholder(),
                  spacer(),

                  // Add New Images
                  Text(
                    'Add New Images:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Custombutton(
                    onPressed: () => productController.pickImage(),
                    text: 'Select Images',
                    width: 200,
                  ),
                  spacer(),

                  // Selected New Images
                  Obx(() {
                    return productController.finalImages.isNotEmpty
                        ? SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: productController.finalImages.length,
                            itemBuilder: (context, index) {
                              final image =
                                  productController.finalImages[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Stack(
                                  children: [
                                    _buildImageWidget(image.path),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: IconButton(
                                        icon: Icon(Icons.close, size: 20),
                                        onPressed: () {
                                          productController.finalImages
                                              .removeAt(index);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                        : SizedBox();
                  }),
                  spacer(),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: updateProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.buttonBg,
                        ),
                        child: Text(
                          'Update Product',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
