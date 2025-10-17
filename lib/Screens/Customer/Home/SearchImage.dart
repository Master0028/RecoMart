import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ImageSearchScreen extends StatelessWidget {
  const ImageSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String backgroundImageUrl = 'https://images.pexels.com/photos/1036627/pexels-photo-1036627.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1';

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Ảnh nền
              Image.network(
                backgroundImageUrl,
                fit: BoxFit.cover,
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 250,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Nút Gallery
                    _buildIconButton(
                      icon: Icons.photo_library_outlined,
                      label: 'Gallery',
                      onTap: () {
                        debugPrint('Gallery tapped');
                      },
                    ),

                    _buildCameraButton(
                      onTap: () {
                        context.push('/recognizing-imagine');
                        debugPrint("Đang chuyển đến màn hình nhận dạng ảnh...");
                      },
                    ),

                    const SizedBox(width: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap, // Sử dụng hàm onTap đã được truyền
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            // ✨ CẢI THIỆN: Thêm icon camera vào trong nút
            child: const Icon(Icons.camera_alt, color: Colors.white, size: 35),
          ),
          const SizedBox(height: 8),
          const Text(
            'Camera',
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}