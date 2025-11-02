import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:recomart/helpers/formatMoney.dart'; 

class TitleProduct extends StatelessWidget {
  const TitleProduct(
      {super.key,
      required this.title,
      required this.price,
      this.oldPrice,
      this.discount = 0.0});
  
  final String title;
  final double price;
  final int? oldPrice;
  final double? discount;

  @override
  Widget build(BuildContext context) {
    final double discountedPrice = price * (1 - (discount ?? 0.0));

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: lerpDouble(
                16, 18, (MediaQuery.of(context).size.width - 300) / 300),
            fontWeight: FontWeight.bold,
          ),
        ),
        Wrap(
          spacing: 10,
          children: [
            Text(
              formatMoney(price),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                decoration: TextDecoration.lineThrough,
              ),
              softWrap: true,
            ),
            Text(
              formatMoney(discountedPrice),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              softWrap: true,
            ),
          ],
        )
      ],
    );
  }
}