import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:recomart/components/custom/snackbar.dart';

const Color primaryBlue = Color(0xFF1976D2);
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
                  child: const Icon(
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

  @override
  void dispose() {
    _newPasswordCtrl.dispose();
    _repeatPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final newPassword = _newPasswordCtrl.text.trim();
    final confirmPassword = _repeatPasswordCtrl.text.trim();

    if (newPassword != confirmPassword) {
      showCustomSnackBar(context, 'Passwords do not match.', type: SnackBarType.error);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('https://lordlier-nonmaritally-margrett.ngrok-free.dev/api/reset-password');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true', 
        },
        body: jsonEncode({
          'id': widget.userId.trim(), // Sent the specific Firebase Document ID
          'newPassword': newPassword,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        if (mounted) {
          showCustomSnackBar(context, 'Password updated successfully!', type: SnackBarType.success);
          context.go('/login');
        }
      } else {
        String errorMessage = 'Failed to update password';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['detail'] ?? errorData['message'] ?? errorMessage;
        } catch (_) {}
        throw errorMessage;
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(context, e.toString(), type: SnackBarType.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const RecoveryHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Set New Password',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Your new password must be different from previous passwords.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 40),
                    AnimatedPasswordField(
                      controller: _newPasswordCtrl,
                      hintText: 'New Password',
                    ),
                    const SizedBox(height: 20),
                    AnimatedPasswordField(
                      controller: _repeatPasswordCtrl,
                      hintText: 'Confirm Password',
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          disabledBackgroundColor: primaryBlue.withOpacity(0.6),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'Save Password',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ),
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
}

class AnimatedPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;

  const AnimatedPasswordField({super.key, required this.controller, required this.hintText});

  @override
  State<AnimatedPasswordField> createState() => _AnimatedPasswordFieldState();
}

class _AnimatedPasswordFieldState extends State<AnimatedPasswordField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() => _isFocused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _isFocused ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _isFocused ? primaryBlue : Colors.transparent, width: 1.5),
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: !_isVisible,
        validator: (value) => (value == null || value.length < 6) ? 'Password must be at least 6 characters' : null,
        decoration: InputDecoration(
          hintText: widget.hintText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          suffixIcon: IconButton(
            icon: Icon(_isVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
            onPressed: () => setState(() => _isVisible = !_isVisible),
          ),
        ),
      ),
    );
  }
}