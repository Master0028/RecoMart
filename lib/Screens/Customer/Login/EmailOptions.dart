import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recomart/Screens/Customer/Login/SetUpNewPasswordScreen.dart';

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
          top: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.pink.shade100,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Colors.white, 
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.grey,
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


class RecoveryEmailCodeScreen extends StatefulWidget {
  final String obscuredEmail; 
  
  const RecoveryEmailCodeScreen({
    super.key, 
    this.obscuredEmail = 'gmai******@mail.com'
  });

  @override
  State<RecoveryEmailCodeScreen> createState() => _RecoveryEmailCodeScreenState();
}

class _RecoveryEmailCodeScreenState extends State<RecoveryEmailCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();
  final int _codeLength = 6;
  
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SetupNewPasswordScreen()));
                    debugPrint('OTP 6 số đã nhập xong.');
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
                    'Enter 6-digits code we sent you\non your email address',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    widget.obscuredEmail,
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
                      debugPrint('Gửi lại Email OTP!');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SetupNewPasswordScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPink,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Send Again', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  
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