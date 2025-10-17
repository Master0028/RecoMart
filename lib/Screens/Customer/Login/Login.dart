import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final Color primaryBlue = Colors.blue.shade700;
const Color inputFillColor = Color(0xFFF0F0F0); 
const Color cancelButtonColor = Color(0xFFEEEEEE);
const Color cancelTextColor = Color(0xFF616161);

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.go('/'); 
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: SizedBox(
            height: size.height,
            child: Stack(
              children: [
                Positioned(
                  top: -120,
                  left: -150,
                  child: Container(
                    width: size.width * 1.2,
                    height: size.height * 0.5,
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -80,
                  right: -100,
                  child: Container(
                    width: size.width * 0.8,
                    height: size.height * 0.3,
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 50),
                        buildLogo(),
                        const SizedBox(height: 40),
                        const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Row(
                          children: [
                            Text(
                              'So good to see you back!',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(width: 5),
                            Icon(Icons.favorite, size: 18, color: Colors.black),
                          ],
                        ),
                        const SizedBox(height: 40),
                        buildEmailField(),
                        const Spacer(),
                        buildNextButton(context),
                        const SizedBox(height: 20),
                        buildCancelButton(context),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLogo() {
    return Row(
      children: [
        Image.asset(
          'assets/assets/logo.png',
          height: 60, 
        ),
        const SizedBox(width: 10),
        const Text(
          "Flutter",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.black54
          ),
        )
      ],
    );
  }

  Widget buildEmailField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: 'Email',
        filled: true,
        fillColor: inputFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, 
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
    );
  }

  Widget buildNextButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.push('/password-verify');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: const Text(
        'Next',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget buildCancelButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.go('/'); 
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: cancelButtonColor,
        foregroundColor: cancelTextColor,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0, 
      ),
      child: const Text(
        'Cancel',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}