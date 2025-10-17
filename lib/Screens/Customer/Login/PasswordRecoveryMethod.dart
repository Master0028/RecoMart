import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Các hằng số màu sắc để dễ quản lý
final Color primaryBlue = Colors.blue.shade700;
const Color cancelButtonColor = Color(0xFFEEEEEE);
const Color cancelTextColor = Color(0xFF616161);

class RecoveryMethodScreen extends StatefulWidget {
  const RecoveryMethodScreen({super.key});

  @override
  State<RecoveryMethodScreen> createState() => _RecoveryMethodScreenState();
}

class _RecoveryMethodScreenState extends State<RecoveryMethodScreen> {
  // State để lưu trữ phương thức được chọn
  String _selectedMethod = 'SMS';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false, // Ngăn back tự động
      onPopInvoked: (didPop) {
        if (!didPop) {
          // Khi nhấn back, quay lại màn hình trước đó
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Phần nền cong trang trí ở trên
            ClipPath(
              clipper: WaveClipper(),
              child: Container(
                height: size.height * 0.4,
                color: primaryBlue.withOpacity(0.2),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 50),
                    buildAvatar(),
                    const SizedBox(height: 30),
                    const Text(
                      'Password Recovery',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'How you would like to restore\nyour password?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Các nút lựa chọn
                    buildOptionTile(
                      label: 'SMS',
                      value: 'SMS',
                      isSelected: _selectedMethod == 'SMS',
                      activeColor: Colors.blue.shade100.withOpacity(0.7),
                    ),
                    const SizedBox(height: 20),
                    buildOptionTile(
                      label: 'Email',
                      value: 'Email',
                      isSelected: _selectedMethod == 'Email',
                      activeColor: Colors.pink.shade100.withOpacity(0.7),
                    ),
                    const Spacer(),
                    // Các nút hành động
                    buildNextButton(context),
                    const SizedBox(height: 20),
                    buildCancelButton(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget xây dựng Avatar
  Widget buildAvatar() {
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

  // THAY ĐỔI CHÍNH: Widget cho các nút lựa chọn được style lại
  Widget buildOptionTile({
    required String label,
    required String value,
    required bool isSelected,
    required Color activeColor,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? primaryBlue : Colors.black87,
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? primaryBlue : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // Nút Next
  Widget buildNextButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Điều hướng dựa trên phương thức đã chọn
        if (_selectedMethod == 'SMS') {
          context.push('/recovery-sms');
        } else if (_selectedMethod == 'Email') {
          context.push('/recovery-email');
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text('Next', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget buildCancelButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.pop();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: cancelButtonColor,
        foregroundColor: cancelTextColor,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: const Text('Cancel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.7);
    path.quadraticBezierTo(
        size.width / 4, size.height, size.width / 2, size.height * 0.85);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.7, size.width, size.height * 0.8);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}