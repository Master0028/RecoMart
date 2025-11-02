import 'package:recomart/config/color.dart';
import 'package:flutter/material.dart';

class HeaderItemData {
  final String label;
  final IconData icon;
  final String route;

  const HeaderItemData({
    required this.label,
    required this.icon,
    required this.route,
  });
}

class HeaderView extends StatelessWidget {
  const HeaderView({super.key});

  final List<HeaderItemData> _headerItems = const [
    HeaderItemData(label: "Home", icon: Icons.home_outlined, route: "home"),
    HeaderItemData(label: "Product", icon: Icons.shopping_bag_outlined, route: "product"),
    HeaderItemData(label: "Chat", icon: Icons.chat_bubble_outline, route: "chat"),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 4, // Độ nổi nhẹ
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _headerItems.map((item) {
            return _buildHeaderItem(item, context);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHeaderItem(HeaderItemData item, BuildContext context) {
    final bool isSelected = ModalRoute.of(context)?.settings.name == item.route;

    final Color itemColor = isSelected ? AppColors.primary : Colors.grey.shade600;

    return Expanded(
      child: InkWell(
        onTap: () {
          if (!isSelected) {
            Navigator.pushNamed(context, item.route);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.icon,
                color: itemColor,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, 
                  fontSize: 12,
                  color: itemColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}