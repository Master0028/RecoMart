import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:recomart/components/custom/snackbar.dart';
import 'package:recomart/views/pages/client/login/my_text_field.dart';
import 'widgets/button.dart';

final Color primaryBlue = Colors.blue.shade700;
final Color primaryPink = Colors.pink.shade300;

class RecoveryHeader extends StatelessWidget {
  const RecoveryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      alignment: Alignment.topCenter,
      children: [
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
        Positioned(
          top: size.height * 0.4 - 70,
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
                    Icons.lock_open_rounded,
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

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;

  String _obscureEmail(String email) {
    if (email.isEmpty || !email.contains('@')) return '******@mail.com';
    final parts = email.split('@');
    final username = parts[0];
    final domain = parts[1];
    if (username.length <= 3) return '***@$domain';
    final obscuredUsername =
        username.substring(0, 3) + '*' * (username.length - 3);
    return '$obscuredUsername@$domain';
  }

  Future<void> _sendCode() async {
    final email = _emailCtrl.text.trim().toLowerCase();
    
    if (email.isEmpty || !email.contains('@')) {
      showCustomSnackBar(context, 'Please enter a valid email address.');
      return;
    }

    setState(() => _loading = true);

    try {
      String otpCode = (1000 + Random().nextInt(9000)).toString();
      debugPrint("OTP: $otpCode");

      await FirebaseFirestore.instance
          .collection('otp_verifications')
          .doc(email)
          .set({
        'code': otpCode,
        'createdAt': FieldValue.serverTimestamp(),
        'expiry': DateTime.now().add(const Duration(minutes: 15)),
      });

      final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost',
        },
        body: json.encode({
          'service_id': 'service_cg1dlar',
          'template_id': 'template_drwxhsn',
          'user_id': 'jlSLGvB_WkhiStTDA',
          'template_params': {
            'email': email,
            'passcode': otpCode,
            'time': '15',
          },
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          showCustomSnackBar(
            context, 
            'Verification code sent successfully!',
            type: SnackBarType.success,
          );
          
          context.push('/verify-otp', extra: {
            'userId': 'actual_uid_if_needed',
            'email': email,
            'obscuredEmail': _obscureEmail(email),
          });
        }
      } else {
        debugPrint("EmailJS Error: ${response.body}");
        throw Exception('Failed to send email: ${response.body}');
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) {
        showCustomSnackBar(context, 'Error: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryBlue),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: primaryPink.withOpacity(0.3),
                          ),
                          child: const Icon(
                            Icons.email_rounded,
                            size: 50,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'Password Recovery',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Please enter your registered email to receive the verification code.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  MyTextField(
                    hintText: 'Your Email',
                    prefixIcon: Icons.email,
                    controller: _emailCtrl,
                    obscureText: false,
                  ),
                  const SizedBox(height: 40),
                  MyButton(
                    text: 'Send Verification Code',
                    onTap: (_) => _sendCode(),
                    isLoading: _loading,
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RecoveryEmailCodeScreen extends StatefulWidget {
  final String userId;
  final String obscuredEmail;
  final String email;

  const RecoveryEmailCodeScreen({
    super.key,
    required this.userId,
    required this.obscuredEmail,
    required this.email,
  });

  @override
  State<RecoveryEmailCodeScreen> createState() =>
      _RecoveryEmailCodeScreenState();
}

class _RecoveryEmailCodeScreenState extends State<RecoveryEmailCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();
  final int _codeLength = 4;
  bool _isVerifying = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_codeFocusNode);
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  Future<void> _verifyCode(String code) async {
    if (code.length != _codeLength) return;

    _codeFocusNode.unfocus();
    setState(() => _isVerifying = true);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('otp_verifications')
          .doc(widget.email)
          .get();

      if (!doc.exists) {
        throw Exception('OTP not found.');
      }

      final data = doc.data()!;
      final String correctOTP = data['code'];
      final DateTime expiry = (data['expiry'] as Timestamp).toDate();

      if (DateTime.now().isAfter(expiry)) {
        throw Exception('OTP has expired.');
      }

      if (code == correctOTP) {
        if (mounted) {
          showCustomSnackBar(context, 'Verification successful!',
              type: SnackBarType.success);
          context.push('/setup-newpass', extra: {'userId': widget.userId});
        }
      } else {
        throw Exception('Invalid verification code.');
      }
    } catch (e) {
      _codeController.clear();
      FocusScope.of(context).requestFocus(_codeFocusNode);
      if (mounted) {
        showCustomSnackBar(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  Future<void> _resendCode() async {
    setState(() => _isResending = true);
    _codeController.clear();

    try {
      String otpCode = (1000 + Random().nextInt(9000)).toString();

      await FirebaseFirestore.instance
          .collection('otp_verifications')
          .doc(widget.email)
          .set({
        'code': otpCode,
        'createdAt': FieldValue.serverTimestamp(),
        'expiry': DateTime.now().add(const Duration(minutes: 15)),
      });

      await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost',
        },
        body: json.encode({
          'service_id': 'service_cg1dlar',
          'template_id': 'template_drwxhsn',
          'user_id': 'jlSLGvB_WkhiStTDA',
          'template_params': {
            'email': widget.email,
            'passcode': otpCode,
            'time': '15 minutes',
          },
        }),
      );

      if (mounted) {
        showCustomSnackBar(context, 'New code sent!',
            type: SnackBarType.success);
        FocusScope.of(context).requestFocus(_codeFocusNode);
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(context, 'Failed to resend code.');
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  Widget buildCodeDots() {
    final currentLength = _codeController.text.length;

    return Column(
      children: [
        GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(_codeFocusNode),
          child: AbsorbPointer(
            absorbing: _isVerifying || _isResending,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_codeLength, (index) {
                final isFilled = index < currentLength;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(horizontal: 10.0),
                  width: isFilled ? 20 : 15,
                  height: isFilled ? 20 : 15,
                  decoration: BoxDecoration(
                    color: isFilled ? primaryBlue : Colors.grey.shade400,
                    shape: BoxShape.circle,
                    boxShadow: isFilled
                        ? [
                            BoxShadow(
                                color: primaryBlue.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 2)
                          ]
                        : [],
                  ),
                );
              }),
            ),
          ),
        ),
        SizedBox(
          width: 0,
          height: 0,
          child: TextFormField(
            controller: _codeController,
            focusNode: _codeFocusNode,
            autofocus: true,
            keyboardType: TextInputType.number,
            maxLength: _codeLength,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(height: 0, fontSize: 0),
            decoration: const InputDecoration(
              counterText: "",
              border: InputBorder.none,
            ),
            onChanged: (value) {
              if (value.length == _codeLength) {
                _verifyCode(value);
              }
            },
          ),
        ),
      ],
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
              const RecoveryHeader(),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.4 - 30),
                      const Text(
                        'Verify OTP Code',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Please enter the 4-digit code we sent to',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.obscuredEmail,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 40),
                      buildCodeDots(),
                      const SizedBox(height: 20),
                      if (_isVerifying)
                        Center(
                          child: CircularProgressIndicator(
                            color: primaryBlue,
                            strokeWidth: 3,
                          ),
                        )
                      else
                        const SizedBox(height: 25),
                      const Spacer(),
                      ElevatedButton(
                        onPressed:
                            _isVerifying || _isResending ? null : _resendCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryPink,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isResending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text('Resend Code',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                      ),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ),
                      const SizedBox(height: 20),
                    ],
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