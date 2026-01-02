import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/helpers/formatMoney.dart';
import 'package:recomart/models/order.model.dart';
import 'package:recomart/services/order.service.dart';
import 'package:recomart/utils/widget/CustomAppBarMobile.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final OrderService _orderService = OrderService();
  OrderModel? _order;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrderDetail();
  }

  Future<void> _loadOrderDetail() async {
    final order = await _orderService.fetchOrderById(widget.orderId);
    setState(() {
      _order = order;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        appBar: CustomAppBarMobile(title: 'Order Details', isBack: true),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_order == null) {
      return const Scaffold(
        appBar: CustomAppBarMobile(title: 'Order Details', isBack: true),
        body: Center(child: Text('Order not found')),
      );
    }

    final order = _order!;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: CustomAppBarMobile(
        title: 'Order #${order.id}',
        isBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              title: 'Order Information',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRow('Order ID', order.id ?? '--'),
                  _buildRow(
                      'Date',
                      order.createdAt != null
                          ? DateFormat('dd/MM/yyyy HH:mm')
                              .format(order.createdAt!)
                          : '--'),
                  _buildRow('Status', order.status ?? 'Unknown'),
                  _buildRow(
                      'Payment Method', order.paymentMethod ?? 'COD'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildSectionCard(
              title: 'Shipping Address',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRow('Recipient', order.userName ?? '--'),
                  _buildRow('Email', order.email ?? '--'),
                  _buildRow('Address', order.address ?? '--'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildSectionCard(
              title: 'Order Items',
              child: Column(
                children: order.items
                        ?.map((item) => _OrderItemTile(item: item))
                        .toList() ??
                    [],
              ),
            ),
            const SizedBox(height: 16),

            _buildSectionCard(
              title: 'Summary',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRow('Subtotal', formatMoney(order.totalAmount ?? 0)),
                  _buildRow('Discount',
                      '- ${formatMoney(order.discountAmount ?? 0)}'),
                  _buildRow('Points Used',
                      '${order.loyaltyPointsUsed ?? 0} points'),
                  const Divider(),
                  _buildRow(
                    'Total',
                    formatMoney(order.totalAmount ?? 0),
                    isBold: true,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (order.orderTracking != null &&
                order.orderTracking!.isNotEmpty)
              _buildSectionCard(
                title: 'Order History',
                child: Column(
                  children: order.orderTracking!.map((track) {
                    return ListTile(
                      leading: const Icon(FeatherIcons.clock, size: 18),
                      title: Text(track.status ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        track.date != null
                            ? DateFormat('dd/MM/yyyy HH:mm')
                                .format(track.date!)
                            : '--/--/----',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14, color: Colors.black54)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  final OrderItemModel item;
  const _OrderItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.images?.url ?? 'https://placehold.co/60x60',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                Text('Qty: ${item.quantity}',
                    style:
                        const TextStyle(color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(formatMoney(item.unitPrice ?? 0),
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }
}