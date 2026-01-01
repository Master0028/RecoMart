import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:recomart/components/custom/snackbar.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/models/user.model.dart';
import 'package:recomart/provider/user_provider.dart';

class MyAccountView extends StatelessWidget {
  const MyAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final bool isLoggedIn = userProvider.isLoggedIn;
    final UserModel? user = userProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildPremiumHeader(context, user, isLoggedIn),
            const SizedBox(height: 25),
            _buildMenuSection(context, isLoggedIn),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(BuildContext context, UserModel? user, bool isLoggedIn) {
    const String bgUrl = "https://images.unsplash.com/photo-1557683316-973673baf926?q=80&w=1000";
    final avatarUrl = user?.avatar;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          height: 240,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(bgUrl),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.6)],
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
            ),
          ),
        ),
        Positioned(
          top: 60,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: (isLoggedIn && avatarUrl != null && avatarUrl.isNotEmpty)
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: (avatarUrl == null || avatarUrl.isEmpty)
                      ? const Icon(CupertinoIcons.person_fill, size: 55, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isLoggedIn ? (user?.fullName ?? 'Customer') : 'Welcome',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black45, offset: Offset(0, 2))],
                ),
              ),
              if (isLoggedIn)
                Text(
                  user?.email ?? '',
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context, bool isLoggedIn) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Column(
          children: isLoggedIn 
            ? [
                _buildMenuItem(
                  icon: CupertinoIcons.person_crop_circle_fill,
                  title: 'Personal Information',
                  color: Colors.blue,
                  onTap: () => context.push('/personal-information'),
                ),
                _buildMenuItem(
                  icon: CupertinoIcons.bag_fill,
                  title: 'My Orders',
                  color: Colors.orange,
                  onTap: () => context.push('/my-orders'),
                ),
                _buildMenuItem(
                  icon: CupertinoIcons.lock_shield_fill,
                  title: 'Change Password',
                  color: Colors.green,
                  onTap: () => context.push('/change-password'),
                ),
                _buildMenuItem(
                  icon: CupertinoIcons.power,
                  title: 'Logout',
                  color: Colors.red,
                  isLast: true,
                  onTap: () => _handleLogout(context),
                ),
              ]
            : [
                _buildMenuItem(
                  icon: CupertinoIcons.arrow_right_square_fill,
                  title: 'Login Now',
                  color: AppColors.primary,
                  isLast: true,
                  onTap: () => context.push('/login'),
                ),
              ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          trailing: const Icon(CupertinoIcons.chevron_right, size: 16, color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        ),
        if (!isLast) Divider(height: 1, thickness: 0.5, color: Colors.grey[200], indent: 70),
      ],
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Confirm'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          CupertinoDialogAction(child: const Text('Cancel'), onPressed: () => Navigator.pop(context, false)),
          CupertinoDialogAction(
            isDestructiveAction: true, 
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<UserProvider>().logout();
      showCustomSnackBar(context, 'Goodbye!', type: SnackBarType.success);
      context.go('/login');
    }
  }
}