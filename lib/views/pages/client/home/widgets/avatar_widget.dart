import 'package:go_router/go_router.dart';
import 'package:recomart/components/custom/bottom_navigation_bar.dart';
import 'package:recomart/components/custom/cart.dart';
import 'package:recomart/components/custom/snackbar.dart';
import 'package:recomart/provider/user_provider.dart';
import 'package:recomart/routes/app_routes.dart';
import 'package:recomart/utils/responsive.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvatarWidget extends StatelessWidget {
  const AvatarWidget({ // Thêm const constructor
    super.key,
    this.userName,
    this.userId,
  });

  final String? userName;
  final String? userId;

  final List<String> recentSearches = const [ // Thêm const cho danh sách hằng số
    "Macbook",
    "Lenovo",
    "Asus",
    "Chuột không dây",
    "Bàn phím cơ",
    "Màn hình ",
    "Tai nghe Gaming"
  ];

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final avatarUrl = userProvider.userModel?.avatar.url;
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Responsive.isDesktop(context)
                  ? const SizedBox() // Kích thước trống để giữ vị trí
                  : const SizedBox(),

              Responsive.isDesktop(context)
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(
                            FeatherIcons.search,
                            size: 25,
                          ),
                          onPressed: () {
                            context.push('/search', extra: recentSearches);
                          },
                        ),
                        const SizedBox(width: 10),
                        const CartWidget(),
                        const SizedBox(width: 10),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: const CartWidget(),
                    ),
                            
              SizedBox(
                height: 50,
                child: PopupMenuButton<String>(
                  color: Colors.white,
                  onSelected: (value) {
                    _handleMenuSelection(value, context);
                  },
                  offset: const Offset(0, 50),
                  itemBuilder: (BuildContext context) {
                    return [
                      if (userId != null && Responsive.isDesktop(context))
                        PopupMenuItem<String>(
                          value: 'profile',
                          child: const Row(
                            children: [
                              Icon(CupertinoIcons.person),
                              SizedBox(width: 8),
                              Text('Profile'),
                            ],
                          ),
                        ),
                      PopupMenuItem<String>(
                        value: 'home',
                        child: const Row( // Thêm const
                          children: [
                            Icon(CupertinoIcons.square_grid_2x2),
                            SizedBox(width: 8),
                            Text('Home'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: userId != null ? 'logout' : 'login',
                        child: Row(
                          children: [
                            Icon(
                              userId != null
                                  ? Icons.logout_rounded
                                  : CupertinoIcons.arrow_right_circle,
                            ),
                            const SizedBox(width: 8), // Thêm const
                            Text(
                              userId != null ? 'Logout' : 'Login',
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                  child: CircleAvatar(
                    backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl)
                        : const AssetImage('assets/images/profile.jpg')
                            as ImageProvider,
                    radius: Responsive.isDesktop(context) ? 25 : 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleMenuSelection(String value, BuildContext context) async {
    switch (value) {
      case 'profile':
        context.go('/profile');
        break;
      case 'home':
        context.go('/home');
        break;
      case 'login':
        context.go('/login');
        break;
      case 'logout':
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('accessToken');
        await prefs.remove('user');
        await prefs.remove('cart'); // Xử lý Giỏ hàng
        await prefs.remove('isCartSynced'); // Xử lý trạng thái Giỏ hàng
        if (context.mounted) {
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          userProvider.clearUser();
          showCustomSnackBar(context, 'Sign out successfully',
              type: SnackBarType.success);
        }
        break;
      default:
        break;
    }
  }
}
