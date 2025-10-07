import 'package:flutter/material.dart';
import 'package:recomart/Screens/Customer/Login/PasswordRecoveryMethod.dart';
import 'package:recomart/Screens/Customer/Login/SetUpNewPasswordScreen.dart';

final Color primaryBlue = Colors.blue.shade700; 
final Color errorRed = Colors.red.shade700;

class WrongPasswordScreen extends StatefulWidget {
  final String userName; 
  
  const WrongPasswordScreen({super.key, this.userName = "Julius"});

  @override
  State<WrongPasswordScreen> createState() => _WrongPasswordScreenState();
}

class _WrongPasswordScreenState extends State<WrongPasswordScreen> {
  final int _passwordLength = 8;

  Widget buildAvatarPlaceholder() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.pink.shade100,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: Colors.white, 
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.person,
                size: 80,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPasswordDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_passwordLength, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: errorRed, 
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
  
  Widget buildForgotPasswordButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => const RecoveryMethodScreen()),
        );
      },
      child: const Text(
        'Forgot your password?',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return const RecoveryHeader(); 
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Stack(
            children: [
              buildHeader(context),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 100),

                      buildAvatarPlaceholder(),
                      
                      const SizedBox(height: 20),

                      Text(
                        'Hello, ${widget.userName}!!',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      
                      const SizedBox(height: 40),

                      const Text(
                        'Type your password',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      
                      const SizedBox(height: 30),

                      buildPasswordDots(),
                      
                      const SizedBox(height: 20),
                      
                      buildForgotPasswordButton(context),

                      const Spacer(),
                      
                      const SizedBox(height: 20),
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
}