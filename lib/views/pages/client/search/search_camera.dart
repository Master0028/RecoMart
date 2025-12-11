import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class SearchCameraPage extends StatefulWidget {
  const SearchCameraPage({super.key});

  @override
  State<SearchCameraPage> createState() => _SearchCameraPageState();
}

class _SearchCameraPageState extends State<SearchCameraPage>
    with SingleTickerProviderStateMixin {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isSearching = false;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _isSearching = false;
          _animationController.reset();
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Unable to access image. Please check permissions.')),
      );
    }
  }

  void _performImageSearch() async {
    if (_imageFile == null) return;

    setState(() {
      _isSearching = true;
    });

    _animationController.repeat(reverse: true);

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    setState(() {
      _isSearching = false;
    });
    
    _animationController.stop();
    _animationController.reset();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Similar products found! (Demo)')),
    );
    context.push('/search-results', extra: _imageFile);
  }

  void _clearImage() {
    setState(() {
      _imageFile = null;
      _isSearching = false;
      _animationController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      // AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Image Search", style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Image Display Area
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
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(_imageFile!, fit: BoxFit.cover),

                          if (_isSearching)
                            Container(color: Colors.black.withOpacity(0.3)),

                          if (_isSearching)
                            AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Positioned(
                                  top: -100 + (_animation.value * (size.height * 0.6)), // Move scanner down
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 100, // Height of the gradient tail
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.blue.withOpacity(0.0),
                                          Colors.blue.withOpacity(0.5),
                                        ],
                                      ),
                                      border: const Border(
                                        bottom: BorderSide(color: Colors.blue, width: 2),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                          // 4. Close Button
                          if (!_isSearching)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: IconButton(
                                onPressed: _clearImage,
                                icon: const Icon(Icons.close, color: Colors.white),
                                style: IconButton.styleFrom(
                                    backgroundColor: Colors.black54),
                              ),
                            ),
                        ],
                      ),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.center_focus_weak,
                            size: 80, color: Colors.grey),
                        SizedBox(height: 10),
                        Text(
                          'Snap or select a photo\nto find products',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
            ),
          ),

          if (_imageFile != null && !_isSearching)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ElevatedButton(
                onPressed: _performImageSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("SEARCH THIS PRODUCT",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          
          if (_isSearching)
             const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text("Scanning...", style: TextStyle(color: Colors.white, letterSpacing: 1.5)),
            ),

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
                // Gallery Button
                _buildActionButton(
                  icon: Icons.image_outlined,
                  label: 'Gallery',
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),

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
                      child: Icon(Icons.camera_alt,
                          color: Colors.white, size: 32),
                    ),
                  ),
                ),

                _buildActionButton(
                  icon: Icons.history,
                  label: 'History',
                  onPressed: () {
                     ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('History feature coming soon')),
                      );
                  },
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