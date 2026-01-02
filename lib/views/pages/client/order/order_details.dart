import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recomart/models/order.model.dart';
import 'package:recomart/provider/order_provider.dart';
import 'package:recomart/helpers/formatMoney.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;
  const OrderDetailScreen({super.key, required this.order, required String orderId});

  Color _statusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'shipping':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final orderId = order.id;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('Order #${order.id}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// ORDER STATUS
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Order Status',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Chip(
                    backgroundColor: _statusColor(order.status),
                    label: Text(
                      order.status?.toUpperCase() ?? 'UNKNOWN',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// PRODUCTS
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: order.items!.map((item) {
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.images?.url ?? 'https://placehold.co/60x60',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    item.productName ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('Qty: ${item.quantity}'),
                  trailing: Text(
                    formatMoney(item.unitPrice ?? 0),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _SummaryRow(
                    label: 'Subtotal',
                    value: formatMoney(order.totalAmount ?? 0),
                  ),
                  if ((order.discountAmount ?? 0) > 0)
                    _SummaryRow(
                      label: 'Discount',
                      value: '-${formatMoney(order.discountAmount ?? 0)}',
                      valueColor: Colors.red,
                    ),
                  const Divider(),
                  _SummaryRow(
                    label: 'Total',
                    value: formatMoney(order.totalAmount ?? 0),
                    isBold: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          if (order.status != 'delivered' &&
              order.status != 'cancelled')
            Column(
              children: [
                _ActionButton(
                  label: 'Mark as Shipping',
                  color: Colors.blue,
                  onTap: () {
                    context
                        .read<OrderProvider>()
                        .updateOrderStatus(order.id!, 'shipping');
                  },
                ),
                const SizedBox(height: 12),
                _ActionButton(
                  label: 'Mark as Delivered',
                  color: Colors.green,
                  onTap: () {
                    context
                        .read<OrderProvider>()
                        .updateOrderStatus(order.id!, 'delivered');
                  },
                ),
                const SizedBox(height: 12),
                _ActionButton(
                  label: 'Cancel Order',
                  color: Colors.red,
                  onTap: () {
                    context
                        .read<OrderProvider>()
                        .updateOrderStatus(order.id!, 'cancelled');
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }
}