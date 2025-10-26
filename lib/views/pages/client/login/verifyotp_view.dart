import 'package:go_router/go_router.dart';
import 'package:recomart/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recomart/components/custom/snackbar.dart';
import 'package:recomart/services/app_exceptions.dart';
import 'package:recomart/services/auth.service.dart';
import 'widgets/button.dart'; 
import 'widgets/otp_input.dart'; 

final Color primaryBlue = Colors.blue.shade700;
final Color primaryPink = Colors.pink.shade300;
const int otpLength = 4;

class OtpInput extends StatelessWidget {
  final TextEditingController controller;
  final bool autoFocus;

  const OtpInput({super.key, required this.controller, this.autoFocus = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: TextFormField(
        controller: controller,
        autofocus: autoFocus,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        maxLength: 1,
        cursorColor: primaryBlue,
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryBlue, width: 2),
          ),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (value.length == 1 && value.isNotEmpty) {
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
      ),
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
            )
          : Text(
              text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
    );
  }
}

class VerifyOtpView extends StatefulWidget {
  const VerifyOtpView({super.key, String? email, required userId, required obscuredEmail});

  @override
  _VerifyOtpViewState createState() => _VerifyOtpViewState();
}

class _VerifyOtpViewState extends State<VerifyOtpView> {
  final otp1Controller = TextEditingController();
  final otp2Controller = TextEditingController();
  final otp3Controller = TextEditingController();
  final otp4Controller = TextEditingController();
  
  bool _isLoading = false;
  String _obscuredEmail = '******@mail.com';
  String? _userId;

  @override
  void initState() {
    super.initState();
    otp4Controller.addListener(_checkAndVerifyOtp);
  }

  void _loadArguments() {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
        _userId = args['userId'] as String?;
        _obscuredEmail = args['obscuredEmail'] as String? ?? '******@mail.com';
    } else if (args is String) {
        _userId = args;
    }

    if (_userId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showCustomSnackBar(context, 'Lỗi: Không tìm thấy ID người dùng.'); 
        context.pop();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadArguments();
  }

  void _checkAndVerifyOtp() {
    if (otp4Controller.text.length == 1 && !_isLoading) {
      verifyOtp(context);
    }
  }

  @override
  void dispose() {
    otp1Controller.dispose();
    otp2Controller.dispose();
    otp3Controller.dispose();
    otp4Controller.dispose();
    super.dispose();
  }

  Future<void> verifyOtp(BuildContext context) async {
    final userId = ModalRoute.of(context)!.settings.arguments as String;
    
    if (_userId == null) return;

    String otpCode = otp1Controller.text +
        otp2Controller.text +
        otp3Controller.text +
        otp4Controller.text;

    if (otpCode.length < otpLength) {
       showCustomSnackBar(context, 'Vui lòng nhập đủ 4 chữ số OTP.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = AuthService();
      await auth.verifyOtp(otpCode: otpCode, id: _userId!); 
      
      // Giả lập delay API
      await Future.delayed(const Duration(seconds: 1)); 

      if (mounted) {
        context.push('/change-password/$_userId');
      }
    } on BadRequestException catch (e) {
      if (mounted) {
        showCustomSnackBar(context, e.message);
      }
      otp1Controller.clear();
      otp2Controller.clear();
      otp3Controller.clear();
      otp4Controller.clear();
      FocusScope.of(context).requestFocus();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _resendOtp() async {

    if (!_isLoading) {
      showCustomSnackBar(context, 'Mã OTP mới đã được gửi.', type: SnackBarType.info);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryBlue),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Center(
            child: SizedBox(
              width: 450,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: primaryBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.mark_email_read_rounded, // Icon hiện đại hơn
                        size: 65,
                        color: primaryBlue,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'Xác Thực OTP',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Mô tả chi tiết
                  Text(
                    'Vui lòng nhập 4 chữ số mã xác thực đã được gửi đến email ${_obscuredEmail}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  
                  const SizedBox(height: 40),

                  // --- HÀNG OTP INPUTS ĐÃ REDESIGN ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OtpInput(controller: otp1Controller, autoFocus: true),
                      OtpInput(controller: otp2Controller),
                      OtpInput(controller: otp3Controller),
                      OtpInput(controller: otp4Controller),
                    ],
                  ),
                  
                  const SizedBox(height: 40),

                  // --- NÚT XÁC THỰC ---
                  MyButton(
                    text: 'Xác Thực OTP',
                    onTap: (_) => verifyOtp(context),
                    isLoading: _isLoading,
                  ),
                  
                  const SizedBox(height: 20),

                  // --- NÚT GỬI LẠI MÃ ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Không nhận được mã? ",
                        style: TextStyle(color: Colors.black54),
                      ),
                      TextButton(
                        onPressed: _isLoading ? null : _resendOtp,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                        ),
                        child: Text(
                          "Gửi lại",
                          style: TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}