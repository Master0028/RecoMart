import 'package:flutter/material.dart';

class SearchCameraPage extends StatelessWidget {
  const SearchCameraPage({super.key});

  Future<void> _onGalleryPressed(BuildContext context) async {
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('FE: Mở Image Picker để chọn ảnh từ Thư viện.')),
    );
    debugPrint('FE: Kích hoạt chức năng chọn ảnh từ Gallery.');
  }

  void _onCameraPressed() {
    debugPrint('FE: Mở Camera.');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Center(
        child: Container(
          width: size.width,
          height: size.height * 0.8,
          color: Colors.white,
          child: const Center(
            child: Text(
              'Khu vực xem trước Camera (hoặc nội dung chính) - FE',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ),
      
      bottomNavigationBar: Container(
        height: size.height * 0.15,
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionButton(
              icon: Icons.image_outlined,
              label: 'Gallery',
              onPressed: () => _onGalleryPressed(context),
            ),
            
            InkWell(
              onTap: _onCameraPressed,
              child: Container(
                width: 65,
                height: 65,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.camera_alt, color: Colors.white),
                ),
              ),
            ),
            
            const SizedBox(
              width: 80,
              child: Center(
                child: Text(
                  'Camera',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: SizedBox(
        width: 80, // Độ rộng cố định
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}