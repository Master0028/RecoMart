import 'package:flutter/material.dart';

final Color primaryBlue = Colors.blue.shade700;

class OnboardingPageModel {
  final String imagePath;
  final String title;
  final String description;
  final bool isLastPage;

  OnboardingPageModel({
    required this.imagePath,
    required this.title,
    required this.description,
    this.isLastPage = false,
  });
}

final List<OnboardingPageModel> onboardingData = [
  OnboardingPageModel(
    imagePath: 'assets/hello_card_image.jpg',
    title: 'Hello',
    description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed non consectetur turpis. Morbi eu eleifend lacus.',
    isLastPage: false,
  ),
  OnboardingPageModel(
    imagePath: 'assets/ready_card_image.jpg',
    title: 'Ready?',
    description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    isLastPage: true,
  ),
];
class OnboardingPageView extends StatefulWidget {
  const OnboardingPageView({super.key});

  @override
  State<OnboardingPageView> createState() => _OnboardingPageViewState();
}

class _OnboardingPageViewState extends State<OnboardingPageView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingData.length,
            itemBuilder: (context, index) {
              final page = onboardingData[index];
              return OnboardingCard(
                page: page,
                currentPage: _currentPage,
                pageController: _pageController,
              );
            },
          ),
        ],
      ),
    );
  }
}

class OnboardingCard extends StatelessWidget {
  final OnboardingPageModel page;
  final int currentPage;
  final PageController pageController;

  const OnboardingCard({
    super.key,
    required this.page,
    required this.currentPage,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: size.height * 0.55,
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(100),
                  bottomRight: Radius.circular(100),
                ),
              ),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(100),
                bottomRight: Radius.circular(100),
              ),
              child: Image.asset(
                page.imagePath,
                height: size.height * 0.5,
                width: size.width,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      page.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      page.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
                
                Column(
                  children: [
                    if (page.isLastPage)
                      ElevatedButton(
                        onPressed: () {
                          debugPrint("Bắt đầu ứng dụng!");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Let's Start", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      )
                    else 
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(onboardingData.length, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: currentPage == index ? 30 : 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: currentPage == index ? primaryBlue : Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          );
                        }),
                      ),
                    const SizedBox(height: 30),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}