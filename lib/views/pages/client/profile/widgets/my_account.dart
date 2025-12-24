import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:recomart/components/custom/snackbar.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/provider/user_provider.dart';

class ModernAccountListTile extends StatelessWidget {
  const ModernAccountListTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: Icon(
          CupertinoIcons.chevron_forward,
          color: Colors.grey.shade400,
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }
}

class MyAccountView extends StatefulWidget {
  const MyAccountView({super.key});

  @override
  State<MyAccountView> createState() => _MyAccountView();
}

class _MyAccountView extends State<MyAccountView> {

  Future<void> _handleLogout(BuildContext context) async {
    context.read<UserProvider>().logout();
    
    showCustomSnackBar(context, 'Logout successful!', type: SnackBarType.success);
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.users;
    // ignore: unnecessary_null_comparison
    final bool isExistUser = user != null;

    // Layout chính
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildUserHeader(user, isExistUser),
          
          const Divider(),
          
          // Menu Items
          if (isExistUser) ...[
            ModernAccountListTile(
              icon: CupertinoIcons.person,
              title: 'Personal Information',
              onTap: () => context.push('/personal-information'),
            ),
            ModernAccountListTile(
              icon: CupertinoIcons.square_grid_2x2,
              title: 'Rewards & Utilities',
              onTap: () {
                context.push('/utilities');
              },
            ),
            ModernAccountListTile(
              icon: CupertinoIcons.lock,
              title: 'Change Password',
              onTap: () => context.push('/change-password'),
            ),
          ],

          ModernAccountListTile(
            icon: isExistUser ? CupertinoIcons.arrow_right_square : CupertinoIcons.arrow_left_square,
            title: isExistUser ? 'Logout' : 'Login Now',
            subtitle: isExistUser ? null : 'Access your account',
            onTap: () {
              if (isExistUser) {
                _handleLogout(context);
              } else {
                context.push('/login');
              }
            },
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildUserHeader(dynamic user, bool isExistUser) {
    if (!isExistUser) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(CupertinoIcons.person_circle, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "Guest User",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("Please login to access full features", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    String avatarUrl = "https://placehold.co/200";
    String fullName = "User";
    String email = "";
    String? phone;

    try {
      if (user is Map) {
         avatarUrl = user['avatar'] ?? avatarUrl;
         fullName = user['fullName'] ?? user['name'] ?? fullName;
         email = user['email'] ?? "";
         phone = user['phone'];
      } else {
         avatarUrl = user.avatar ?? avatarUrl;
         fullName = user.fullName ?? fullName;
         email = user.email ?? "";
         phone = user.phone;
      }
    } catch (e) {
      print("Error parsing user data: $e");
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(avatarUrl),
            onBackgroundImageError: (_, __) => const Icon(Icons.error),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(email, style: const TextStyle(color: Colors.grey)),
                
                if (phone != null && phone.isNotEmpty)
                  Text(phone, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          )
        ],
      ),
    );
  }
}