import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math; // Cần thiết cho custom painter

// Các hằng số màu sắc để dễ quản lý
final Color primaryBlue = Colors.blue.shade700;
const Color inputFillColor = Color(0xFFF0F0F0); 
const Color cancelButtonColor = Color(0xFFEEEEEE);
const Color cancelTextColor = Color(0xFF616161);

// Chuyển thành StatefulWidget để quản lý trạng thái ẩn/hiện mật khẩu
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false, // Ngăn back tự động
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.go('/'); // Xử lý khi nhấn nút back
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: SizedBox(
            // Đặt chiều cao tối thiểu để nội dung không bị co lại khi bàn phím hiện
            height: size.height,
            child: Stack(
              children: [
                // Phần nền trang trí "blob"
                Positioned(
                  top: -50,
                  left: -100,
                  child: Container(
                    width: size.width * 0.8,
                    height: size.height * 0.4,
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  top: 100,
                  right: -150,
                  child: Container(
                    width: size.width,
                    height: size.height * 0.4,
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.2),
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
                        buildEmailField(),
                        const SizedBox(height: 20),
                        buildPasswordField(),
                        const SizedBox(height: 20),
                        buildPhoneNumberField(),
                        const Spacer(), // Đẩy các button xuống dưới
                        buildDoneButton(context),
                        const SizedBox(height: 20),
                        buildCancelButton(context),
                        buildSignInButton(context),
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

  // Các phương thức build widget con
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

  // THAY ĐỔI CHÍNH: Dùng CustomPaint để vẽ viền nét đứt
  Widget buildProfilePicturePlaceholder() {
    return Center(
      child: SizedBox(
        width: 100,
        height: 100,
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

  // THAY ĐỔI CHÍNH: Thêm logic ẩn/hiện mật khẩu
  Widget buildPasswordField() {
    return TextFormField(
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        hintText: 'Password',
        filled: true,
        fillColor: inputFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
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
        context.go('/login');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Done',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  // THAY ĐỔI CHÍNH: Chuyển thành ElevatedButton được style lại
  Widget buildCancelButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.go('/'); // Quay về trang Intro
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
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
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
}


// Thêm class CustomPainter để vẽ viền nét đứt
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