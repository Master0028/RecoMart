import 'package:go_router/go_router.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recomart/components/custom/snackbar.dart';

class Responsive {
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1000;
  }
}

class _MockCartWidget extends StatelessWidget {
  const _MockCartWidget();
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(FeatherIcons.shoppingCart, size: 25),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chuyển đến giỏ hàng (Mock)'))
        );
      },
    );
  }
}

class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    super.key,
    this.userName,
    this.userId,
  });

  final String? userName;
  final String? userId;

  final List<String> recentSearches = const [ 
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
    const String mockAvatarUrl = "https://placehold.co/100x100/A0C0E0/ffffff?text=U";
    final bool isUserLoggedIn = userId != null; 
    
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [              
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
                        const _MockCartWidget(),
                        const SizedBox(width: 10),
                      ],
                    )
                  : const Padding(
                      padding: EdgeInsets.only(right: 10.0),
                      child: _MockCartWidget(),
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
                      if (isUserLoggedIn && Responsive.isDesktop(context))
                        const PopupMenuItem<String>(
                          value: 'profile',
                          child: Row(
                            children: [
                              Icon(CupertinoIcons.person),
                              SizedBox(width: 8),
                              Text('Profile'),
                            ],
                          ),
                        ),
                      const PopupMenuItem<String>(
                        value: 'home',
                        child: Row( 
                          children: [
                            Icon(CupertinoIcons.square_grid_2x2),
                            SizedBox(width: 8),
                            Text('Home'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: isUserLoggedIn ? 'logout' : 'login',
                        child: Row(
                          children: [
                            Icon(
                              isUserLoggedIn
                                  ? Icons.logout_rounded
                                  : CupertinoIcons.arrow_right_circle,
                            ),
                            const SizedBox(width: 8), 
                            Text(
                              isUserLoggedIn ? 'Logout' : 'Login',
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(mockAvatarUrl) as ImageProvider,
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

  void _handleMenuSelection(String value, BuildContext context) {
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
        context.go('/login');
        showCustomSnackBar(context, 'Đăng xuất thành công (Mock)');
        break;
      default:
        break;
    }
  }
}
