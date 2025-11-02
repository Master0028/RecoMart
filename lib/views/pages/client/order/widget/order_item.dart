import 'package:flutter/material.dart';
import 'package:recomart/config/color.dart'; 

String formatMoney(dynamic amount) {
  if (amount is int) {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VND';
  }
  return '0 VND';
}

String formatDate(String? dateString) {
  return dateString ?? '2025-10-27';
}


class OrderItem extends StatelessWidget {
  final Map<String, dynamic> order;
  final String state;

  const OrderItem({super.key, required this.order, required this.state});

  void _showOrderDetails(BuildContext context, Map<String, dynamic> order) {
    print("Mở chi tiết đơn hàng: ${order['id']}");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Order Details (FE Only)'),
        content: Text('Details for order ID: ${order['id']}'),
      ),
    );
  }

  Widget _buildActionButton({required String title, required bool isOutlined, required VoidCallback onPressed}) {
    final style = isOutlined
        ? OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary),
            foregroundColor: AppColors.primary,
          )
        : ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          );

    return isOutlined 
        ? OutlinedButton(onPressed: onPressed, style: style, child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis))
        : ElevatedButton(onPressed: onPressed, style: style, child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis));
  }


  @override
  Widget build(BuildContext context) {
    final List<dynamic>? items = order['items'] as List<dynamic>?;
    final Map<String, dynamic>? firstItem = items?.isNotEmpty == true ? items![0] : null;

    final String productName = firstItem?['productVariantName'] ?? 'No Name';
    final int totalAmount = order['totalAmount'] as int? ?? 0;
    final String imageURL = firstItem?['images']?['url'] ?? '';
    final String createdAt = order['createdAt'] as String? ?? '';
    final int itemLength = items?.length ?? 0;

    Color statusColor;
    String statusText;

    switch (state) {
      case 'PENDING':
        statusColor = AppColors.primary;
        statusText = 'Pending';
        break;
      case 'SHIPPING':
        statusColor = AppColors.primary;
        statusText = 'Shipping';
        break;
      case 'CANCELLED':
        statusColor = AppColors.red;
        statusText = 'Cancelled';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageURL,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatMoney(totalAmount),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Order ID và Số lượng
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Quantity: $itemLength",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              Text(
                formatDate(createdAt),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha((0.1 * 255).toInt()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ),

              // Nút thao tác theo trạng thái
              if (state == 'PENDING')
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: _buildActionButton(
                        isOutlined: true,
                        title: "Cancel",
                        onPressed: () {
                          print("Cancel order: ${order['id']}");
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 100,
                      child: _buildActionButton(
                        isOutlined: false,
                        title: "Details",
                        onPressed: () {
                          _showOrderDetails(context, order);
                        },
                      ),
                    ),
                  ],
                )
              else if (state == 'SHIPPING')
                SizedBox(
                  width: 120,
                  child: _buildActionButton(
                    isOutlined: false,
                    title: "Track",
                    onPressed: () {
                      print("Track order: ${order['id']}");
                    },
                  ),
                )
              else
                SizedBox(
                  width: 120,
                  child: _buildActionButton(
                    isOutlined: false,
                    title: "Order Again",
                    onPressed: () {
                      print("Order Again: ${order['id']}");
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}