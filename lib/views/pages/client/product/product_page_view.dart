import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:recomart/views/pages/client/home/widgets/appBar_widget.dart';
import 'package:recomart/views/pages/client/product/product_page_body.dart';
import 'package:flutter/material.dart';

class ProductPageView extends StatefulWidget {
  const ProductPageView({super.key, this.categoryId});

  final String? categoryId;

  @override
  State<ProductPageView> createState() => _ProductPageViewState();
}

class _ProductPageViewState extends State<ProductPageView> {
  final GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) runAddToCartAnimation;

  @override
  Widget build(BuildContext context) {
    return AddToCartAnimation(
      cartKey: cartKey,
      height: 30,
      width: 30,
      opacity: 0.85,
      dragAnimation: const DragToCartAnimationOptions(rotation: true),
      jumpAnimation: const JumpAnimationOptions(),
      createAddToCartAnimation: (runAddToCartAnimation) {
        this.runAddToCartAnimation = runAddToCartAnimation;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBarHomeCustom(cartKey: cartKey),
        body: ProductPageBody(
          categoryId: widget.categoryId,
        ),
      ),
    );
  }
}