import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/provider/user_provider.dart';

class ProfileBody extends StatefulWidget {
  const ProfileBody({super.key});

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUserInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        if (userProvider.loading) {
          return const Center(key: ValueKey('loading_state'), child: CircularProgressIndicator());
        }

        final userInfo = userProvider.userInfo;
        final userName = userInfo?.fullName ?? userProvider.userName;
        final userAvatar = userInfo?.avatar ?? '';
        final loyaltyPoints = userInfo?.loyaltyPoints ?? 0;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: CustomScrollView(
            key: const ValueKey('profile_scroll_view'),
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                          ),
                        ),
                      ),
                      Positioned(
                        top: -50,
                        right: -50,
                        child: CircleAvatar(
                          radius: 100,
                          backgroundColor: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          _buildModernAvatar(userAvatar),
                          const SizedBox(height: 12),
                          Text(
                            userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _buildPointBadge(loyaltyPoints),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildQuickStats(),
                      const SizedBox(height: 24),
                      _buildMenuSection(context, userProvider.userId),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernAvatar(String url) {
    return Container(
      key: const ValueKey('avatar_container'),
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
      child: CircleAvatar(
        radius: 45,
        backgroundColor: Colors.white,
        child: ClipOval(
          child: url.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  width: 90,
                  height: 90,
                  placeholder: (_, __) => const CircularProgressIndicator(strokeWidth: 2),
                  errorWidget: (_, __, ___) => const Icon(FeatherIcons.user, size: 40),
                )
              : const Icon(FeatherIcons.user, size: 40),
        ),
      ),
    );
  }

  Widget _buildPointBadge(num points) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars, color: Colors.amber, size: 16),
          const SizedBox(width: 4),
          Text(
            "$points Points",
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItem("Wishlist", "12"),
          _verticalDivider(),
          _statItem("Vouchers", "5"),
          _verticalDivider(),
          _statItem("Reviews", "48"),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _verticalDivider() => Container(height: 30, width: 1, color: Colors.grey.shade200);

  Widget _buildMenuSection(BuildContext context, String userId) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Account Settings"),
        _menuTile(FeatherIcons.user, "Profile Info", "Change your basic info", () {
          context.push('/personal-information');
        }),
        _menuTile(FeatherIcons.mapPin, "Shipping Address", "Manage your delivery locations", () {
          context.push('/address');
        }),
        _menuTile(FeatherIcons.lock, "Change Password", "Secure your account", () {
          context.push('/change-password');
        }),
        _menuTile(FeatherIcons.menu, "Utilities", "Have some utilities", () {
          context.push('/utilities');
        }),

        const SizedBox(height: 24),

        _buildSectionTitle("My Orders"),
        _menuTile(FeatherIcons.package, "Order History", "View all your past purchases", () {
          context.push('/history');
        }),
        _menuTile(FeatherIcons.truck, "Track Order", "Check status of current orders", () {
          context.push('/history?tab=shipping');
        }),

        const SizedBox(height: 24),

        _buildSectionTitle("Payment Methods"),
        _menuTile(FeatherIcons.creditCard, "ATM / Bank Cards", "Manage linked bank accounts", () {
          context.push('/atm');
        }),
        _menuTile(FeatherIcons.tablet, "E-Wallets", "Momo, ZaloPay, ShopeePay", () {
          context.push('/e-wallets');
        }),

        const SizedBox(height: 24),

        _buildSectionTitle("More"),
        _menuTile(FeatherIcons.messageSquare, "Help Center", "FAQs and Live Support", () {
          context.push('/help-support');
        }),
        _menuTile(FeatherIcons.info, "About Recomart", "Terms and Privacy Policy", () {
          context.push('/about');
        }),
        const SizedBox(height: 12),
        _menuTile(FeatherIcons.logOut, "Logout", null, () {
          _showLogoutDialog(context, userProvider);
        }, isExit: true),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, UserProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await provider.logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _menuTile(IconData icon, String title, String? subtitle, VoidCallback onTap, {bool isExit = false}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      opaque: false,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isExit ? Colors.red.withOpacity(0.1) : Colors.transparent),
        ),
        child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isExit ? Colors.red.shade50 : AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: isExit ? Colors.red : AppColors.primary),
          ),
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w600, color: isExit ? Colors.red : Colors.black87),
          ),
          subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
          trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        ),
      ),
    );
  }
}