import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RecoMart UI',
      theme: ThemeData(
        fontFamily: 'Roboto', 
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const IntroScreen(),
    );
  }
}

class BannerImage extends StatelessWidget {
  final double width;
  final double height;
  final String imagePath; 

  const BannerImage({
    super.key,
    required this.width,
    required this.height,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: const BorderRadius.all(Radius.circular(60)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.shopping_bag_outlined,
          size: 100,
          color: Colors.blue,
        ),
      ),
    );
  }
}

class WelcomeImageWidget extends StatelessWidget {
  const WelcomeImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const String imagePath = "assets/logo/logo.png"; 
    
    return const Center(
      child: BannerImage(
          width: 300.0,
          height: 300.0,
          imagePath: imagePath),
    );
  }
}

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  void _handleNavigation(BuildContext context, String routeName) {
    print('UI Interaction: Navigating to $routeName...');
  }

  @override
  Widget build(BuildContext context) {
    final blueColor = Colors.blue.shade800;
    const orangeColor = Color(0xFFFF9800);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Spacer(), 
              
              const WelcomeImageWidget(),
              const SizedBox(height: 30), 

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
                    const TextSpan(text: ' '),
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
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),

              const Spacer(flex: 2),

              ElevatedButton(
                onPressed: () => context.push('/signup'), 
                style: ElevatedButton.styleFrom( 
                  backgroundColor: Colors.blue.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
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

              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.push('/login'), 
                  borderRadius: BorderRadius.circular(8.0), 
                  
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
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
