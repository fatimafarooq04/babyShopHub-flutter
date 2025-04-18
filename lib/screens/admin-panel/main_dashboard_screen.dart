import 'package:babyshop/controllers/adminController/brand_controller.dart';
import 'package:babyshop/controllers/adminController/category_controller.dart';
import 'package:babyshop/controllers/adminController/order_controller.dart';
import 'package:babyshop/controllers/adminController/product_controller.dart';
import 'package:babyshop/screens/admin-panel/adminCustom%20Widget/drawer.dart';
import 'package:babyshop/utilis/app_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  final categoryController = Get.find<Categoryadd>();
  final brandController = Get.find<BrandController>();
  final productController = Get.find<ProductController>();
  final orderController = Get.put(OrderController());

  @override
  void initState() {
    super.initState();

    // Call these to load data when the screen opens
    categoryController.fetchCategory();
    brandController.fetchBrands();
    productController.fetchProducts();
    orderController.fetchProductOrderStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.buttonBg,
        title: const Text(
          'Admin Panel',
          style: TextStyle(color: Colors.white, fontSize: 26),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();

              Get.snackbar(
                'Logged out',
                'You have been signed out.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppConstants.buttonBg,
                colorText: Colors.white,
              );
              Get.toNamed('/Signup');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            final brandCount = brandController.brandList.length;
            final categoryCount = categoryController.categoryList.length;
            final productCount = productController.productsList.length;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildDashboardCard(
                        title: 'Total Brands',
                        count: brandCount,
                        color: Colors.purple,
                        icon: Icons.branding_watermark,
                      ),
                      _buildDashboardCard(
                        title: 'Total Categories',
                        count: categoryCount,
                        color: Colors.orange,
                        icon: Icons.category,
                      ),
                      _buildDashboardCard(
                        title: 'Total Products',
                        count: productCount,
                        color: Colors.green,
                        icon: Icons.shopping_bag,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Top Products',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildTopProductsByBrandChart(),
                  const SizedBox(height: 30),
                  const Text(
                    'Category Sales',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // let content decide size
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProductsByBrandChart() {
    return Obx(() {
      final data = orderController.productOrderData;

      if (data.isEmpty) return const Text("No data to show");

      final productNames = data.keys.toList();
      final brandNames = <String>{};

      for (var brandMap in data.values) {
        brandNames.addAll(brandMap.keys);
      }

      final brandList = brandNames.toList();

      // Create grouped bars
      List<BarChartGroupData> groups = [];

      for (int i = 0; i < productNames.length; i++) {
        final productName = productNames[i];
        final brandMap = data[productName]!;

        List<BarChartRodData> rods = [];

        for (int j = 0; j < brandList.length; j++) {
          final brand = brandList[j];
          final count = brandMap[brand] ?? 0;

          rods.add(
            BarChartRodData(
              toY: count.toDouble(),
              color: Colors.primaries[j % Colors.primaries.length],
            ),
          );
        }

        groups.add(BarChartGroupData(x: i, barRods: rods));
      }

      return SizedBox(
        height: 300,
        child: BarChart(
          BarChartData(
            barGroups: groups,
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() < productNames.length) {
                      return Transform.rotate(
                        angle: -0.5,
                        child: Text(
                          productNames[value.toInt()],
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) => Text('${value.toInt()}'),
                ),
              ),
            ),
            gridData: FlGridData(show: true),
            borderData: FlBorderData(show: false),
            groupsSpace: 30,
          ),
        ),
      );
    });
  }
}
