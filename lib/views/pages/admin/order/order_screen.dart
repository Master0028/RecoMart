import 'package:flutter/material.dart';
import 'package:recomart/services/order.service.dart';
import 'package:recomart/views/pages/admin/order/widgets/order_table.dart';

class OrderManagementScreen extends StatelessWidget {
  const OrderManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderService orderService = OrderService();

    return Container(
      color: Colors.grey[100],
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: orderService.streamAllOrders(), // 👈 dùng stream realtime
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "❌ Lỗi tải dữ liệu: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return const Center(child: Text("Không có đơn hàng nào"));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OrderManagementTable(orders: orders),
              ],
            ),
          );
        },
      ),
    );
  }
}
