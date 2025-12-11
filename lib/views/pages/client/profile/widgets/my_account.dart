import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recomart/components/custom/snackbar.dart';
import 'package:recomart/config/color.dart';

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
  Map<String, dynamic>? userInfo;
  bool isLoading = true;
  bool isExistUser = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: currentUser.email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          if (mounted) {
            setState(() {
              userInfo = querySnapshot.docs.first.data();
              isExistUser = true;
              isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              userInfo = {
                'fullName': currentUser.displayName ?? 'No Name',
                'email': currentUser.email,
                'avatar': currentUser.photoURL ?? 'https://placehold.co/200',
              };
              isExistUser = true;
              isLoading = false;
            });
          }
        }
      } catch (e) {
        print("Error loading user: $e");
        if (mounted) setState(() => isLoading = false);
      }
    } else {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      showCustomSnackBar(context, 'Logout successful!', type: SnackBarType.success);
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    Widget buildUserHeader() {
      if (!isExistUser || userInfo == null) {
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("You are not logged in."),
        );
      }
      
      String avatarUrl = "https://placehold.co/200";
      
      final dynamic avatarData = userInfo!['avatar'];
      
      if (avatarData is Map) {
        avatarUrl = avatarData['url'] ?? avatarUrl;
      } else if (avatarData is String) {
        if (avatarData.isNotEmpty) {
          avatarUrl = avatarData;
        }
      }

      return Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(avatarUrl),
              onBackgroundImageError: (_, __) {
                // Handle image error if necessary
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userInfo?['fullName'] ?? userInfo?['name'] ?? 'User',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(userInfo?['email'] ?? '', style: const TextStyle(color: Colors.grey)),
                  
                  if (userInfo?['phone'] != null && userInfo!['phone'].toString().isNotEmpty)
                    Text(userInfo!['phone'], style: const TextStyle(color: Colors.grey)),
                ],
              ),
            )
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          buildUserHeader(),
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
                showCustomSnackBar(context, 'Loyalty Points: ${userInfo?['loyaltyPoints'] ?? 0}', type: SnackBarType.info);
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
            onTap: () {
              if (isExistUser) {
                _handleLogout();
              } else {
                context.push('/login');
              }
            },
          ),
        ],
      ),
    );
  }
}