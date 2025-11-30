import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SearchCameraPage extends StatefulWidget {
  const SearchCameraPage({super.key});

  @override
  State<SearchCameraPage> createState() => _SearchCameraPageState();
}

class _SearchCameraPageState extends State<SearchCameraPage> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isSearching = false;

  // Hàm chọn ảnh từ nguồn (Gallery hoặc Camera)
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85, // Nén nhẹ để upload nhanh hơn
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Lỗi chọn ảnh: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể truy cập hình ảnh. Vui lòng kiểm tra quyền truy cập.')),
      );
    }
  }

  // Hàm giả lập gửi ảnh đi tìm kiếm
  void _performImageSearch() async {
    if (_imageFile == null) return;

    setState(() {
      _isSearching = true;
    });

    // Giả lập delay gọi API (2 giây)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isSearching = false;
    });

    // Ở đây bạn sẽ Navigate sang trang kết quả hoặc hiện bottom sheet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã tìm thấy sản phẩm tương tự! (Demo)')),
    );
    
    // Ví dụ: context.push('/search-results', extra: _imageFile);
  }

  // Hàm xóa ảnh để chọn lại
  void _clearImage() {
    setState(() {
      _imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      // Nút Back và Tiêu đề
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Tìm kiếm bằng hình ảnh", style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Khu vực hiển thị ảnh
          Expanded(
            child: Container(
              width: size.width,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: _imageFile != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        // Ảnh đã chọn
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        ),
                        // Nút xóa ảnh
                        Positioned(
                          top: 10,
                          right: 10,
                          child: IconButton(
                            onPressed: _clearImage,
                            icon: const Icon(Icons.close, color: Colors.white),
                            style: IconButton.styleFrom(backgroundColor: Colors.black54),
                          ),
                        ),
                        // Loading khi đang tìm kiếm
                        if (_isSearching)
                          Container(
                            color: Colors.black54,
                            child: const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          ),
                      ],
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.center_focus_weak, size: 80, color: Colors.grey),
                        SizedBox(height: 10),
                        Text(
                          'Chụp hoặc chọn ảnh sản phẩm\nđể tìm kiếm',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
            ),
          ),

          // Nút tìm kiếm (Chỉ hiện khi đã có ảnh)
          if (_imageFile != null && !_isSearching)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ElevatedButton(
                onPressed: _performImageSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("TÌM KIẾM SẢN PHẨM NÀY", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),

          // Bottom Bar (Gallery & Camera)
          Container(
            height: size.height * 0.15,
            padding: const EdgeInsets.only(bottom: 20, top: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Nút Gallery
                _buildActionButton(
                  icon: Icons.image_outlined,
                  label: 'Thư viện',
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),

                // Nút Camera (Nổi bật)
                InkWell(
                  onTap: () => _pickImage(ImageSource.camera),
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.4),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.camera_alt, color: Colors.white, size: 32),
                    ),
                  ),
                ),

                // Placeholder để cân đối layout (hoặc nút xoay camera nếu cần)
                 const SizedBox(
                   width: 80,
                   child: Center(
                    // Có thể thay bằng nút flash hoặc lịch sử
                     child: Icon(Icons.history, color: Colors.grey),
                   ),
                 ),
              ],
            ),
          ),
        ],
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
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30, color: Colors.black87),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}