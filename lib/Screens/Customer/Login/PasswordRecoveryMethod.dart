import 'package:flutter/material.dart';
import 'package:recomart/Screens/Customer/Login/EmailOptions.dart';
import 'package:recomart/Screens/Customer/Login/RecoverySMSCodeScreen.dart';

final Color primaryBlue = Colors.blue.shade700; 

Widget buildRecoveryHeader(BuildContext context) {
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

class RecoveryMethodScreen extends StatefulWidget {
  const RecoveryMethodScreen({super.key});

  @override
  State<RecoveryMethodScreen> createState() => _RecoveryMethodScreenState();
}

class _RecoveryMethodScreenState extends State<RecoveryMethodScreen> {
  String _selectedMethod = 'SMS';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          buildRecoveryHeader(context),

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
                    'How you would like to restore your password?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 40),

                  buildOptionTile('SMS', 'SMS', Icons.message, _selectedMethod == 'SMS', Colors.blue.shade100),
                  const SizedBox(height: 20),

                  buildOptionTile('Email', 'Email', Icons.email, _selectedMethod == 'Email', Colors.pink.shade100),
                  
                  const Spacer(),

                  ElevatedButton(
                      onPressed: () {
                          if (_selectedMethod == 'SMS') {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const RecoveryCodeScreen(),
                                  ),
                              );
                          } else if (_selectedMethod == 'Email') {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const RecoveryEmailCodeScreen(), 
                                  ),
                              );
                          }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Next', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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

  Widget buildOptionTile(String label, String value, IconData icon, bool isSelected, Color activeColor) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = value;
        });
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontSize: 16, color: isSelected ? primaryBlue : Colors.black)),
              CircleAvatar(
                radius: 12,
                backgroundColor: isSelected ? primaryBlue : Colors.grey.shade300,
                child: isSelected 
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : const Icon(Icons.circle_outlined, size: 16, color: Colors.white),
              )
            ],
          ),
        ),
      ),
    );
  }
}