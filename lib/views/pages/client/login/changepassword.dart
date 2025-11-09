import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final Color primaryBlue = Colors.blue.shade700;
const Color inputFillColor = Color(0xFFF0F0F0);
const double largeRadius = 32.0;

class ChangePasswordApp extends StatelessWidget {
  const ChangePasswordApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Đổi Mật Khẩu',
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
  bool _loading = false;
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

  Widget buildInputField({
    required String hintText,
    required IconData icon,
    required TextEditingController controller,
    required FocusNode focusNode,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: primaryBlue.withOpacity(0.7)),
        suffixIcon: suffixIcon,
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

  Widget _buildPasswordInput({
    required String hintText,
    required IconData icon,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
  }) {
    return buildInputField(
      hintText: hintText,
      icon: icon,
      controller: controller,
      focusNode: focusNode,
      obscureText: !isVisible,
      suffixIcon: IconButton(
        icon: Icon(
          isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: Colors.grey,
        ),
        onPressed: onToggleVisibility,
      ),
    );
  }

  Widget buildDoneButton() {
    return ElevatedButton(
      onPressed: _loading
          ? null
          : () {
              context.pop();
            },
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
        backgroundColor: Colors.grey,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(largeRadius)),
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
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 50),
                              buildHeader(), // Tiêu đề lớn
                              const SizedBox(height: 30),
                              
                              const Text(
                                'Mật khẩu của bạn phải đủ mạnh và khác với mật khẩu trước đó.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 30),

                              _buildPasswordInput(
                                hintText: 'Mật khẩu cũ',
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

                              _buildPasswordInput(
                                hintText: 'Mật khẩu mới',
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

                              // Xác nhận mật khẩu mới
                              _buildPasswordInput(
                                hintText: 'Xác nhận mật khẩu mới',
                                icon: Icons.lock_outline,
                                controller: _confirmedPasswordController,
                                focusNode: _confirmPassFocus,
                                isVisible: _confirmPasswordVisible,
                                onToggleVisibility: () {
                                  setState(() {
                                    _confirmPasswordVisible =
                                        !_confirmPasswordVisible;
                                  });
                                },
                              ),
                              const SizedBox(height: 40),

                              // Nút "Done"
                              buildDoneButton(),
                              const SizedBox(height: 20),

                              // Nút "Cancel"
                              buildCancelButton(context),
                              const SizedBox(height: 40),
                            ],
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