import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import 'package:recomart/helpers/formatMoney.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/utils/widget/CustomAppBarMobile.dart';
import 'package:recomart/models/order.model.dart';
import 'package:recomart/provider/order_provider.dart';

import '../../../../../pattern/singleton.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key, required this.userId});
  final String userId;

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  String selectedTab = 'All';

  final Map<String, String> _statusMap = {
    'All': '',
    'Pending': 'pending',
    'Shipping': 'shipping',
    'Delivered': 'delivered',
    'Cancelled': 'cancelled',
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<OrderProvider>(context, listen: false).fetchOrderHistory(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderProvider>(context);
    final orders = provider.orders;

    // Filter orders by status
    final filter = _statusMap[selectedTab];
    final filteredOrders = (filter == null || filter.isEmpty)
        ? orders
        : orders.where((o) => o.status == filter).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: const CustomAppBarMobile(title: 'My Orders', isBack: true),
      body: Column(
        children: [
          // Tabs
          Container(
            height: 48,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _statusMap.keys.map((label) {
                final isActive = label == selectedTab;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: isActive,
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.grey.shade200,
                    labelStyle: TextStyle(
                      color: isActive ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => setState(() => selectedTab = label),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Main Content
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredOrders.isEmpty
                ? const Center(child: Text('No orders found.'))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                return _OrderCard(order: filteredOrders[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  Map<String, dynamic> _getStatusVisuals(String? status) {
    switch (status) {
      case 'DELIVERED':
        return {'color': Colors.green, 'icon': FeatherIcons.checkCircle, 'label': 'Delivered'};
      case 'SHIPPING':
        return {'color': AppColors.primary, 'icon': FeatherIcons.truck, 'label': 'Shipping'};
      case 'PENDING':
        return {'color': Colors.orange.shade700, 'icon': FeatherIcons.clock, 'label': 'Pending'};
      case 'CANCELLED':
        return {'color': Colors.red.shade700, 'icon': FeatherIcons.xCircle, 'label': 'Cancelled'};
      default:
        return {'color': Colors.grey, 'icon': FeatherIcons.helpCircle, 'label': 'Unknown'};
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusVisuals = _getStatusVisuals(order.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.push('/orders/${order.id}'),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order ID: ${order.id}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(
                          'Date: ${order.createdAt != null ? DateFormat('MM/dd/yyyy').format(order.createdAt!) : '--/--/----'}',
                          style: const TextStyle(color: Colors.black54, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    avatar: Icon(statusVisuals['icon'] as IconData, size: 16, color: Colors.white),
                    label: Text(
                      statusVisuals['label'],
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: statusVisuals['color'],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Items
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.items?.length ?? 0,
              itemBuilder: (context, index) {
                final item = order.items![index];
                return _OrderItemTile(item: item);
              },
            ),

            // Total + Action
            Container(
              color: Colors.grey.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total:', style: TextStyle(color: Colors.black54, fontSize: 15)),
                  Text(
                    formatMoney(order.totalAmount ?? 0),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 17),
                  ),
                ],
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SvgPicture.network(
              item.images?.url ?? 'https://placehold.co/60x60',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              placeholderBuilder: (_) => Container(
                width: 60,
                height: 60,
                color: Colors.grey.shade200,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('Qty: ${item.quantity}',
                    style: const TextStyle(color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(formatMoney(item.unitPrice ?? 0),
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 15)),
        ],
      ),
    );
  }
}