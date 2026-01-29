import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:recomart/provider/user_provider.dart';
import 'package:recomart/services/api_service.dart';

import '../../../../pattern/singleton.dart';

final Color primaryBlue = Colors.blue.shade700;
const Color inputFillColor = Color(0xFFF0F0F0);
const Color cancelTextColor = Color(0xFF616161);
const double largeRadius = 32.0;

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _loading = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _focusAndShowError(FocusNode node, String message) {
    FocusScope.of(context).requestFocus(node);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _checkLoginStatus() {
    final userProvider = context.read<UserProvider>();
    if (userProvider.isLoggedIn) {
      debugPrint("User already logged in. Redirecting...");
    }
  }

  Future<void> signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      _focusAndShowError(_emailFocus, 'Please enter your email');
      return;
    }
    if (password.isEmpty) {
      _focusAndShowError(_passwordFocus, 'Please enter your password');
      return;
    }

    setState(() => _loading = true);

    try {
      final data = await ApiService.login(email, password);

      if (!mounted) return;

      await context.read<UserProvider>().loginSuccess(
        data['user_id'].toString(),
        data['name'], 
        data['access_token']
      );

      debugPrint("Login success: ${data['name']}");
      UserSession.instance.setUser(data['user_id']);


      if (email.contains('admin')) {
        context.go('/admin');
      } else {
        context.go('/home');
      }

    } catch (e) {
      String errorMsg = e.toString().replaceAll("Exception: ", "");
      _focusAndShowError(_emailFocus, errorMsg);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget buildSignInButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: ElevatedButton(
        onPressed: _loading ? null : signIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(largeRadius),
          ),
          elevation: _loading ? 0 : 5,
          shadowColor: primaryBlue.withOpacity(0.4),
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
                'Sign In',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
      ),
    );
  }

  Widget buildLogo() {
    return Row(
      children: [
        Image.asset(
          'assets/logo/logo.png',
          height: 40,
        ),
        const SizedBox(width: 10),
        const Text(
          "RecoMart",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            letterSpacing: 0.5,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
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
                  top: -size.height * 0.15,
                  left: -size.width * 0.5,
                  child: Container(
                    width: size.width * 1.5,
                    height: size.height * 0.6,
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  top: -size.height * 0.1,
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
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 450,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 80),
                            buildLogo(),
                            const SizedBox(height: 50),
                            const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                                letterSpacing: -1,
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
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.favorite, size: 20, color: Colors.black),
                              ],
                            ),
                            const SizedBox(height: 40),

                            AnimatedInputField(
                              controller: _emailController,
                              focusNode: _emailFocus,
                              hintText: "Email",
                              icon: Icons.email_outlined,
                              inputType: TextInputType.emailAddress,
                              inputAction: TextInputAction.next,
                            ),

                            const SizedBox(height: 20),

                            AnimatedInputField(
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              hintText: "Password",
                              icon: Icons.lock_outline,
                              inputType: TextInputType.visiblePassword,
                              inputAction: TextInputAction.done,
                              isPassword: true,
                              isPasswordVisible: _isPasswordVisible,
                              onVisibilityToggle: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              onSubmitted: (_) {
                                if (!_loading) signIn();
                              },
                            ),

                            const SizedBox(height: 10),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  final email = _emailController.text.trim();
                                  context.push('/find-account?email=$email'); 
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: primaryBlue,
                                ),
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            buildSignInButton(),

                            const SizedBox(height: 40),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account?",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black54),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.push('/signup');
                                  },
                                  child: Text(
                                    'Sign up',
                                    style: TextStyle(
                                      color: primaryBlue,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
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
}

class AnimatedInputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final IconData icon;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? onVisibilityToggle;
  final Function(String)? onSubmitted;

  const AnimatedInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.icon,
    required this.inputType,
    required this.inputAction,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.onVisibilityToggle,
    this.onSubmitted,
  });

  @override
  State<AnimatedInputField> createState() => _AnimatedInputFieldState();
}

class _AnimatedInputFieldState extends State<AnimatedInputField> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = widget.focusNode.hasFocus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: inputFillColor,
        borderRadius: BorderRadius.circular(largeRadius),
        border: Border.all(
          color: _isFocused ? primaryBlue : Colors.transparent,
          width: _isFocused ? 2.0 : 1.0,
        ),
        boxShadow: [
          if (_isFocused)
            BoxShadow(
              color: primaryBlue.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        keyboardType: widget.inputType,
        textInputAction: widget.inputAction,
        obscureText: widget.isPassword && !widget.isPasswordVisible,
        onFieldSubmitted: widget.onSubmitted,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: Icon(
            widget.icon,
            color: _isFocused ? primaryBlue : Colors.grey.shade600,
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    widget.isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: _isFocused
                        ? primaryBlue.withOpacity(0.8)
                        : Colors.grey.shade500,
                  ),
                  onPressed: widget.onVisibilityToggle,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }
}