import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color primaryColor = Color(0xFF1976D2); 

class OtpInput extends StatelessWidget {
  final TextEditingController controller;
  final bool autoFocus;

  const OtpInput({
    super.key,
    required this.controller,
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        autofocus: autoFocus,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        cursorColor: primaryColor,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          counterText: "",
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: primaryColor),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            FocusScope.of(context).nextFocus(); 
          }
        },
      ),
    );
  }
}
