import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recomart/views/pages/client/splash/widgets/splash_image_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  
  static const Duration minSplashDuration = Duration(seconds: 3); 

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _initializeApp() async {
    final startTime = DateTime.now();
    final elapsedTime = DateTime.now().difference(startTime);
    if (elapsedTime < minSplashDuration) {
      await Future.delayed(minSplashDuration - elapsedTime);
    }
    
    if (mounted) {
      context.go('/intro'); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SplashImageViewWidget(),
    );
  }
}