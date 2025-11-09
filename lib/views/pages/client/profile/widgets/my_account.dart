import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recomart/components/custom/snackbar.dart';
import 'package:recomart/config/color.dart';

final Map<String, dynamic> FE_USER_INFO = {
  'fullName': 'FE User Name',
  'email': 'fe.user@email.com',
  'phone': '0123456789',
  'address': 'District 1, HCM City',
  'avatar': {'url': 'https://picsum.photos/200'},
};


class ModernAccountListTile extends StatelessWidget {
  const ModernAccountListTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
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
  final bool isExistUser = true; 
  final Map<String, dynamic>? userInfo = FE_USER_INFO;
  
  List<Map<String, dynamic>> myAccountItems = [
    {'title': 'Personal Information', 'icon': CupertinoIcons.person, 'type': 'auth'},
    {'title': 'My Utilities', 'icon': CupertinoIcons.square_grid_2x2, 'type': 'general'},
    {'title': 'Change Password', 'icon': CupertinoIcons.lock, 'type': 'auth'},
    {'title': 'Address', 'icon': CupertinoIcons.location_north, 'type': 'general'},
    {'title': 'Switch Account/Logout', 'icon': CupertinoIcons.arrow_right_square, 'type': 'auth'},
  ];
  
  Future<void> _handleLogout() async {
    showCustomSnackBar(context, 'Logged out successfully!', type: SnackBarType.success);
    context.go('/login');
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    final visibleItems = List<Map<String, dynamic>>.from(myAccountItems).where((item) {
      if (item['title'] == 'Personal Information' || item['title'] == 'Change Password') {
        return isExistUser;
      }
      if (item['title'] == 'Switch Account/Logout') {
        return true;
      }
      return true;
    }).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...visibleItems.map((item) {
            return ModernAccountListTile(
              icon: item['icon'],
              title: item['title'] == 'Switch Account/Logout' 
                  ? (isExistUser ? 'Đăng Xuất' : 'Switch Account/Logout') 
                  : item['title'],
              onTap: () {
                switch (item['title']) {
                  case 'Personal Information':
                    context.push('/personal-information');
                    break; 
                  case 'My Utilities':
                    context.push('/utilities');
                    showCustomSnackBar(context, 'Chuyển đến trang Tiện ích của tôi', type: SnackBarType.info);
                    break;
                  case 'Change Password':
                    context.push('/change-password'); 
                    break;
                  case 'Address':
                    context.push('/address');
                    break;
                  case 'Switch Account/Logout':
                    if (isExistUser) {
                      _handleLogout();
                    } else {
                      showCustomSnackBar(context, 'Chuyển đến màn hình Đăng nhập', type: SnackBarType.info);
                      context.push('/login');
                    }
                    break;
                }
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}