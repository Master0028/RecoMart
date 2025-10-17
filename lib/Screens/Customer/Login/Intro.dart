import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RecoMartLogo extends StatelessWidget {
  const RecoMartLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/assets/logo.png',
          height: 200, 
          width: 200, 
        ),
      ],
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final blueColor = Colors.blue.shade800;
    const orangeColor = Color(0xFFFF9800);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Spacer(),
              
              const RecoMartLogo(),
              const SizedBox(height: 50),

              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Reco',
                      style: TextStyle(
                        color: blueColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'Mart',
                      style: TextStyle(
                        color: orangeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 40,
                ),
              ),
              const SizedBox(height: 10),

              const Text(
                'Personalized Product\nRecommendation System',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.4,
                ),
              ),

              const Spacer(flex: 2),

              ElevatedButton(
                onPressed: () {
                  context.go('/create-account');
                },
                style: ElevatedButton.styleFrom( 
                  backgroundColor: Colors.blue.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Let's get started",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              
              GestureDetector(
                onTap: () {
                  context.go('/login');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'I already have an account',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.blue.shade700,
                      size: 24,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}