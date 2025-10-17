import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Các hằng số màu sắc
final Color primaryBlue = Colors.blue.shade700;
final Color errorRed = Colors.pink.shade400; // Dùng màu hồng cho viền lỗi

// Screen này nên là StatefulWidget để quản lý trạng thái của TextFormField
class WrongPasswordScreen extends StatefulWidget {
  final String userName;

  const WrongPasswordScreen({super.key, this.userName = "Julius"});

  @override
  State<WrongPasswordScreen> createState() => _WrongPasswordScreenState();
}

class _WrongPasswordScreenState extends State<WrongPasswordScreen> {
  // Thêm state để quản lý ẩn/hiện mật khẩu và controller
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // Tự động focus vào trường mật khẩu khi màn hình được build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Xử lý nút Back của hệ thống
    return PopScope(
      canPop: false, // Ngăn không cho tự động back
      onPopInvoked: (didPop) {
        if (!didPop) {
          // Khi nhấn back, quay lại màn hình trước đó trong stack
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
                // THAY ĐỔI CHÍNH: Dùng CustomClipper để tạo nền cong
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
                        // THAY ĐỔI CHÍNH: Thay thế các chấm tròn bằng TextFormField
                        buildPasswordField(),
                        const SizedBox(height: 20),
                        buildLoginButton(context),
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
      ),
    );
  }

  // Cập nhật lại widget Avatar cho đẹp hơn
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

  // THAY ĐỔI CHÍNH: Widget cho trường nhập mật khẩu
  Widget buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      autofocus: true, // Tự động mở bàn phím
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        hintText: 'Password',
        // Style cho trạng thái lỗi
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.0),
          borderSide: BorderSide(color: errorRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.0),
          borderSide: BorderSide(color: errorRed, width: 2),
        ),
        // Style mặc định (mặc dù sẽ luôn ở trạng thái lỗi)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.0),
          borderSide: BorderSide(color: primaryBlue),
        ),
        // Thêm icon ẩn/hiện mật khẩu
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
        errorText: _passwordController.text.isEmpty ? 'Incorrect password. Please try again.' : null,
        errorStyle: const TextStyle(height: 0.01, color: Colors.transparent), // Ẩn text lỗi đi
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      ),
      onChanged: (value) {
        setState(() {});
      },
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

  Widget buildForgotPasswordButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        context.push('/recovery-method');
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
}

// Thêm class Clipper để tạo hiệu ứng sóng
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