import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:recomart/config/color.dart'; 
import 'package:recomart/utils/widget/CustomAppBarMobile.dart';
import 'package:recomart/components/custom/snackbar.dart';

final List<Map<String, dynamic>> accountUtilities = [
  {
    'title': 'Payment Methods',
    'subtitle': 'Manage your cards & e-wallets',
    'icon': FeatherIcons.creditCard,
    'route': '/profile/payment'
  },
  {
    'title': 'Notifications',
    'subtitle': 'Control push & email alerts',
    'icon': FeatherIcons.bell,
    'route': '/profile/notifications'
  },
];

final List<Map<String, dynamic>> supportUtilities = [
  {
    'title': 'Help Center',
    'subtitle': 'Find FAQs and contact support',
    'icon': FeatherIcons.helpCircle,
    'route': '/support/faq'
  },
  {
    'title': 'Language',
    'subtitle': 'English (US)',
    'icon': FeatherIcons.globe,
    'route': '/settings/language'
  },
  {
    'title': 'Privacy Policy',
    'subtitle': 'Legal information',
    'icon': FeatherIcons.shield,
    'route': '/legal/privacy'
  },
  {
    'title': 'Rate Our App',
    'subtitle': 'We value your feedback',
    'icon': FeatherIcons.star,
    'route': '/rate-app'
  },
];

class MyUtilitiesPage extends StatelessWidget {
  const MyUtilitiesPage({super.key});

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.black87
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const CustomAppBarMobile(
        title: 'My Utilities',
        isBack: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Account Settings'),
                _buildUtilityGrid(context, accountUtilities),
                
                _buildSectionHeader('Support & Legal'),
                _buildUtilityGrid(context, supportUtilities),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUtilityGrid(BuildContext context, List<Map<String, dynamic>> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
        
        double childAspectRatio = constraints.maxWidth < 600 ? 0.85 : 1.2;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: items.length,
          shrinkWrap: true, 
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final item = items[index];
            return _UtilityCard(
              title: item['title'] as String,
              subtitle: item['subtitle'] as String,
              icon: item['icon'] as IconData,
              onTap: () {
                showCustomSnackBar(context, 'Navigating to ${item['title']}', type: SnackBarType.info);
              },
            );
          },
        );
      },
    );
  }
}

class _UtilityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _UtilityCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              
              const SizedBox(height: 12),
              
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 2, // Cho phép 2 dòng
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Text Subtitle
              Expanded(
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}