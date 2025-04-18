import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class OrderController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // List of orders with user names
  var orders = <Map<String, dynamic>>[].obs;

  Future<void> fetchOrders() async {
    try {
      QuerySnapshot snapshot = await firestore.collection('Orders').get();

      List<Map<String, dynamic>> orderList = [];

      for (var doc in snapshot.docs) {
        var orderData = doc.data() as Map<String, dynamic>;
        var userId = orderData['userId'];

        DocumentSnapshot userDoc =
            await firestore.collection('user').doc(userId).get();

        var userData = userDoc.data() as Map<String, dynamic>?;

        // Get the latest status update timestamp
        var statusHistory = List<Map<String, dynamic>>.from(
          orderData['statusHistory'] ?? [],
        );

        DateTime latestStatusTime =
            statusHistory.isNotEmpty
                ? (statusHistory.last['timestamp'] as Timestamp).toDate()
                : DateTime.fromMillisecondsSinceEpoch(0); // fallback time

        orderList.add({
          'orderId': doc.id,
          'orderData': orderData,
          'userName': userData?['username'] ?? 'Unknown',
          'latestStatusTime': latestStatusTime,
        });
      }

      // Sort orders based on latestStatusTime in descending order
      orderList.sort(
        (a, b) => (b['latestStatusTime'] as DateTime).compareTo(
          a['latestStatusTime'],
        ),
      );

      orders.value = orderList;
    } catch (e) {
      log('Error fetching orders: $e');
    }
  }

  // Method to update the status of an order
  void updateOrderStatus(String orderId, String newStatus) async {
    try {
      final docRef = firestore.collection('Orders').doc(orderId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final orderData = docSnapshot.data() as Map<String, dynamic>;
        final existingHistory = List<Map<String, dynamic>>.from(
          orderData['statusHistory'] ?? [],
        );

        existingHistory.add({'status': newStatus, 'timestamp': DateTime.now()});

        await docRef.update({
          'status': newStatus,
          'statusHistory': existingHistory,
        });

        // Refresh orders to reflect changes
        fetchOrders();

        Get.snackbar('Success', 'Order status updated to $newStatus');
      } else {
        Get.snackbar('Error', 'Order not found');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status: $e');
    }
  }

  var productOrderData =
      <String, Map<String, int>>{}
          .obs; // {productName: {brandName: orderCount}}

  Future<void> fetchProductOrderStats() async {
    try {
      QuerySnapshot orderSnapshot = await firestore.collection('Orders').get();
      log('Total orders: ${orderSnapshot.docs.length}');

      Map<String, Map<String, int>> tempData = {};

      for (var doc in orderSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        List cartItems = data['cartItems'] ?? [];

        for (var item in cartItems) {
          String productName = item['ProuductName'] ?? 'Unknown';
          String brandName = item['BrandID'] ?? 'Unknown';
          int quantity = item['Quentity'] ?? 1;

          tempData.putIfAbsent(productName, () => {});
          tempData[productName]!.putIfAbsent(brandName, () => 0);
          tempData[productName]![brandName] =
              tempData[productName]![brandName]! + quantity;
        }
      }

      log('Grouped product order data: $tempData');
      productOrderData.value = tempData;
    } catch (e) {
      log('Error fetching product stats: $e');
    }
  }
}
