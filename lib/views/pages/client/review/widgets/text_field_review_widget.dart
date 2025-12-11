import 'package:flutter/material.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/utils/responsive.dart';

class TextFieldReviewWidget extends StatelessWidget {
  const TextFieldReviewWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: ShapeBorder.lerp(
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AppColors.grey)),
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AppColors.grey)),
            0.5),
        color: AppColors.white,
        child: Container(
          width: Responsive.isMobile(context)
              ? MediaQuery.sizeOf(context).width * 0.9
              : MediaQuery.sizeOf(context).width * 0.7,
          padding: const EdgeInsets.all(8.0),
          child: const TextField(
            maxLines: 5,
            decoration:
                InputDecoration.collapsed(hintText: "Write your review here"),
          ),
        ));
  }
}