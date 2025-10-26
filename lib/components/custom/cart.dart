import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CartWidget extends StatelessWidget {
  const CartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        context.push('/cart');
      },
      icon: Icon(
        FeatherIcons.shoppingCart,
        color: Colors.black,
        size: 25,
      ),
    );
  }
}
