import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Navigated to $title'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class MockAppRunner extends StatelessWidget {
    final Widget child;
    const MockAppRunner({super.key, required this.child});

    @override
    Widget build(BuildContext context) {
        final router = GoRouter(
            routes: [
                GoRoute(
                    path: '/',
                    builder: (context, state) => child,
                ),
            ],
            debugLogDiagnostics: true,
        );

        return MaterialApp.router(
            theme: ThemeData(fontFamily: 'Poppins'),
            debugShowCheckedModeBanner: false,
            routerConfig: router,
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
        image: DecorationImage(
          image: AssetImage(imagePath), 
          fit: BoxFit.cover,
        ),
        // Bo góc theo yêu cầu
        borderRadius: const BorderRadius.all(Radius.circular(60)),
      ),
    );
  }
}

class WelcomeImageWidget extends StatelessWidget {
  const WelcomeImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const String imagePath = "assets/logo/logo.png"; 
    
    return Center(
      child: BannerImage(
          width: 300.0,
          height: 300.0,
          imagePath: imagePath),
    );
  }
}

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

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
                  context.push('/signup');
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

              
              Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  context.push('/login');
                },
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