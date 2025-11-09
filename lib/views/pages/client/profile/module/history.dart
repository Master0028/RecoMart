import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/utils/widget/CustomAppBarMobile.dart';
import 'package:recomart/helpers/formatMoney.dart';
import 'package:go_router/go_router.dart';

class _OrderItem {
  final String name;
  final int quantity;
  final double price;
  final String imageUrl;

  _OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.imageUrl,
  });
}

class _Order {
  final String id;
  final DateTime orderDate;
  final String status;
  final double totalAmount;
  final List<_OrderItem> items;

  _Order({
    required this.id,
    required this.orderDate,
    required this.status,
    required this.totalAmount,
    required this.items,
  });
}

final List<_Order> FE_MOCK_ORDERS = [
  _Order(
    id: 'RECO-12345',
    orderDate: DateTime.now().subtract(const Duration(days: 2)),
    status: 'DELIVERED',
    totalAmount: 25800000.0,
    items: [
      _OrderItem(name: 'Laptop X1 Carbon', quantity: 1, price: 25000000.0, imageUrl: 'https://placehold.co/svg/100x100/E8F5E9/333?text=X1'),
      _OrderItem(name: 'Mouse Logitech', quantity: 1, price: 800000.0, imageUrl: 'https://placehold.co/svg/100x100/FCE4EC/333?text=Mouse'),
    ],
  ),
  _Order(
    id: 'RECO-12300',
    orderDate: DateTime.now().subtract(const Duration(days: 5)),
    status: 'SHIPPING',
    totalAmount: 1200000.0,
    items: [
      _OrderItem(name: 'Bàn phím cơ', quantity: 1, price: 1200000.0, imageUrl: 'https://placehold.co/svg/100x100/E1F5FE/333?text=Keyboard'),
    ],
  ),
  _Order(
    id: 'RECO-12250',
    orderDate: DateTime.now().subtract(const Duration(days: 10)),
    status: 'CANCELLED',
    totalAmount: 900000.0,
    items: [
      _OrderItem(name: 'Tai nghe Bluetooth', quantity: 1, price: 900000.0, imageUrl: 'https://placehold.co/svg/100x100/FFF8E1/333?text=Headset'),
    ],
  ),
];

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, 
      appBar: const CustomAppBarMobile(
        title: 'Lịch Sử Đơn Hàng',
        isBack: true,
      ),
      body: Center( 
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: FE_MOCK_ORDERS.length,
            itemBuilder: (context, index) {
              final order = FE_MOCK_ORDERS[index];
              return _OrderCard(order: order);
            },
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final _Order order;

  const _OrderCard({required this.order});

  Map<String, dynamic> _getStatusVisuals(String status) {
    switch (status) {
      case 'DELIVERED':
        return {'color': Colors.green, 'icon': FeatherIcons.checkCircle};
      case 'SHIPPING':
        return {'color': AppColors.primary, 'icon': FeatherIcons.truck};
      case 'PENDING':
        return {'color': Colors.orange.shade700, 'icon': FeatherIcons.clock};
      case 'CANCELLED':
        return {'color': Colors.red.shade700, 'icon': FeatherIcons.xCircle};
      default:
        return {'color': Colors.grey, 'icon': FeatherIcons.helpCircle};
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusVisuals = _getStatusVisuals(order.status);
    
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          print('Navigate to Order Details: ${order.id}');
          context.push('/orders/${order.id}');
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  bool isTight = constraints.maxWidth < 400;
                  
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MÃ ĐƠN HÀNG: ${order.id}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ngày đặt: ${DateFormat('dd/MM/yyyy').format(order.orderDate)}',
                              style: const TextStyle(fontSize: 13, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        avatar: Icon(statusVisuals['icon'] as IconData, color: Colors.white, size: 16),
                        label: Text(
                          order.status,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        backgroundColor: statusVisuals['color'] as Color,
                        // SỬA: Thu nhỏ padding trên mobile hẹp
                        padding: isTight 
                            ? const EdgeInsets.symmetric(horizontal: 4, vertical: 2)
                            : const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    ],
                  );
                },
              ),
            ),
            
            const Divider(height: 1, color: Color(0xFFEEEEEE)),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.items.length,
              itemBuilder: (context, index) {
                final item = order.items[index];
                return _OrderItemTile(item: item);
              },
            ),

            Container(
              color: Colors.grey.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Tổng cộng: ',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  Text(
                    formatMoney(order.totalAmount),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  final _OrderItem item;
  const _OrderItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SvgPicture.network( 
              item.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              placeholderBuilder: (context) => Container(
                width: 60,
                height: 60,
                color: Colors.grey.shade200,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Số lượng: ${item.quantity}',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          
          // Giá
          Text(
            formatMoney(item.price),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}