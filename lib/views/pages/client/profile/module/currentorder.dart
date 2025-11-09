import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:intl/intl.dart';
import 'package:recomart/config/color.dart'; 
import 'package:recomart/utils/widget/CustomAppBarMobile.dart'; 

String formatMoney(double amount) {
  final format = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
  return format.format(amount);
}

class OrderItemModelFE {
  final String productName;
  final int quantity;
  OrderItemModelFE({required this.productName, required this.quantity});
}

class OrderModelFE {
  final String id;
  final String status;
  final double totalAmount;
  final DateTime orderDate;
  final List<OrderItemModelFE> items;

  OrderModelFE({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.orderDate,
    required this.items,
  });
}

final List<OrderModelFE> FE_CURRENT_ORDERS = [
  OrderModelFE(
    id: 'ORDER-123',
    status: 'SHIPPING',
    totalAmount: 25800000.0,
    orderDate: DateTime.now().subtract(const Duration(days: 1)),
    items: [
      OrderItemModelFE(productName: 'Laptop X1 Carbon', quantity: 1),
      OrderItemModelFE(productName: 'Mouse Logitech', quantity: 1),
    ],
  ),
  OrderModelFE(
    id: 'ORDER-122',
    status: 'PENDING',
    totalAmount: 1500000.0,
    orderDate: DateTime.now().subtract(const Duration(hours: 2)),
    items: [
      OrderItemModelFE(productName: 'Bàn phím cơ', quantity: 1),
    ],
  ),
];

class CurrentOrderPage extends StatelessWidget {
  const CurrentOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<OrderModelFE> orders = FE_CURRENT_ORDERS;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: const CustomAppBarMobile(
        title: 'Đơn Hàng Của Tôi',
        isBack: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return OrderTimelineCard(order: orders[index]);
            },
            separatorBuilder: (context, index) => const SizedBox(height: 16),
          ),
        ),
      ),
    );
  }
}

class OrderTimelineCard extends StatelessWidget {
  final OrderModelFE order;

  const OrderTimelineCard({super.key, required this.order});

  Map<String, dynamic> _getStatusInfo(String status) {
    if (status == 'SHIPPING') {
      return {
        'title': 'Đang Giao Hàng',
        'subtitle': 'Đơn hàng của bạn đang trên đường vận chuyển',
        'icon': FeatherIcons.truck,
        'color': AppColors.primary,
        'step': 2, 
      };
    }
    return {
      'title': 'Đang Chờ Xử Lý',
      'subtitle': 'Chúng tôi đang chuẩn bị đơn hàng của bạn',
      'icon': FeatherIcons.package,
      'color': Colors.orange.shade700,
      'step': 1,
    };
  }

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(order.status);
    final activeColor = statusInfo['color'] as Color;
    final int activeStep = statusInfo['step'] as int;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đơn hàng: ${order.id}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ngày đặt: ${DateFormat('dd/MM/yyyy').format(order.orderDate)}',
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: activeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(statusInfo['icon'] as IconData, color: activeColor, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        statusInfo['title'] as String,
                        style: TextStyle(
                          color: activeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusInfo['subtitle'] as String,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                // Dòng thời gian
                _buildTimeline(activeStep, activeColor),
              ],
            ),
          ),

          Container(
            color: Colors.grey.shade50,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${order.items.length} sản phẩm',
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    Text(
                      formatMoney(order.totalAmount),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: order.items.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                          // Giả lập ảnh sản phẩm
                          image: DecorationImage(
                            image: NetworkImage('https://placehold.co/80x80/EEEEEE/AAAAAA?text=${order.items[index].productName[0]}'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(int activeStep, Color activeColor) {
    return Row(
      children: [
        _buildTimelineStep(
          icon: FeatherIcons.package,
          label: 'Đã đặt hàng',
          isActive: activeStep >= 1,
          isFirst: true,
          activeColor: activeColor,
        ),
        _buildTimelineConnector(isActive: activeStep >= 2, activeColor: activeColor),
        _buildTimelineStep(
          icon: FeatherIcons.truck,
          label: 'Đang giao',
          isActive: activeStep >= 2,
          activeColor: activeColor,
        ),
        _buildTimelineConnector(isActive: activeStep >= 3, activeColor: activeColor),
        _buildTimelineStep(
          icon: FeatherIcons.checkCircle,
          label: 'Đã nhận',
          isActive: activeStep >= 3,
          isLast: true,
          activeColor: activeColor,
        ),
      ],
    );
  }

  Widget _buildTimelineStep({
    required IconData icon,
    required String label,
    required bool isActive,
    required Color activeColor,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final color = isActive ? activeColor : Colors.grey.shade400;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isActive ? activeColor.withOpacity(0.1) : Colors.grey.shade200,
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: 1.5,
            ),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.black87 : Colors.grey.shade600,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineConnector({required bool isActive, required Color activeColor}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 28.0),
        child: Divider(
          height: 2,
          thickness: 2,
          color: isActive ? activeColor : Colors.grey.shade300,
        ),
      ),
    );
  }
}