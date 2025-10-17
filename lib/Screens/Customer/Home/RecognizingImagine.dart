import 'dart:ui';
import 'package:flutter/material.dart';

class ImageRecognitionScreen extends StatefulWidget {
  const ImageRecognitionScreen({super.key});

  @override
  State<ImageRecognitionScreen> createState() => _ImageRecognitionScreenState();
}

class _ImageRecognitionScreenState extends State<ImageRecognitionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand, // Đảm bảo Stack lấp đầy màn hình
        children: [
          Image.network(
            'https://images.pexels.com/photos/1036627/pexels-photo-1036627.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
            fit: BoxFit.cover,
          ),

          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Colors.black.withOpacity(0.1),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 60.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 200,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return LinearProgressIndicator(
                        value: _controller.value,
                        minHeight: 6,
                        backgroundColor: Colors.white.withOpacity(0.5),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                        borderRadius: BorderRadius.circular(5),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Recognizing',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),

                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    debugPrint("Đã hủy nhận dạng!");
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.close, color: Colors.black, size: 28),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}