import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:recomart/Screens/Customer/Login/EmailOptions.dart';

final Color primaryBlue = Colors.blue.shade700; 

class RecoveryCodeScreen extends StatefulWidget {
  const RecoveryCodeScreen({super.key});

  @override
  State<RecoveryCodeScreen> createState() => _RecoveryCodeScreenState();
}

class _RecoveryCodeScreenState extends State<RecoveryCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();
  final int _codeLength = 4;
  
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
  
  Widget buildCodeDots() {
    final currentLength = _codeController.text.length;
    
    return Column(
      children: [
        GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(_codeFocusNode),
          child: AbsorbPointer(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_codeLength, (index) {
                final isFilled = index < currentLength;
                
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isFilled ? primaryBlue : Colors.grey.shade500,
                    shape: BoxShape.circle,
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
            obscureText: true,
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
                    _codeFocusNode.unfocus();
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
      body: Stack(
        children: [
          const RecoveryHeader(),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 250),

                  const Text(
                    'Password Recovery',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text(
                    'Enter 4-digits code we sent you\non your phone number',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Số điện thoại mờ
                  Text(
                    '+84376****48',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 40),

                  buildCodeDots(),
                  
                  const Spacer(),

                  ElevatedButton(
                    onPressed: () {
                      context.push('/setup-newpass');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Send Again', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  
                  // Nút Cancel
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}