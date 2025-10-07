import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final Color primaryBlue = Colors.blue.shade700; 

class PasswordVerifyScreen extends StatefulWidget {
  final String userName; 
  
  const PasswordVerifyScreen({super.key, this.userName = "Julius"});

  @override
  State<PasswordVerifyScreen> createState() => _PasswordVerifyScreenState();
}

class _PasswordVerifyScreenState extends State<PasswordVerifyScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final int _passwordLength = 8;
  
  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updateScreen);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_passwordFocusNode);
    });
  }
  
  @override
  void dispose() {
    _passwordController.removeListener(_updateScreen);
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
  
  void _updateScreen() {
    setState(() {});
  }
  
  void _showKeyboard() {
    FocusScope.of(context).requestFocus(_passwordFocusNode);
  }
 
  Widget buildAvatarPlaceholder() {
    return Center(
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
    );
  }

  Widget buildPasswordInputArea() {
    final currentLength = _passwordController.text.length;
    
    return Column(
      children: [
        GestureDetector(
          onTap: _showKeyboard,
          child: AbsorbPointer( 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_passwordLength, (index) {
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
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            autofocus: true,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: _passwordLength,
            style: const TextStyle(height: 0, fontSize: 0),
            decoration: const InputDecoration(
              counterText: "",
              border: InputBorder.none,
            ),
            onChanged: (value) {
                if (value.length == _passwordLength) {
                    _passwordFocusNode.unfocus(); 
                }
            },
          ),
        ),
      ],
    );
  }
  
  Widget buildNotYouButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Not you?',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black54,
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: Icon(
            Icons.arrow_forward,
            color: primaryBlue,
            size: 24,
          ),
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: SizedBox(
          height: size.height,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: Container(
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
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 100),

                      buildAvatarPlaceholder(),
                      
                      const SizedBox(height: 20),

                      Text(
                        'Hello, ${widget.userName}!!',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      
                      const SizedBox(height: 40),

                      const Text(
                        'Type your password',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      
                      const SizedBox(height: 30),

                      buildPasswordInputArea(),

                      const Spacer(),

                      buildNotYouButton(context),
                      
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