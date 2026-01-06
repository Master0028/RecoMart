import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

import 'package:recomart/services/api_service.dart';

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
  final _addressFocus = FocusNode();

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
    _addressFocus.dispose();

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
    final confirmPass = _confirmedPasswordController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty) {
      _focusAndShowError(_nameFocus, 'Please enter your full name');
      return;
    }
    if (email.isEmpty) {
      _focusAndShowError(_emailFocus, 'Please enter your email');
      return;
    }
    if (pass.isEmpty || pass.length < 6) {
      _focusAndShowError(
          _passwordFocus, 'Password must be at least 6 characters');
      return;
    }
    if (pass != confirmPass) {
      _focusAndShowError(_confirmFocus, 'Passwords do not match');
      return;
    }

    try {
      setState(() => _loading = true);

      await ApiService.register(
        email: email,
        password: pass,
        name: name,
        address: address,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Sign up successful! Redirecting to Login!'),
          backgroundColor: Colors.green,
        ));
        context.go('/login');
      }
    } catch (e) {
      String errorMsg = e.toString().replaceAll("Exception: ", "");
      if (mounted) _focusAndShowError(_emailFocus, errorMsg);
    } finally {
      if (mounted) setState(() => _loading = false);
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
    return AnimatedInputContainer(
      focusNode: focusNode,
      child: TextFormField(
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
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(largeRadius),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(largeRadius),
            borderSide: BorderSide(color: primaryBlue, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
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
          _isPasswordVisible
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
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
          _isConfirmPasswordVisible
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
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
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(largeRadius)),
        elevation: 0,
      ),
      child: const Text('Cancel',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            child: const Icon(Icons.arrow_forward,
                color: Colors.white, size: 20),
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
                              buildInputField(
                                  hintText: 'Full Name',
                                  icon: Icons.person_outline,
                                  controller: _userNameController,
                                  focusNode: _nameFocus),
                              const SizedBox(height: 20),
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
                                focusNode: _addressFocus,
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

class AnimatedInputContainer extends StatefulWidget {
  final Widget child;
  final FocusNode focusNode;

  const AnimatedInputContainer({
    super.key,
    required this.child,
    required this.focusNode,
  });

  @override
  State<AnimatedInputContainer> createState() => _AnimatedInputContainerState();
}

class _AnimatedInputContainerState extends State<AnimatedInputContainer> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = widget.focusNode.hasFocus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isFocused ? 1.02 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(largeRadius),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: primaryBlue.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: widget.child,
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
      final double startAngle =
          (i * (dashWidth + dashSpace)) / (size.width / 2);
      final double sweepAngle = dashWidth / (size.width / 2);
      path.addArc(
        Rect.fromCircle(
            center: Offset(size.width / 2, size.height / 2),
            radius: size.width / 2),
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