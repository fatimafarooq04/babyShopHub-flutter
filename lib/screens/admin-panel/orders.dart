import 'package:babyshop/controllers/adminController/order_controller.dart';
import 'package:babyshop/screens/admin-panel/adminCustom Widget/drawer.dart';
import 'package:babyshop/utilis/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  OrderController orderController = Get.find<OrderController>();
  TextEditingController searchController = TextEditingController();
  var searchQuery = ''.obs;

  @override
  void initState() {
    super.initState();
    orderController.fetchOrders();
  }

  void changeOrderStatus(String orderId, String newStatus) {
    orderController.updateOrderStatus(orderId, newStatus);
  }

  void showOrderDetailsModal(Map orderItem) {
    final orderData = orderItem['orderData'];
    final userName = orderItem['userName'];
    final orderId = orderItem['orderId'];
    final totalPrice = orderData['totalPrice'];
    final timestamp = orderData['timestamp'];
    final cartItems = List<Map<String, dynamic>>.from(orderData['cartItems']);
    final address = orderData['address'];
    final phone = orderData['phone'];
    final status = orderData['status'];
    final statusHistory = orderData['statusHistory'];

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Order Details'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order ID: $orderId'),
                  Text('Customer: $userName'),
                  Text('Total: Rs. $totalPrice'),
                  Text('Date: ${timestamp.toDate()}'),
                  SizedBox(height: 10),
                  Text('Address: $address'),
                  Text('Phone: $phone'),
                  SizedBox(height: 10),
                  Text('Status: $status'),
                  SizedBox(height: 10),
                  Text(
                    'Cart Items:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...cartItems.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${item['ProuductName']}'),
                          Text('Qty: ${item['Quentity']}'),
                        ],
                      ),
                    );
                  }).toList(),
                  SizedBox(height: 10),
                  Text(
                    'Status History:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...((statusHistory ?? []).map((history) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        children: [
                          Text('${history['status']}'),
                          SizedBox(width: 10),
                          Text('${history['timestamp'].toDate()}'),
                        ],
                      ),
                    );
                  }).toList()),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            'Total orders: ${orderController.orders.length}',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        backgroundColor: AppConstants.buttonBg,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: AppDrawer(),
      body: Obx(() {
        if (orderController.orders.isEmpty) {
          return Center(child: Text('No orders found'));
        }

        final filteredOrders =
            orderController.orders.where((order) {
              final orderId = order['orderId'].toString().toLowerCase();
              final userName = order['userName'].toString().toLowerCase();
              final query = searchQuery.value.toLowerCase();
              return orderId.contains(query) || userName.contains(query);
            }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  searchQuery.value = value;
                },
                decoration: InputDecoration(
                  hintText: 'Search by Order ID or Customer Name',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  final orderItem = filteredOrders[index];
                  final orderData = orderItem['orderData'];
                  final userName = orderItem['userName'];
                  final orderId = orderItem['orderId'];
                  final totalPrice = orderData['totalPrice'];
                  final status = orderData['status'];

                  return GestureDetector(
                    onTap: () => showOrderDetailsModal(orderItem),
                    child: Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      elevation: 2,
                      child: ListTile(
                        title: Text('Order ID: $orderId'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Customer: $userName'),
                            Text('Total: Rs. $totalPrice'),
                          ],
                        ),
                        trailing: DropdownButton<String>(
                          value: status,
                          items:
                              [
                                'Pending',
                                'Processing',
                                'Shipped',
                                'Delivered',
                                'Cancelled',
                              ].map((String statusOption) {
                                return DropdownMenuItem<String>(
                                  value: statusOption,
                                  child: Text(statusOption),
                                );
                              }).toList(),
                          onChanged: (newStatus) {
                            if (newStatus != null) {
                              changeOrderStatus(orderId, newStatus);
                            }
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
