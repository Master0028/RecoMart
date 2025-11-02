import 'package:flutter/material.dart';

// Dữ liệu giả lập
final List<Map<String, dynamic>> FE_ORDERS_STUB = [
  {
    'id': 'ORD-001',
    'customerName': 'Nguyen Van A',
    'orderDate': '2025-11-01',
    'totalAmount': 15000000.0,
    'discountApplied': 500000.0,
    'status': 'SHIPPING',
    'products': [
      {'name': 'Laptop Gaming', 'quantity': 1, 'unit_price': 14000000.0},
    ],
  },
  {
    'id': 'ORD-002',
    'customerName': 'Le Thi B',
    'orderDate': '2025-10-28',
    'totalAmount': 800000.0,
    'discountApplied': 0.0,
    'status': 'PENDING',
    'products': [
      {'name': 'Wireless Mouse', 'quantity': 2, 'unit_price': 400000.0},
    ],
  },
];

class OrderManagementTable extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  const OrderManagementTable({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Management Table', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('${orders.length} orders loaded.'),
        ],
      ),
    );
  }
}


class OrderManagementScreen extends StatelessWidget {
  const OrderManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bool isLoading = false;
    final List<Map<String, dynamic>> orders = FE_ORDERS_STUB;

    return Container(
      color: Colors.grey[100],
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLoading)
              // ignore: dead_code
              const Center(child: CircularProgressIndicator())
            else if (orders.isEmpty)
              const Center(child: Text("No orders found"))
            else
              OrderManagementTable(
                orders: orders,
              ),
          ],
        ),
      ),
    );
  }
}