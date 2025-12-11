import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final Color primaryBlue = Colors.blue.shade700;
const Color cancelButtonColor = Color(0xFFEEEEEE);
const Color cancelTextColor = Color(0xFF616161);

class RecoveryMethodScreen extends StatefulWidget {
  const RecoveryMethodScreen({super.key});

  @override
  State<RecoveryMethodScreen> createState() => _RecoveryMethodScreenState();
}

class _RecoveryMethodScreenState extends State<RecoveryMethodScreen> {
  String _selectedMethod = 'SMS';
  final TextEditingController _inputController = TextEditingController();

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
        if (!didPop) {
          context.pop();
        }
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 30),
                        buildAvatar(),
                        const SizedBox(height: 20),
                        const Text(
                          'Julius',
                          textAlign: TextAlign.center,
                          style: TextStyle(
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
                        
                        // Selection Tiles
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
                        
                        const Spacer(),
                        buildNextButton(context),
                        const SizedBox(height: 15),
                        buildCancelButton(context),
                        const SizedBox(height: 30),
                      ],
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

  Widget buildAvatar() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.pink.shade100,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
          ),
          Container(
            width: 105,
            height: 105,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                    "https://cdn3d.iconscout.com/3d/premium/thumb/man-avatar-6299539-5187871.png"),
                fit: BoxFit.cover,
              ),
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ],
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
          _inputController.clear(); // Clear input when switching methods
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
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? primaryBlue : Colors.grey,
            ),
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
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isSelected ? 1.0 : 0.0,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNextButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (_inputController.text.isEmpty) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Please enter your ${_selectedMethod.toLowerCase()}'))
           );
           return;
        }
        
        // Navigate
        context.push('/setup-pass');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 5,
        shadowColor: primaryBlue.withOpacity(0.4),
      ),
      child: const Text('Next',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget buildCancelButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        context.pop();
      },
      style: TextButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: cancelButtonColor,
      ),
      child: const Text('Cancel',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: cancelTextColor)),
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
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
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
            : [
                const BoxShadow(
                  color: Colors.transparent,
                  blurRadius: 0,
                  offset: Offset(0, 0),
                )
              ],
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
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              widget.icon,
              key: ValueKey(widget.icon),
              color: _isFocused ? primaryBlue : Colors.grey,
            ),
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