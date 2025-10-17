import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MobileNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final bool isLoggedIn;
  final String role;

  const MobileNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.isLoggedIn = false,
    this.role = 'user',
  });

  // THAY ĐỔI CHÍNH 1: Thêm mục "Favorite" vào danh sách cho 'user'
  List<BottomNavigationBarItem> get _navigationItems {
    if (role == 'manager') {
      return [
        _buildNavItem(Icons.dashboard_outlined, Icons.dashboard, 0),
        _buildNavItem(Icons.support_agent_outlined, Icons.support_agent, 1),
        _buildNavItem(Icons.account_circle_outlined, Icons.account_circle, 2),
      ];
    } else { // Dành cho 'user'
      return [
        _buildNavItem(Icons.home_outlined, Icons.home, 0), // index 0: Home
        _buildNavItem(Icons.favorite_border, Icons.favorite, 1), // index 1: Favorite
        _buildNavItem(Icons.shopping_cart_outlined, Icons.shopping_cart, 2), // index 2: Cart
        _buildNavItem(Icons.receipt_long_outlined, Icons.receipt_long, 3), // index 3: Orders
        _buildNavItem(Icons.account_circle_outlined, Icons.account_circle, 4), // index 4: Profile
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: _navigationItems,
      currentIndex: selectedIndex,
      onTap: (index) {
        onItemTapped(index);

        if (role == 'manager') {
          switch (index) {
            case 0: context.go('/manager-dashboard'); break;
            case 1: context.go('/customer-service'); break;
            case 2: context.go('/manager-profile'); break;
          }
        } else {
          switch (index) {
            case 0: context.go('/'); break;
            case 1: context.go('/favorite-list'); break;
            case 2: context.go('/checkout', extra: isLoggedIn); break;
            case 3: context.go('/my-orders'); break;
            case 4: context.go('/profile'); break;
          }
        }
      },
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      elevation: 0,
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData unselectedIcon, IconData selectedIcon, int index) {
    const Color unselectedColor = Colors.blue;
    const Color selectedColor = Colors.black;

    return BottomNavigationBarItem(
      icon: Icon(unselectedIcon, color: unselectedColor),
      activeIcon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(selectedIcon, color: selectedColor),
          const SizedBox(height: 4),
          Container(
            height: 3,
            width: 20,
            decoration: BoxDecoration(
              color: selectedColor,
              borderRadius: BorderRadius.circular(10),
            ),
          )
        ],
      ),
      label: '',
    );
  }
}