import 'package:flutter/material.dart';

enum SnackBarType { success, error, info, warning }

void showCustomSnackBar(
  BuildContext context,
  String message, {
  SnackBarType type = SnackBarType.error,
}) {
  Color backgroundColor;
  Color textColor;
  IconData icon;

  switch (type) {
    case SnackBarType.success:
      backgroundColor = Colors.green.shade50;
      textColor = Colors.green.shade800;
      icon = Icons.check_circle;
      break;
    case SnackBarType.error:
      backgroundColor = Colors.red.shade50;
      textColor = Colors.red.shade800;
      icon = Icons.error;
      break;
    case SnackBarType.info:
      backgroundColor = Colors.blue.shade50;
      textColor = Colors.blue.shade800;
      icon = Icons.info_outline;
      break;
    case SnackBarType.warning:
      // TODO: Handle this case.
      throw UnimplementedError();
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: textColor, fontSize: 16),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      duration: const Duration(seconds: 3),
    ),
  );
}
