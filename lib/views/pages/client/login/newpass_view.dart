import 'package:recomart/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recomart/components/custom/snackbar.dart';
import 'package:recomart/services/app_exceptions.dart';
import 'package:recomart/services/auth.service.dart';

// --- Khai Báo Biến Màu Chung ---
final Color primaryBlue = const Color(0xFF1976D2); 
final Color primaryPink = Colors.pink.shade300; 

// --- Component: RecoveryHeader (Phần đầu trang) ---
class RecoveryHeader extends StatelessWidget {
  const RecoveryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Lớp nền màu xanh đậm hơn (lớp dưới)
        Container(
          width: size.width,
          height: size.height * 0.4,
          decoration: BoxDecoration(
            color: primaryBlue.withOpacity(0.5),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(100),
              bottomRight: Radius.circular(100),
            ),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            // Lớp nền màu xanh nhạt hơn (lớp trên) tạo hiệu ứng gợn sóng
            child: Container(
              width: size.width,
              height: size.height * 0.35,
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(150),
                  bottomRight: Radius.circular(150),
                ),
              ),
            ),
          ),
        ),
        // Icon Khóa (thay thế Icons.person) ở giữa
        Positioned(
          top: size.height * 0.4 - 70, // Đặt ở vị trí hợp lý hơn
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Vòng tròn màu hồng nhạt (nền)
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: primaryPink.withOpacity(0.3), // Dùng primaryPink
                  shape: BoxShape.circle,
                ),
              ),
              // Vòng tròn màu trắng (trên)
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.lock_reset_rounded, // Icon reset mật khẩu
                    size: 70,
                    color: primaryBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --- Màn Hình: SetupNewPasswordScreen (Thiết Lập Mật Khẩu Mới) ---
class SetupNewPasswordScreen extends StatefulWidget {
  final String userId; // ID người dùng, cần thiết để reset mật khẩu

  const SetupNewPasswordScreen({super.key, required this.userId});

  @override
  State<SetupNewPasswordScreen> createState() => _SetupNewPasswordScreenState();
}

class _SetupNewPasswordScreenState extends State<SetupNewPasswordScreen> {
  final _newPasswordCtrl = TextEditingController();
  final _repeatPasswordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isNewPasswordVisible = false;
  bool _isRepeatPasswordVisible = false;

  @override
  void dispose() {
    _newPasswordCtrl.dispose();
    _repeatPasswordCtrl.dispose();
    super.dispose();
  }

  // --- Logic: Đổi Mật Khẩu ---
  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_newPasswordCtrl.text != _repeatPasswordCtrl.text) {
      if (mounted) {
        // Đảm bảo showCustomSnackBar được import và khả dụng
         showCustomSnackBar(context, 'Mật khẩu nhập lại không khớp.'); 
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = AuthService();
      final newPassword = _newPasswordCtrl.text;

      //await auth.resetPassword(widget.userId, newPassword); 

      // *** GIẢ LẬP KẾT QUẢ API THÀNH CÔNG ***
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        showCustomSnackBar(context, 'Đổi mật khẩu thành công! Vui lòng đăng nhập lại.');
        context.go('/login');
      }
    } on BadRequestException catch (e) {
      if (mounted) {
        showCustomSnackBar(context, e.message);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- Widget: Trường nhập mật khẩu được tùy chỉnh theo thiết kế cũ ---
  Widget buildPasswordField(
      String hint, TextEditingController controller, bool isVisible, Function(bool) toggleVisibility) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      // Validator cơ bản
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Mật khẩu không được để trống.';
        }
        if (value.length < 6) {
          return 'Mật khẩu phải có ít nhất 6 ký tự.';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey.shade500,
          ),
          onPressed: () => toggleVisibility(!isVisible),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              // 1. Header (Phần trên cùng)
              const RecoveryHeader(),

              // 2. Nội dung chính
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Khoảng cách từ trên xuống
                        SizedBox(height: MediaQuery.of(context).size.height * 0.4 - 30),

                        // Tiêu đề
                        const Text(
                          'Thiết Lập Mật Khẩu Mới',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Hướng dẫn
                        const Text(
                          'Vui lòng thiết lập mật khẩu mới cho tài khoản của bạn.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Trường nhập Mật khẩu Mới
                        buildPasswordField(
                          'Mật khẩu mới',
                          _newPasswordCtrl,
                          _isNewPasswordVisible,
                          (value) => setState(() => _isNewPasswordVisible = value),
                        ),
                        const SizedBox(height: 20),

                        // Trường nhập Lặp lại Mật khẩu
                        buildPasswordField(
                          'Nhập lại mật khẩu mới',
                          _repeatPasswordCtrl,
                          _isRepeatPasswordVisible,
                          (value) => setState(() => _isRepeatPasswordVisible = value),
                        ),

                        const Spacer(),

                        // Nút "Lưu"
                        ElevatedButton(
                          onPressed: _isLoading ? null : _changePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text('Lưu Mật Khẩu',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                        ),

                        // Nút "Hủy"
                        TextButton(
                          onPressed: () => context.pop(),
                          child: const Text('Hủy Bỏ',
                              style: TextStyle(color: Colors.grey, fontSize: 16)),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
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