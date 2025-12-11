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

  @override
  void dispose() {
    _newPasswordCtrl.dispose();
    _repeatPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordCtrl.text != _repeatPasswordCtrl.text) {
      if (mounted) {
        showCustomSnackBar(context, 'Passwords do not match.', type: SnackBarType.error);
      }
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      showCustomSnackBar(context, 'Password changed successfully! Please login again.', type: SnackBarType.success);
      context.go('/login');
    }

    if (mounted) setState(() => _isLoading = false);
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
                      'Set New Password',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Please create a new password for your account.',
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
                      hintText: 'Confirm New Password',
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
                          elevation: 5,
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
                                'Save Password',
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
                        'Cancel',
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

class AnimatedPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;

  const AnimatedPasswordField({
    super.key,
    required this.controller,
    required this.hintText,
  });

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
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: _isFocused ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isFocused ? primaryBlue : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: !_isVisible,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Password cannot be empty.';
          if (value.length < 6) return 'Password must be at least 6 characters.';
          return null;
        },
        style: const TextStyle(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: _isFocused ? primaryBlue.withOpacity(0.7) : Colors.grey,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          suffixIcon: IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => RotationTransition(
                turns: child.key == const ValueKey('icon1')
                    ? Tween<double>(begin: 1, end: 0.75).animate(anim)
                    : Tween<double>(begin: 0.75, end: 1).animate(anim),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Icon(
                _isVisible ? Icons.visibility : Icons.visibility_off,
                key: ValueKey(_isVisible ? 'icon1' : 'icon2'),
                color: _isFocused ? primaryBlue : Colors.grey.shade600,
              ),
            ),
            onPressed: () => setState(() => _isVisible = !_isVisible),
          ),
        ),
      ),
    );
  }
}