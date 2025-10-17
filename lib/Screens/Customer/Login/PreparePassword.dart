import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

final Color primaryBlue = Colors.blue.shade700;

class PasswordVerifyScreen extends StatefulWidget {
  final String userName;

  const PasswordVerifyScreen({super.key, this.userName = "Julius"});

  @override
  State<PasswordVerifyScreen> createState() => _PasswordVerifyScreenState();
}

class _PasswordVerifyScreenState extends State<PasswordVerifyScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false, // Ngăn back tự động
      onPopInvoked: (didPop) {
        if (!didPop) {
          // Quay về màn hình trước đó (có thể là màn hình nhập email)
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: SizedBox(
            height: size.height,
            child: Stack(
              children: [
                ClipPath(
                  clipper: WaveClipper(),
                  child: Container(
                    height: size.height * 0.4,
                    color: Colors.blue.shade100.withOpacity(0.5),
                  ),
                ),
                ClipPath(
                  clipper: WaveClipper(),
                  child: Container(
                    height: size.height * 0.38,
                    color: primaryBlue.withOpacity(0.6),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 50),
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
                        const SizedBox(height: 10),
                        const Text(
                          'Type your password',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 30),
                        buildPasswordInputArea(),
                        const SizedBox(height: 30), // Khoảng cách giữa ô password và nút Login
                        
                        buildLoginButton(context),
                        
                        const Spacer(), // Đẩy phần "Not you?" xuống dưới
                        buildNotYouButton(context),
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

  // Các widget con (không thay đổi nhiều)
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
              image: DecorationImage(
                // Cập nhật lại ảnh để giống mẫu
                image: NetworkImage("https://cdn3d.iconscout.com/3d/premium/thumb/man-avatar-6299539-5187871.png"),
                fit: BoxFit.cover,
              ),
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPasswordInputArea() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      keyboardType: TextInputType.visiblePassword,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        hintText: 'Password',
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.0),
          borderSide: BorderSide(color: primaryBlue),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey.shade600,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
    );
  }

  Widget buildLoginButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.go('/home'); 
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
        'Login',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget buildNotYouButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Not you?',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black54,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            color: primaryBlue,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              context.go('/login');
            },
          ),
        ),
      ],
    );
  }
}

// Giữ nguyên Clipper
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint =
        Offset(size.width - (size.width / 3.25), size.height - 65);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}