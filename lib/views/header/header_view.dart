import 'package:flutter/material.dart';
import 'package:recomart/config/color.dart';

class HeaderItemData {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const HeaderItemData({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}

class HeaderView extends StatelessWidget {
  const HeaderView({super.key});

  final List<HeaderItemData> _headerItems = const [
    HeaderItemData(
      label: "Home",
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      route: "home",
    ),
    HeaderItemData(
      label: "Product",
      icon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag_rounded,
      route: "product",
    ),
    HeaderItemData(
      label: "Chat",
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble_rounded,
      route: "chat",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final String? currentRoute = ModalRoute.of(context)?.settings.name;

    return SafeArea(
      top: true,
      bottom: false,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 5),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _headerItems.map((item) {
            bool isSelected = false;
            
            if (currentRoute != null) {
               isSelected = currentRoute.contains(item.route); 
            }

            return Expanded(
              child: _ModernHeaderItem(
                item: item,
                isSelected: isSelected,
                onTap: () {
                  if (!isSelected) {
                    Navigator.pushNamed(context, item.route);
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ModernHeaderItem extends StatelessWidget {
  final HeaderItemData item;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModernHeaderItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                key: ValueKey(isSelected), // Key để kích hoạt animation
                size: 24,
                color: isSelected ? AppColors.primary : Colors.grey.shade400,
              ),
            ),
            
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : Colors.grey.shade400,
              ),
              child: Text(item.label),
            ),
            
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}