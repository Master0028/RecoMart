import 'package:recomart/config/color.dart';
import 'package:flutter/material.dart';

class CustomAppBarMobile extends StatelessWidget
    implements PreferredSizeWidget {
  const CustomAppBarMobile({
    super.key,
    required this.title,
    this.isBack = false,
    this.actionButton = false,
    this.handleOnPressed,
  });

  final String title;
  final bool isBack;
  final bool actionButton;
  final Function()? handleOnPressed;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          color: AppColors.primary, // Màu chủ đạo cho tiêu đề
          fontWeight: FontWeight.w600, // Chữ đậm hơn
        ),
      ),
      centerTitle: true,
      leading: isBack
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.primary,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          : null,
      actions: [
        if (actionButton)
          IconButton(
            icon: Icon(
              Icons.menu_rounded,
              color: AppColors.primary,
            ),
            onPressed: handleOnPressed,
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}