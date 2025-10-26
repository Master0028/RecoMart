import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashImageViewWidget extends StatelessWidget {
  const SplashImageViewWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        'assets/lotties/splash.json', 
        width: 300, 
        height: 300
      ),
    );
  }
}
