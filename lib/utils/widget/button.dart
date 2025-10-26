import 'package:recomart/config/color.dart';
import 'package:flutter/material.dart';
import 'package:recomart/config/font.dart';

class ModernButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const ModernButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Góc bo tròn
          ),
          elevation: 5, 
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), 
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.white, 
            fontSize: FontSizes.medium,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}