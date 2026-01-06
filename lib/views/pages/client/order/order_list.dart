import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/models/order.model.dart';
import 'package:recomart/provider/order_provider.dart';
import 'package:recomart/provider/user_provider.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_loaded) return;

    final userId = context.read<UserProvider>().user?.id;

    if (userId != null && userId.isNotEmpty) {
      debugPrint('--- [UI] Fetch order history for userId: $userId');
      context.read<OrderProvider>().fetchOrderHistory(userId);
      _loaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'My Orders History',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Consumer2<UserProvider, OrderProvider>(
        builder: (context, userProvider, orderProvider, _) {
          final userId = userProvider.user?.id;

          if (userId == null || userId.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (!orderProvider.hasFetched) {
            debugPrint('--- [UI] Fetch order history for userId: $userId');
            orderProvider.fetchOrderHistory(userId);
          }

          if (orderProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (orderProvider.errorMessage != null) {
            return _emptyState(
              icon: Icons.error_outline,
              title: "Something went wrong",
              subtitle: orderProvider.errorMessage!,
            );
          }

          if (orderProvider.orders.isEmpty) {
            return _emptyState(
              icon: Icons.shopping_bag_outlined,
              title: "No orders yet",
              subtitle: "You haven't made any orders yet.",
              showBrowse: true,
            );
          }

          return RefreshIndicator(
            onRefresh: () => orderProvider.fetchOrderHistory(userId, force: true),
            color: AppColors.primary,
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: orderProvider.orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, index) =>
                  _orderCard(context, orderProvider.orders[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _orderCard(BuildContext context, OrderModel order) {
    return InkWell(
      onTap: () => context.push('/order-detail', extra: order.id),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.inventory_2_outlined, color: Colors.grey),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order #${order.id?.substring(0, 8).toUpperCase()}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Total: ${order.totalAmount?.toStringAsFixed(0)} VND",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            _statusBadge(order.status ?? 'PENDING'),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final color = status.toLowerCase() == 'cancelled'
        ? Colors.red
        : status.toLowerCase() == 'completed'
            ? Colors.green
            : Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    bool showBrowse = false,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center),
          if (showBrowse)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Start Shopping'),
              ),
            ),
        ],
      ),
    );
  }
}
