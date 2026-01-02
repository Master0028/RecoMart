import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
      backgroundColor: const Color(0xFFF8F9FD),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            collapsedHeight: 100,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: _buildModernHeader(user, isLoggedIn),
            ),
          ),
          
          // Menu Section
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -30),
              child: _buildMenuContent(context, isLoggedIn),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader(UserModel? user, bool isLoggedIn) {
    const String bgUrl = "https://images.unsplash.com/photo-1614850523296-d8c1af93d400?q=80&w=1000";
    
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: bgUrl,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => Container(color: AppColors.primary),
        ),
        
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.8),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(bottom: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildAvatar(user?.avatar, isLoggedIn),
              const SizedBox(height: 15),
              Text(
                isLoggedIn ? (user?.fullName ?? 'Customer') : 'Welcome to Recomart',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              if (isLoggedIn) ...[
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(String? avatarUrl, bool isLoggedIn) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
      ),
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.white24,
        child: ClipOval(
          child: (isLoggedIn && avatarUrl != null && avatarUrl.isNotEmpty)
              ? CachedNetworkImage(
                  imageUrl: avatarUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const CupertinoActivityIndicator(),
                  errorWidget: (context, url, error) => const Icon(CupertinoIcons.person_fill, color: Colors.white, size: 50),
                )
              : const Icon(CupertinoIcons.person_fill, color: Colors.white, size: 50),
        ),
      ),
    );
  }

  Widget _buildMenuContent(BuildContext context, bool isLoggedIn) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: isLoggedIn
            ? [
                _buildMenuItem(
                  icon: CupertinoIcons.person_circle,
                  title: 'Personal Information',
                  subtitle: 'Update your profile and data',
                  color: Colors.blueAccent,
                  onTap: () => context.push('/personal-information'),
                ),
                _buildMenuItem(
                  icon: CupertinoIcons.cube_box,
                  title: 'My Orders',
                  subtitle: 'Track and manage your orders',
                  color: Colors.orangeAccent,
                  onTap: () => context.push('/my-orders'),
                ),
                _buildMenuItem(
                  icon: CupertinoIcons.shield_lefthalf_fill,
                  title: 'Security',
                  subtitle: 'Change password and settings',
                  color: Colors.teal,
                  onTap: () => context.push('/change-password'),
                ),
                const SizedBox(height: 10),
                _buildMenuItem(
                  icon: CupertinoIcons.square_arrow_right,
                  title: 'Logout',
                  subtitle: 'Sign out of your account',
                  color: Colors.redAccent,
                  isLast: true,
                  onTap: () => _handleLogout(context),
                ),
              ]
            : [
                _buildMenuItem(
                  icon: CupertinoIcons.lock_open_fill,
                  title: 'Login Now',
                  subtitle: 'Access your account features',
                  color: AppColors.primary,
                  isLast: true,
                  onTap: () => context.push('/login'),
                ),
              ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          shape: RoundedRectangleApp(borderRadius: BorderRadius.circular(20)),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A1C1E)),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          trailing: const Icon(CupertinoIcons.chevron_forward, size: 18, color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 80),
            child: Divider(height: 1, thickness: 0.6, color: Colors.grey.shade100),
          ),
      ],
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<UserProvider>().logout();
      showCustomSnackBar(context, 'Signed out successfully', type: SnackBarType.success);
      context.go('/login');
    }
  }
}

class RoundedRectangleApp extends RoundedRectangleBorder {
  const RoundedRectangleApp({super.borderRadius});
}