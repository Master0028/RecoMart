import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:recomart/provider/user_provider.dart';
import 'package:recomart/services/api_service.dart';

final Color primaryBlue = Colors.blue.shade700;
const Color inputFillColor = Color(0xFFF0F0F0);
const double largeRadius = 32.0;

class ChangePasswordApp extends StatelessWidget {
  const ChangePasswordApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Change Password',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ChangePasswordScreen(),
    );
  }
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _isLoading = false;
  bool _oldPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmedPasswordController = TextEditingController();

  final _oldPassFocus = FocusNode();
  final _newPassFocus = FocusNode();
  final _confirmPassFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _oldPassFocus.addListener(() => setState(() {}));
    _newPassFocus.addListener(() => setState(() {}));
    _confirmPassFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmedPasswordController.dispose();

    _oldPassFocus.dispose();
    _newPassFocus.dispose();
    _confirmPassFocus.dispose();

    super.dispose();
  }

  Widget buildHeader() {
    return const Text(
      'Change\nPassword',
      style: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        color: Colors.black,
        height: 1.1,
      ),
    );
  }

  Future<void> handleChangePassword() async {
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmedPasswordController.text.trim();

    // 1. Validate cơ bản
    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showSnack('Please fill in all fields', Colors.redAccent);
      return;
    }

    if (newPassword != confirmPassword) {
      _showSnack('New passwords do not match', Colors.redAccent);
      return;
    }

    if (newPassword.length < 6) {
      _showSnack('Password must be at least 6 characters', Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.userId; 

      if (userId.isEmpty) {
        _showSnack('Session expired. Please login again.', Colors.redAccent);
        return;
      }

      await ApiService.changePassword(
        userId: userId, 
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      _showSnack('Password changed successfully!', Colors.green);
      
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmedPasswordController.clear();

    } catch (e) {
      String errorMsg = e.toString().replaceAll('Exception:', '').trim();
      _showSnack(errorMsg, Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildAnimatedInputField({
    required String hintText,
    required IconData icon,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
  }) {
    final isFocused = focusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      transform: isFocused
          ? Matrix4.diagonal3Values(1.02, 1.02, 1.0) // Scale up slightly
          : Matrix4.diagonal3Values(1.0, 1.0, 1.0),
      decoration: BoxDecoration(
        color: isFocused ? Colors.white : inputFillColor,
        borderRadius: BorderRadius.circular(largeRadius),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
        border: Border.all(
          color: isFocused ? primaryBlue : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: !isVisible,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(
            icon,
            color: isFocused ? primaryBlue : Colors.grey,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              isVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: isFocused ? primaryBlue : Colors.grey,
            ),
            onPressed: onToggleVisibility,
          ),
          filled: false, // Handled by AnimatedContainer
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }

  Widget buildDoneButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : handleChangePassword,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(largeRadius),
        ),
        elevation: 5,
        shadowColor: primaryBlue.withOpacity(0.4),
      ),
      child: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 3),
            )
          : const Text(
              'Change Password',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
    );
  }

  Widget buildCancelButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.pop();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(largeRadius),
            side: const BorderSide(color: Colors.grey)),
        elevation: 0,
      ),
      child: const Text('Cancel',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Stack(
                    children: [
                      // Background Decoration
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
                        top: size.height * 0.0,
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
                          constraints: const BoxConstraints(maxWidth: 450), 
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 50),
                                buildHeader(),
                                const SizedBox(height: 30),

                                const Text(
                                  'Your password must be strong and different from the previous one.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 30),

                                _buildAnimatedInputField(
                                  hintText: 'Old Password',
                                  icon: Icons.lock_open_outlined,
                                  controller: _oldPasswordController,
                                  focusNode: _oldPassFocus,
                                  isVisible: _oldPasswordVisible,
                                  onToggleVisibility: () {
                                    setState(() {
                                      _oldPasswordVisible = !_oldPasswordVisible;
                                    });
                                  },
                                ),
                                const SizedBox(height: 20),

                                _buildAnimatedInputField(
                                  hintText: 'New Password',
                                  icon: Icons.lock_outline,
                                  controller: _newPasswordController,
                                  focusNode: _newPassFocus,
                                  isVisible: _newPasswordVisible,
                                  onToggleVisibility: () {
                                    setState(() {
                                      _newPasswordVisible = !_newPasswordVisible;
                                    });
                                  },
                                ),
                                const SizedBox(height: 20),

                                _buildAnimatedInputField(
                                  hintText: 'Confirm New Password',
                                  icon: Icons.lock_outline,
                                  controller: _confirmedPasswordController,
                                  focusNode: _confirmPassFocus,
                                  isVisible: _confirmPasswordVisible,
                                  onToggleVisibility: () {
                                    setState(() {
                                      _confirmPasswordVisible = !_confirmPasswordVisible;
                                    });
                                  },
                                ),
                                const SizedBox(height: 40),

                                buildDoneButton(),
                                const SizedBox(height: 20),

                                buildCancelButton(context),
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
            );
          },
        ),
      ),
    );
  }
}