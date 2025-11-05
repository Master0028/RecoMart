import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    _isLogin();
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
    ));
  }

  Future<void> _isLogin() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      print(user.email);
      // Kiểm tra email của user
      if (user.email == 'admin@gmail.com') {
        context.go('/admin');
      } else {
        context.go('/home');
      }
    }
  }

  Future<void> signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      _focusAndShowError(_emailFocus, 'Vui lòng nhập email');
      return;
    }
    if (password.isEmpty) {
      _focusAndShowError(_passwordFocus, 'Vui lòng nhập mật khẩu');
      return;
    }

    setState(() => _loading = true);

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final token = await userCredential.user?.getIdToken();

      // Lưu token để kiểm tra đăng nhập sau
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', token ?? '');

      _isLogin();
    } on FirebaseAuthException catch (e) {
      String errorMsg;
      switch (e.code) {
        case 'user-not-found':
          errorMsg = 'Tài khoản không tồn tại.';
          break;
        case 'wrong-password':
          errorMsg = 'Sai mật khẩu.';
          break;
        default:
          errorMsg = e.message ?? 'Đăng nhập thất bại.';
      }
      _focusAndShowError(_emailFocus, errorMsg);
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget buildEmailField() {
    return TextFormField(
      controller: _emailController,
      focusNode: _emailFocus,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: 'Email',
        prefixIcon: Icon(Icons.email, color: primaryBlue.withOpacity(0.7)),
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
    return TextFormField(
      controller: _passwordController,
      focusNode: _passwordFocus,
      obscureText: !_isPasswordVisible,
      keyboardType: TextInputType.visiblePassword,
      decoration: InputDecoration(
        hintText: 'Password',
        prefixIcon: Icon(Icons.lock, color: primaryBlue.withOpacity(0.7)),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: primaryBlue.withOpacity(0.6),
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
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

  Widget buildSignInButton() {
    return ElevatedButton(
      onPressed: _loading ? null : signIn,
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
              'Sign In',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
            fontWeight: FontWeight.w500,
            color: Colors.black54,
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
          context.go('/splash');
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
                      color: primaryBlue.withOpacity(0.2),
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
                // Nội dung chính
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 100),
                        buildLogo(),
                        const SizedBox(height: 60),
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
                        // Email
                        buildEmailField(),
                        const SizedBox(height: 15),
                        // Password
                        buildPasswordField(),
                        const SizedBox(height: 10),
                        
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              context.push('/recovery?email=${_emailController.text.trim()}');
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
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
                              style: TextStyle(fontSize: 16, color: Colors.black54),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}