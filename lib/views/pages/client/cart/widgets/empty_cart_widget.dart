import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recomart/config/color.dart';

class EmptyCartView extends StatefulWidget {
  const EmptyCartView({super.key});

  @override
  State<EmptyCartView> createState() => _EmptyCartViewState();
}

class _EmptyCartViewState extends State<EmptyCartView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.9), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 120,
                  color: AppColors.primary.withOpacity(0.7),
                ),
              ),
            ),
            const SizedBox(height: 32.0),
            const Text(
              "Your Cart Is Looking Lonely...",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12.0),
            const Text(
              "Start adding some high-tech gadgets to your digital inventory!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 32.0),
            SizedBox(
              width: 250,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.go('/home');
                },
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                label: const Text(
                  "Explore Products",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: AppColors.primary.withOpacity(0.5),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}