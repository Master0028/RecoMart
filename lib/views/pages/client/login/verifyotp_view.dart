import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final Color primaryBlue = Colors.blue.shade700;
const int otpLength = 4;

void showCustomSnackBar(BuildContext context, String message, {SnackBarType type = SnackBarType.error}) {
  final backgroundColor = type == SnackBarType.error ? Colors.red : Colors.green;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

enum SnackBarType { error, info }

class AnimatedOtpInput extends StatefulWidget {
  final TextEditingController controller;
  final bool autoFocus;

  const AnimatedOtpInput({
    super.key,
    required this.controller,
    this.autoFocus = false,
  });

  @override
  State<AnimatedOtpInput> createState() => _AnimatedOtpInputState();
}

class _AnimatedOtpInputState extends State<AnimatedOtpInput> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });

    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_focusNode);
      });
    }
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
      width: 60,
      height: 60,
      transform: Matrix4.identity()..scale(_isFocused ? 1.05 : 1.0),
      decoration: BoxDecoration(
        color: _isFocused ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isFocused ? primaryBlue : Colors.transparent,
          width: 2,
        ),
        boxShadow: _isFocused
            ? [BoxShadow(color: primaryBlue.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]
            : [],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        enableSuggestions: false,
        autocorrect: false,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryBlue),
        decoration: const InputDecoration(counterText: "", border: InputBorder.none),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          } else if (value.isEmpty) {
            FocusScope.of(context).previousFocus();
          }
        },
      ),
    );
  }
}

class MyButton extends StatelessWidget {
  final String text;
  final Function(BuildContext) onTap;
  final bool isLoading;

  const MyButton({super.key, required this.text, required this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : () => onTap(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
        shadowColor: primaryBlue.withOpacity(0.4),
      ),
      child: isLoading
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
          : Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }
}

class VerifyOtpView extends StatefulWidget {
  final String? email;
  final String? userId;
  final String obscuredEmail;

  const VerifyOtpView({
    super.key,
    this.email,
    required this.userId,
    required this.obscuredEmail,
  });

  @override
  State<VerifyOtpView> createState() => _VerifyOtpViewState();
}

class _VerifyOtpViewState extends State<VerifyOtpView> {
  final otp1Controller = TextEditingController();
  final otp2Controller = TextEditingController();
  final otp3Controller = TextEditingController();
  final otp4Controller = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    otp4Controller.addListener(_checkAndVerifyOtp);
  }

  void _checkAndVerifyOtp() {
    if (otp4Controller.text.length == 1 && !_isLoading) {
      verifyOtp(context);
    }
  }

  @override
  void dispose() {
    for (var c in [otp1Controller, otp2Controller, otp3Controller, otp4Controller]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> verifyOtp(BuildContext context) async {
    String otpCode = otp1Controller.text + otp2Controller.text + otp3Controller.text + otp4Controller.text;

    if (otpCode.length < otpLength) {
      showCustomSnackBar(context, 'Please enter the full 4-digit code.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        context.push('/setup-pass', extra: {
          'userId': widget.userId,
        });
      }
    } catch (e) {
      if (mounted) showCustomSnackBar(context, 'Verification failed. Please try again.');
      for (var c in [otp1Controller, otp2Controller, otp3Controller, otp4Controller]) {
        c.clear();
      }
      FocusScope.of(context).unfocus();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      showCustomSnackBar(context, 'A new code has been sent to ${widget.obscuredEmail}', type: SnackBarType.info);
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryBlue),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              CircleAvatar(
                radius: 60,
                backgroundColor: primaryBlue.withOpacity(0.1),
                child: Icon(Icons.mark_email_read_rounded, size: 60, color: primaryBlue),
              ),
              const SizedBox(height: 30),
              const Text('OTP Verification', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text(
                'Enter the 4-digit code sent to\n${widget.obscuredEmail}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 16, height: 1.4),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AnimatedOtpInput(controller: otp1Controller, autoFocus: true),
                  AnimatedOtpInput(controller: otp2Controller),
                  AnimatedOtpInput(controller: otp3Controller),
                  AnimatedOtpInput(controller: otp4Controller),
                ],
              ),
              const SizedBox(height: 40),
              MyButton(text: 'Verify OTP', onTap: verifyOtp, isLoading: _isLoading),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Didn't receive the code?", style: TextStyle(color: Colors.black54)),
                  TextButton(
                    onPressed: _isLoading ? null : _resendOtp,
                    child: Text("Resend", style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}