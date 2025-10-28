import 'package:recomart/config/color.dart'; 
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';

class ModernListTile extends StatelessWidget {
  const ModernListTile({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(16) : Radius.zero,
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
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
                // Title
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
                // Icon mũi tên
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

class SupportAccount extends StatefulWidget {
  const SupportAccount({super.key});

  @override
  State<SupportAccount> createState() => _SupportAccountState();
}

class _SupportAccountState extends State<SupportAccount> {
  List<Map<String, dynamic>> supportItems = [
    {'title': 'Contact & Support', 'icon': FeatherIcons.phoneCall},
    {'title': 'Frequently Asked Questions', 'icon': FeatherIcons.messageCircle},
    {'title': 'Send Feedback', 'icon': FeatherIcons.edit},
  ];

  void _handleTap(int index) {
    if (index == 0) {
      print('FE: Navigate to Contact Us');
    } else if (index == 1) {
      print('FE: Navigate to FAQ');
    } else if (index == 2) {
      print('FE: Navigate to Feedback');
    }
  }

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          children: List.generate(supportItems.length, (index) {
            return ModernListTile(
              icon: supportItems[index]['icon'],
              title: supportItems[index]['title'],
              isFirst: index == 0,
              isLast: index == supportItems.length - 1,
              onTap: () => _handleTap(index),
            );
          }),
        ),
      ),
    );
  }
}