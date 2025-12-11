import 'package:firebase_auth/firebase_auth.dart';
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
          const SnackBar(content: Text('Navigate to Cart')), // Translated
        );
      },
    );
  }
}

class AvatarWidget extends StatelessWidget {
  const AvatarWidget({super.key});

  // Translated the search keywords to English
  final List<String> recentSearches = const [ 
    "Macbook", "Lenovo", "Asus", "Wireless Mouse", 
    "Mechanical Keyboard", "Monitor", "Gaming Headset"
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final User? currentUser = snapshot.data;
        final bool isUserLoggedIn = currentUser != null;
        
        final String avatarUrl = currentUser?.photoURL ?? 
            "https://placehold.co/100x100/A0C0E0/ffffff?text=${isUserLoggedIn ? 'U' : 'G'}";

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
                          children: [
                            IconButton(
                              icon: const Icon(FeatherIcons.search, size: 25),
                              onPressed: () => context.push('/search', extra: recentSearches),
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
                      onSelected: (value) => _handleMenuSelection(value, context),
                      offset: const Offset(0, 50),
                      itemBuilder: (BuildContext context) {
                        return [
                          if (isUserLoggedIn) 
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
                                Icon(isUserLoggedIn ? Icons.logout_rounded : CupertinoIcons.arrow_right_circle),
                                const SizedBox(width: 8), 
                                Text(isUserLoggedIn ? 'Logout' : 'Login'),
                              ],
                            ),
                          ),
                        ];
                      },
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(avatarUrl),
                        radius: Responsive.isDesktop(context) ? 25 : 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
        await FirebaseAuth.instance.signOut();
        context.go('/login');
        showCustomSnackBar(context, 'Logged out successfully', type: SnackBarType.success);
        break;
      default:
        break;
    }
  }
}