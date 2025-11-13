import 'package:recomart/config/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:go_router/go_router.dart';

class OrderManagement extends StatefulWidget {
  const OrderManagement({super.key, required this.userId});

  final String userId;

  @override
  State<OrderManagement> createState() => _OrderManagementState();
}

class _OrderManagementState extends State<OrderManagement> {
  List<Map<String, dynamic>> orderItems = [
    {
      'title': 'Order History',
      'icon': FeatherIcons.archive,
      'route': '/history'
    },
  ];

  void _handleNavigation(BuildContext context, String routeName) {
    if (context.mounted) {
      context.push(routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isExistUser = widget.userId.isNotEmpty;

    if (!isExistUser) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FeatherIcons.lock,
              size: 60,
              color: AppColors.primary.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            const Text(
              '🔒 Access Restricted',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please login to view and manage your orders securely.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _handleNavigation(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Go to Login',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: List.generate(orderItems.length, (index) {
            final item = orderItems[index];
            return ModernOrderListTile(
              icon: item['icon'],
              title: item['title'],
              isFirst: index == 0,
              isLast: index == orderItems.length - 1,
              onTap: () {
                _handleNavigation(context, item['route']);
              },
            );
          }),
        ),
      ),
    );
  }
}

class ModernOrderListTile extends StatelessWidget {
  const ModernOrderListTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_forward,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
            if (!isLast)
              Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 56.0),
                child: Divider(
                  color: Colors.grey.shade200,
                  thickness: 1,
                  height: 0,
                ),
              ),
          ],
        ),
      ),
    );
  }
}