import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

final Color primaryBlue = Colors.blue.shade700;
const Color cancelButtonColor = Color(0xFFEEEEEE);
const Color cancelTextColor = Color(0xFF616161);

class RecoveryMethodScreen extends StatefulWidget {
  final String userName;
  final String userAvatar;
  final String email;
  final String userId; // Added userId

  const RecoveryMethodScreen({
    super.key,
    required this.userName,
    required this.userAvatar,
    required this.email,
    required this.userId, // Added to constructor
  });

  @override
  State<RecoveryMethodScreen> createState() => _RecoveryMethodScreenState();
}

class _RecoveryMethodScreenState extends State<RecoveryMethodScreen> {
  String _selectedMethod = 'Email';
  late TextEditingController _inputController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) context.pop();
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
                    color: primaryBlue.withOpacity(0.2),
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
                            const SizedBox(height: 30),
                            buildAvatar(widget.userAvatar),
                            const SizedBox(height: 20),
                            Text(
                              widget.userName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'How would you like to restore\nyour password?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 30),
                            buildOptionTile(
                              label: 'SMS',
                              value: 'SMS',
                              icon: Icons.sms_outlined,
                              isSelected: _selectedMethod == 'SMS',
                              activeColor: Colors.blue.shade100.withOpacity(0.7),
                            ),
                            const SizedBox(height: 15),
                            buildOptionTile(
                              label: 'Email',
                              value: 'Email',
                              icon: Icons.email_outlined,
                              isSelected: _selectedMethod == 'Email',
                              activeColor: Colors.pink.shade100.withOpacity(0.7),
                            ),
                            const SizedBox(height: 30),
                            SmoothInputField(
                              controller: _inputController,
                              hintText: _selectedMethod == 'SMS' 
                                  ? 'Enter your Phone Number' 
                                  : 'Enter your Email Address',
                              icon: _selectedMethod == 'SMS' 
                                  ? Icons.phone_iphone 
                                  : Icons.alternate_email,
                              inputType: _selectedMethod == 'SMS' 
                                  ? TextInputType.phone 
                                  : TextInputType.emailAddress,
                            ),
                            const Expanded(child: SizedBox(height: 20)), 
                            buildNextButton(context),
                            const SizedBox(height: 15),
                            buildCancelButton(context),
                            const SizedBox(height: 30),
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
      ),
    );
  }

  Widget buildAvatar(String url) {
    return Center(
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          backgroundImage: NetworkImage(
            url.isNotEmpty ? url : "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
          ),
        ),
      ),
    );
  }

  Widget buildOptionTile({
    required String label,
    required String value,
    required bool isSelected,
    required Color activeColor,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = value;
          _inputController.text = (value == 'Email') ? widget.email : '';
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryBlue : Colors.grey.shade200,
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? primaryBlue : Colors.grey),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? primaryBlue : Colors.black87,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: primaryBlue, size: 24),
          ],
        ),
      ),
    );
  }

  Widget buildNextButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : () async {
        final inputText = _inputController.text.trim();

        if (inputText.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enter your ${_selectedMethod.toLowerCase()}')),
          );
          return;
        }

        setState(() => _isLoading = true);

        final String otpCode = (math.Random().nextInt(9000) + 1000).toString();

        try {
          final response = await http.post(
            Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
            headers: {
              'Content-Type': 'application/json',
              'origin': 'http://localhost',
            },
            body: jsonEncode({
              'service_id': 'service_cg1dlar',
              'template_id': 'template_drwxhsn',
              'user_id': 'jlSLGvB_WkhiStTDA',
              'template_params': {
                'email': inputText,
                'user_name': widget.userName,
                'passcode': otpCode,
              }
            }),
          );

          if (response.statusCode == 200) {
            String obscured;
            if (_selectedMethod == 'Email' && inputText.contains('@')) {
              final parts = inputText.split('@');
              final name = parts[0];
              obscured = name.length > 2
                  ? "${name.substring(0, 2)}***@${parts[1]}"
                  : "***@${parts[1]}";
            } else {
              obscured = inputText.length > 3
                  ? "***${inputText.substring(inputText.length - 3)}"
                  : "***";
            }

            if (mounted) {
              context.push('/verify-otp', extra: {
                'userId': widget.userId,
                'email': inputText,
                'obscuredEmail': obscured,
                'otpCode': otpCode,
              });
            }
          } else {
            throw "Failed to send OTP. Please try again.";
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.toString())),
            );
          }
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 5,
        shadowColor: primaryBlue.withOpacity(0.4),
      ),
      child: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
          : const Text(
              'Send Code',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
    );
  }

  Widget buildCancelButton(BuildContext context) {
    return TextButton(
      onPressed: () => context.pop(),
      style: TextButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: cancelButtonColor,
      ),
      child: const Text('Cancel',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cancelTextColor)),
    );
  }
}

class SmoothInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final TextInputType inputType;

  const SmoothInputField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.inputType = TextInputType.text,
  });

  @override
  State<SmoothInputField> createState() => _SmoothInputFieldState();
}

class _SmoothInputFieldState extends State<SmoothInputField> {
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
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
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: _isFocused ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isFocused ? primaryBlue : Colors.grey.shade300,
          width: _isFocused ? 2.0 : 1.0,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        keyboardType: widget.inputType,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(
            widget.icon,
            color: _isFocused ? primaryBlue : Colors.grey,
          ),
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400),
        ),
      ),
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