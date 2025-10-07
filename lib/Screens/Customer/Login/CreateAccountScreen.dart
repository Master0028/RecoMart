import 'package:flutter/material.dart';
import 'package:recomart/Screens/Customer/Login/Login.dart';

final Color primaryBlue = Colors.blue.shade700;
const Color inputFillColor = Color(0xFFF0F0F0); 

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key});

  Widget buildHeader(BuildContext context) {
    return SizedBox(
      height: 270,
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          const Positioned(
            top: 100,
            left: 32,
            child: Text(
              'Create\nAccount',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget buildProfilePicturePlaceholder() {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(
            color: primaryBlue,
            width: 2,
            // style: BorderStyle.solid, 
          ),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.camera_alt_outlined,
          size: 40,
          color: primaryBlue,
        ),
      ),
    );
  }

  Widget buildEmailField() {
    return TextFormField(
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

  Widget buildPasswordField() {
    return TextFormField(
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Password',
        filled: true,
        fillColor: inputFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: const Icon(Icons.visibility_off_outlined, color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
    );
  }

  Widget buildPhoneNumberField() {
    return TextFormField(
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        hintText: 'Your number',
        filled: true,
        fillColor: inputFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🇻🇳', style: TextStyle(fontSize: 22)), 
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
              Container(
                width: 1,
                height: 24,
                color: Colors.grey.shade400,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget buildDoneButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(), 
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
        'Done',
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
  
  Widget buildSignInButton(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
            const Text(
                'I already have an account',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                ),
            ),
            const SizedBox(width: 5),
            IconButton(
                icon: Icon(
                    Icons.arrow_forward,
                    color: primaryBlue,
                    size: 24,
                ),
                onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen(), 
                        ),
                    );
                },
            ),
        ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildHeader(context),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  
                  buildProfilePicturePlaceholder(),
                  
                  const SizedBox(height: 40),
                  
                  buildEmailField(),
                  const SizedBox(height: 20),
                  buildPasswordField(),
                  const SizedBox(height: 20),
                  buildPhoneNumberField(),
                  
                  const SizedBox(height: 60),

                  buildDoneButton(context),
                  
                  const SizedBox(height: 20),

                  buildCancelTextButton(context), 
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
            
            buildSignInButton(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}