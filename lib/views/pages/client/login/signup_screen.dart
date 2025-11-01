import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


final Color primaryBlue = Colors.blue.shade700;
const Color inputFillColor = Color(0xFFF0F0F0); 
const Color largeButtonColor = Color(0xFFEEEEEE);
const Color cancelTextColor = Colors.white;
const double largeRadius = 32.0;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmedPasswordController = TextEditingController();
  final _addressController = TextEditingController(); 

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  final _phoneFocus = FocusNode();
  
  bool _loading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmedPasswordController.dispose();
    _addressController.dispose();

    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    _phoneFocus.dispose();
    
    super.dispose();
  }

  void _focusAndShowError(FocusNode node, String message) {
    FocusScope.of(context).requestFocus(node);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message), 
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 3),
    ));
  }

  Future<void> signUp() async {
    final name = _userNameController.text.trim();
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();
    final address = _addressController.text.trim();

    try {
      setState(() => _loading = true);

      final authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );

      // Lưu thêm thông tin vào Firestore
      await FirebaseFirestore.instance.collection('users').doc(authResult.user!.uid).set({
        'name': name,
        'email': email,
        'address': address,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Sign up successful! Redirecting...'),
        backgroundColor: Colors.green,
      ));

      context.go('/login');
    } on FirebaseAuthException catch (e) {
      _focusAndShowError(_emailFocus,"lor" ?? 'Sign up failed');
    } finally {
      setState(() => _loading = false);
    }
  }


  Widget buildHeader() {
    return const Text(
      'Create\nAccount',
      style: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        color: Colors.black,
        height: 1.1,
      ),
    );
  }

  Widget buildProfilePicturePlaceholder() {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: primaryBlue.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: CustomPaint(
          painter: DashedCirclePainter(color: primaryBlue),
          child: Center(
            child: Icon(
              Icons.camera_alt_outlined,
              size: 40,
              color: primaryBlue,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInputField({
    required String hintText,
    required IconData icon,
    required TextEditingController controller,
    required FocusNode focusNode,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: primaryBlue.withOpacity(0.7)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: inputFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(largeRadius),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
    );
  }

  Widget buildPasswordField() {
    return buildInputField(
      hintText: 'Password',
      icon: Icons.lock_outline,
      controller: _passwordController,
      focusNode: _passwordFocus,
      obscureText: !_isPasswordVisible,
      suffixIcon: IconButton(
        icon: Icon(
          _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: Colors.grey,
        ),
        onPressed: () {
          setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          });
        },
      ),
    );
  }
  
  Widget buildConfirmPasswordField() {
    return buildInputField(
      hintText: 'Confirm Password',
      icon: Icons.lock_open_outlined,
      controller: _confirmedPasswordController,
      focusNode: _confirmFocus,
      obscureText: !_isConfirmPasswordVisible,
      suffixIcon: IconButton(
        icon: Icon(
          _isConfirmPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: Colors.grey,
        ),
        onPressed: () {
          setState(() {
            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
          });
        },
      ),
    );
  }

  Widget buildDoneButton() {
    return ElevatedButton(
      onPressed: _loading ? null : signUp,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(largeRadius),
        ),
        elevation: 2,
      ),
      child: _loading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3.0,
              ),
            )
          : const Text(
              'Sign Up',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
    );
  }

  Widget buildCancelButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.pop(); 
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey, 
        foregroundColor: cancelTextColor,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(largeRadius)),
        elevation: 0,
      ),
      child: const Text('Cancel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }


  Widget buildSignInButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        context.go('/login');
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'I already have an account',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: primaryBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Stack(
                    children: [
                      Positioned(
                        top: -size.height * 0.15, 
                        left: -size.width * 0.5,
                        child: Container(
                          width: size.width * 1.5,
                          height: size.height * 0.6,
                          decoration: BoxDecoration(
                            color: primaryBlue.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      // Hình khối trang trí 2
                      Positioned(
                        top: size.height * 0.0,
                        right: -size.width * 0.3,
                        child: Container(
                          width: size.width * 0.8,
                          height: size.height * 0.4,
                          decoration: BoxDecoration(
                            color: primaryBlue.withOpacity(0.1),
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
                              buildHeader(),
                              const SizedBox(height: 30),
                              buildProfilePicturePlaceholder(),
                              const SizedBox(height: 30),
                              
                              // Name
                              buildInputField(
                                hintText: 'Full Name', 
                                icon: Icons.person_outline, 
                                controller: _userNameController, 
                                focusNode: _nameFocus
                              ),
                              const SizedBox(height: 20),
                              
                              // Email
                              buildInputField(
                                hintText: 'Email', 
                                icon: Icons.email_outlined, 
                                controller: _emailController, 
                                focusNode: _emailFocus,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 20),

                              buildInputField(
                                hintText: 'Address (Optional)', 
                                icon: Icons.home_outlined, 
                                controller: _addressController, 
                                focusNode: _phoneFocus, // Tạm dùng FocusNode này
                              ),
                              const SizedBox(height: 20),

                              buildPasswordField(),
                              const SizedBox(height: 20),
                              
                              buildConfirmPasswordField(),
                              const SizedBox(height: 40),
                              
                              buildDoneButton(),
                              const SizedBox(height: 20),

                              buildCancelButton(context),
                              const SizedBox(height: 20),
                                                            
                              buildSignInButton(context),
                              
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


class DashedCirclePainter extends CustomPainter {
  final Color color;

  DashedCirclePainter({this.color = Colors.blue});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const double dashWidth = 8.0;
    const double dashSpace = 4.0;
    final double circumference = 2 * math.pi * (size.width / 2);
    final int dashCount = (circumference / (dashWidth + dashSpace)).floor();

    final Path path = Path();
    for (int i = 0; i < dashCount; i++) {
      final double startAngle = (i * (dashWidth + dashSpace)) / (size.width / 2);
      final double sweepAngle = dashWidth / (size.width / 2);
      path.addArc(
        Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2),
        startAngle,
        sweepAngle,
      );
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}