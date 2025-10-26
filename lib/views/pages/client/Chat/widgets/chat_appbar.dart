import 'package:recomart/config/color.dart';
import 'package:flutter/material.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final Color blueDark = AppColors.primary;
    final Color blueLight = AppColors.primary.withOpacity(0.8);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [blueLight, blueDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: blueDark.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.white, // Chữ trắng tinh khiết
            fontWeight: FontWeight.bold, // Chữ đậm hơn
            fontSize: 20, // Kích thước font hợp lý
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}