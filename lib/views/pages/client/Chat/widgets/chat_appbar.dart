import 'package:flutter/material.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF007AFF);
    final Color blueDark = primaryColor;
    final Color blueLight = primaryColor.withOpacity(0.8);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [blueLight, blueDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        // Logic Shadow UI
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
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
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