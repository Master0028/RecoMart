import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recomart/components/custom/snackbar.dart';

final Color primaryBlue = const Color(0xFF1976D2);
final Color primaryPink = Colors.pink.shade300;

class RecoveryHeader extends StatelessWidget {
  const RecoveryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * 0.35,
      width: size.width,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.5),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(100),
                bottomRight: Radius.circular(100),
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.18,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: primaryPink.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 110,
                  height: 110,
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
                  child: Icon(
                    Icons.lock_reset_rounded,
                    size: 60,
                    color: primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SetupNewPasswordScreen extends StatefulWidget {
  final String userId;

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

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordCtrl.text != _repeatPasswordCtrl.text) {
      if (mounted) showCustomSnackBar(context, 'Mật khẩu nhập lại không khớp.');
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      showCustomSnackBar(context, 'Đổi mật khẩu thành công! Vui lòng đăng nhập lại.');
      context.go('/login');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Widget buildPasswordField(
    String hint,
    TextEditingController controller,
    bool isVisible,
    Function(bool) toggleVisibility,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Mật khẩu không được để trống.';
        if (value.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự.';
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
            color: Colors.grey.shade600,
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
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          const RecoveryHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
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
                    const Text(
                      'Vui lòng thiết lập mật khẩu mới cho tài khoản của bạn.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 40),
                    buildPasswordField(
                      'Mật khẩu mới',
                      _newPasswordCtrl,
                      _isNewPasswordVisible,
                      (value) => setState(() => _isNewPasswordVisible = value),
                    ),
                    const SizedBox(height: 20),
                    buildPasswordField(
                      'Nhập lại mật khẩu mới',
                      _repeatPasswordCtrl,
                      _isRepeatPasswordVisible,
                      (value) => setState(() => _isRepeatPasswordVisible = value),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                            : const Text(
                                'Lưu Mật Khẩu',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text(
                        'Hủy Bỏ',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}