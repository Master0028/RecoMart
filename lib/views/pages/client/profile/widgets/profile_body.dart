import 'package:recomart/config/color.dart';
import 'package:recomart/provider/user_provider.dart';
import 'package:recomart/views/pages/client/profile/widgets/my_account.dart';
import 'package:recomart/views/pages/client/profile/widgets/order_management.dart';
import 'package:recomart/views/pages/client/profile/widgets/payment_management.dart';
import 'package:recomart/views/pages/client/profile/widgets/support.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:feather_icons/feather_icons.dart';

class ProfileBody extends StatefulWidget {
  const ProfileBody({super.key});

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'My Account', 'icon': FeatherIcons.user},
    {'title': 'Order Management', 'icon': FeatherIcons.package},
    {'title': 'Payment Method', 'icon': FeatherIcons.creditCard},
    {'title': 'Support', 'icon': FeatherIcons.helpCircle},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<UserProvider>(context, listen: false).loadUserData();
    });
  }

  Widget _buildContent(String userId) {
    switch (_selectedIndex) {
      case 0:
        return const MyAccountView();
      case 1:
        return OrderManagement(userId: userId);
      case 2:
        return const PaymentManagement();
      case 3:
        return const SupportAccount();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.userModel;
    final name = user?.fullName ?? 'Anonymous User';
    final point = user?.loyaltyPoints ?? 0;
    final avatar = user?.avatar.url;
    final userId = user?.id ?? '';

    const Color headerColor = Color(0xFF003D80);

    return Column(
      children: [
        // === HEADER ===
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 40, bottom: 20, left: 16, right: 16),
          decoration: const BoxDecoration(
            color: headerColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
            ],
          ),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.secondary, width: 3),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade200,
                      child: ClipOval(
                        child: avatar != null && avatar.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: avatar,
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                                placeholder: (_, __) => const CircularProgressIndicator(color: AppColors.primary),
                                errorWidget: (_, __, ___) => const Icon(FeatherIcons.user, size: 50, color: Colors.grey),
                              )
                            : const Icon(FeatherIcons.user, size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -15,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(FeatherIcons.award, color: Colors.white, size: 14),
                            const SizedBox(width: 5),
                            Text(
                              '${point.toStringAsFixed(0)} Points',
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                'Welcome, $name!',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // === TABS ===
        SizedBox(
          height: 50,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _menuItems.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = _menuItems[index];
              final isSelected = _selectedIndex == index;
              return InkWell(
                onTap: () => setState(() => _selectedIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))]
                        : [],
                  ),
                  child: Row(
                    children: [
                      Icon(item['icon'], size: 16, color: isSelected ? Colors.white : AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        item['title'],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        // === NỘI DUNG CHÍNH (Scrollable + Expanded) ===
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildContent(userId),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}