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
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08), 
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF333333), 
        ),
      ),
      trailing: Icon(
        CupertinoIcons.chevron_forward,
        color: Colors.grey.shade400,
        size: 20,
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
      print('Navigate to Contact Us');
    } else if (index == 1) {
      print('Navigate to FAQ');
    } else if (index == 2) {
      print('Navigate to Feedback');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero, 
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), 
          side: BorderSide(color: Colors.grey.shade200, width: 1.0) 
        ),
        clipBehavior: Clip.antiAlias, 
        child: Column(
          children: supportItems.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> item = entry.value;

            return Column(
              children: [
                ModernListTile(
                  icon: item['icon'],
                  title: item['title'],
                  onTap: () => _handleTap(index),
                ),
                if (index < supportItems.length - 1)
                  Padding(
                    padding: const EdgeInsets.only(left: 72.0, right: 16.0),
                    child: Divider(
                      color: Colors.grey.shade200,
                      height: 1,
                      thickness: 1,
                    ),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}