import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:intl/intl.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/utils/widget/CustomAppBarMobile.dart';
import 'package:recomart/helpers/formatMoney.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OrderItem { 
  final String name;
  final int quantity;
  final double price;
  final String imageUrl;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.imageUrl,
  });
}

class MockTrackingStep {
  final String status;
  final String location;
  final DateTime timestamp;

  MockTrackingStep({
    required this.status,
    required this.location,
    required this.timestamp,
  });
}

// SỬA: Đổi tên MockOrder thành Order (cho nhất quán)
class Order {
  final String id;
  final String status;
  final DateTime estimatedDelivery;
  final double totalAmount;
  final List<OrderItem> items; // SỬA: Dùng OrderItem
  final List<MockTrackingStep> trackingHistory;
  final String shippingAddress;
  final String paymentMethod;

  Order({
    required this.id,
    required this.status,
    required this.estimatedDelivery,
    required this.totalAmount,
    required this.items,
    required this.trackingHistory,
    required this.shippingAddress,
    required this.paymentMethod,
  });
}


final Order FE_MOCK_ORDER = Order(
  id: 'RECO-12345XYZ',
  status: 'SHIPPING',
  estimatedDelivery: DateTime.now().add(const Duration(days: 2)),
  totalAmount: 25800000.0,
  shippingAddress: '123 Đường Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP. HCM',
  paymentMethod: 'Thanh toán khi nhận hàng (COD)',
  items: [
    // SỬA: Sử dụng OrderItem
    OrderItem(
      name: 'Laptop X1 Carbon (Tên sản phẩm rất dài)',
      quantity: 1,
      price: 25000000.0,
      imageUrl: 'https://placehold.co/svg/100x100/E8F0FE/007AFF?text=X1',
    ),
    OrderItem(
      name: 'Mouse Logitech Master 3S',
      quantity: 1,
      price: 800000.0,
      imageUrl: 'https://placehold.co/svg/100x100/E8F0FE/007AFF?text=Mouse',
    ),
  ],
  trackingHistory: [
    MockTrackingStep(
      status: 'Order Placed',
      location: 'Hệ thống RecoMart',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    ),
    MockTrackingStep(
      status: 'Processing',
      location: 'Kho hàng trung tâm (HCM)',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    MockTrackingStep(
      status: 'Shipped (On its way)',
      location: 'Trung tâm vận chuyển Củ Chi',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    MockTrackingStep(
      status: 'Delivered',
      location: 'Địa chỉ của bạn',
      timestamp: DateTime.now().add(const Duration(days: 2)),
    ),
  ],
);
// --- (Kết thúc Stub) ---

class OrderTrackingPage extends StatelessWidget {
  const OrderTrackingPage({super.key});

  String _formatDate(DateTime date) {
    return DateFormat('E, dd MMM yyyy').format(date);
  }

  Map<String, dynamic> _getStatusDetails(String status) {
    switch (status) {
      case 'SHIPPING':
        return {'text': 'Đang Giao Hàng', 'icon': FeatherIcons.truck, 'color': AppColors.primary};
      case 'PENDING':
        return {'text': 'Chờ Xác Nhận', 'icon': FeatherIcons.clock, 'color': Colors.orange};
      case 'DELIVERED':
        return {'text': 'Đã Giao Hàng', 'icon': FeatherIcons.checkCircle, 'color': Colors.green};
      case 'CANCELLED':
        return {'text': 'Đã Hủy', 'icon': FeatherIcons.xCircle, 'color': Colors.red};
      default:
        return {'text': 'Đang Xử Lý', 'icon': FeatherIcons.package, 'color': Colors.blueGrey};
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = FE_MOCK_ORDER;
    final statusDetails = _getStatusDetails(order.status);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: const CustomAppBarMobile(
        title: 'Theo dõi Đơn hàng',
        isBack: true,
      ),
      body: Center( 
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                _buildStatusHeader(statusDetails, order),
                
                _buildSectionHeader('Lịch sử Đơn hàng'),
                _buildTrackingTimeline(order.trackingHistory, order.status),

                _buildSectionHeader('Sản phẩm (${order.items.length})'),
                _buildOrderItemsList(order.items), // SỬA: Truyền List<OrderItem>

                _buildSectionHeader('Thông tin Chi tiết'),
                
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      return Column(
                        children: [
                          _buildInfoCard(
                            'Địa chỉ Giao hàng',
                            order.shippingAddress,
                            FeatherIcons.mapPin,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoCard(
                            'Phương thức Thanh toán',
                            order.paymentMethod,
                            FeatherIcons.creditCard,
                          ),
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            'Địa chỉ Giao hàng',
                            order.shippingAddress,
                            FeatherIcons.mapPin,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildInfoCard(
                            'Phương thức Thanh toán',
                            order.paymentMethod,
                            FeatherIcons.creditCard,
                          ),
                        ),
                      ],
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildStatusHeader(Map<String, dynamic> status, Order order) {
    return Card(
      elevation: 4,
      shadowColor: status['color'].withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: status['color'],
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(status['icon'], color: Colors.white, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status['text'],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Dự kiến giao: ${_formatDate(order.estimatedDelivery)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white30, height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Mã đơn: ${order.id}',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Tổng: ${formatMoney(order.totalAmount)}',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingTimeline(List<MockTrackingStep> history, String currentStatus) {
    final statusOrder = ['PENDING', 'PROCESSING', 'SHIPPING', 'DELIVERED'];
    final currentStatusIndex = statusOrder.indexOf(currentStatus.toUpperCase());

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final step = history[index];
          final stepStatusIndex = statusOrder.indexOf(step.status.toUpperCase().split(' ')[0]);
          bool isActive = stepStatusIndex <= currentStatusIndex;
          bool isCurrent = stepStatusIndex == currentStatusIndex;

          return _buildTimelineTile(
            step: step,
            isFirst: index == 0,
            isLast: index == history.length - 1,
            isActive: isActive,
            isCurrent: isCurrent,
          );
        },
      ),
    );
  }

  Widget _buildTimelineTile({
    required MockTrackingStep step,
    required bool isFirst,
    required bool isLast,
    required bool isActive,
    required bool isCurrent,
  }) {
    final Color activeColor = isCurrent ? AppColors.primary : Colors.green;
    final Color inactiveColor = Colors.grey.shade300;
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 2,
                height: 12,
                color: isFirst ? Colors.transparent : (isActive ? activeColor : inactiveColor),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? activeColor : inactiveColor,
                  border: Border.all(
                    color: isCurrent ? Colors.white : Colors.transparent,
                    width: 2
                  ),
                  boxShadow: isCurrent ? [
                     BoxShadow(
                       color: activeColor.withOpacity(0.5),
                       blurRadius: 8,
                       spreadRadius: 2
                     )
                  ] : null,
                ),
                child: Center(
                  child: Icon(
                    (isActive && !isCurrent) ? FeatherIcons.check : FeatherIcons.radio,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: isLast ? Colors.transparent : (isActive ? activeColor : inactiveColor),
                ),
              ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.status,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.black87 : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.location,
                    style: TextStyle(
                      fontSize: 14,
                      color: isActive ? Colors.black54 : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm - dd/MM/yyyy').format(step.timestamp),
                    style: TextStyle(
                      fontSize: 13,
                      color: isActive ? Colors.black54 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SỬA: Thay đổi tham số từ List<MockOrderItem> thành List<OrderItem>
  Widget _buildOrderItemsList(List<OrderItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          // Giả định _OrderItemTile đã được sửa ở file khác
          return _OrderItemTile(item: item); 
        },
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey.shade200,
          indent: 20,
          endIndent: 20,
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const Divider(height: 20),
          Text(
            content,
            style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET _OrderItemTile (Giả định nằm trong cùng file hoặc đã import) ---
class _OrderItemTile extends StatelessWidget {
  final OrderItem item;
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
            flex: 3,
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
          
          Flexible(
            flex: 2,
            child: Text(
              formatMoney(item.price), 
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}