import 'package:flutter/material.dart';
import 'package:recomart/Screens/Customer/Login/PreparePassword.dart';

final Color primaryBlue = Colors.blue.shade700;
const Color inputFillColor = Color(0xFFF0F0F0); 

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Stack(
            children: [
              Positioned(
                top: -50,
                left: -100,
                child: Transform.rotate(
                  angle: -0.2,
                  child: Container(
                    width: size.width * 1.5,
                    height: 300,
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(150),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 100,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),

              Positioned(
                top: 150,
                left: -20,
                child: Container(
                  width: size.width * 0.9,
                  height: 400,
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(200),
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

                      // Dòng phụ
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
                      
                      const SizedBox(height: 40),

                      buildNextButton(context),

                      const SizedBox(height: 20),

                      buildCancelTextButton(context),
                    ],
                  ),
                ),
              ),
            ],
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
          height: 100, 
          width: 100, 
        ),
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
        debugPrint('Tiếp tục (Next)!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const PasswordVerifyScreen(), 
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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

  Widget buildCancelTextButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pop(context); 
      },
      child: const Text(
        'Cancel',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    );
  }
}
