import 'dart:io' show File;
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BrandForm extends StatefulWidget {
  final void Function(Map<String, dynamic>) onSubmit;
  final void Function()? onDelete;
  final String buttonLabel;
  final Map<String, dynamic>? initialBrand;

  const BrandForm({
    super.key,
    required this.onSubmit,
    this.onDelete,
    required this.buttonLabel,
    this.initialBrand,
  });

  @override
  State<BrandForm> createState() => _BrandFormState();
}

class _BrandFormState extends State<BrandForm> {
  late TextEditingController nameController;
  File? imageFile;
  Uint8List? imageBytes;
  Map<String, dynamic>? brandImage;
  bool isActive = true;
  bool isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final data = widget.initialBrand;

    nameController = TextEditingController(text: data?['brand_name']?.toString() ?? '');
    isActive = data?['isActive'] is bool ? data!['isActive'] : true;

    if (data?['brand_image'] != null && data!['brand_image'] is Map<String, dynamic>) {
      final imageMap = data['brand_image'] as Map<String, dynamic>;
      if (imageMap['url'] != null && imageMap['url'].toString().isNotEmpty) {
        brandImage = {
          'url': imageMap['url'].toString(),
          'public_id': imageMap['public_id']?.toString() ?? '',
        };
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      const String FE_IMAGE_URL = 'https://placehold.co/600x400.png'; 
      const String FE_PUBLIC_ID = 'fe_public_id';
      
      final bytes = await pickedFile.readAsBytes();

      setState(() {
        imageBytes = bytes;
        imageFile = null;
        brandImage = {
          'url': FE_IMAGE_URL,
          'public_id': FE_PUBLIC_ID,
        };
        isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Image picking failed.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleSubmit() async {
    setState(() {
      isLoading = true;
    });

    try {
      final brandName = nameController.text.trim();
      if (brandName.isEmpty) {
        throw Exception('Tên thương hiệu không được để trống');
      }
      if (brandImage == null || brandImage!['url'] == null || brandImage!['url'].isEmpty) {
        throw Exception('URL hình ảnh không được để trống');
      }

      await Future.delayed(const Duration(milliseconds: 500));

      final brandData = {
        'brand_name': brandName,
        'brand_image': brandImage!,
        'isActive': isActive,
        '_id': widget.initialBrand != null ? widget.initialBrand!['_id'] : 'FE_NEW_ID',
      };
      
      widget.onSubmit(brandData); 
      
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thương hiệu đã được lưu thành công')),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lưu thương hiệu thất bại: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleDelete() async {
    if (widget.initialBrand == null || widget.onDelete == null) return;

    final brandId = widget.initialBrand!['_id']?.toString();
    if (brandId == null || brandId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID thương hiệu không hợp lệ')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      widget.onDelete!();
      
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thương hiệu đã được xóa thành công')),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xóa thương hiệu thất bại.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 600,
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: brandImage != null && brandImage!['url'] != null && brandImage!['url'].isNotEmpty
                          ? Image.network(
                        brandImage!['url'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(child: Text('Error Loading Image'));
                        },
                      )
                          : imageBytes != null
                          ? Image.memory(
                        imageBytes!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(child: Text('Error Loading Image'));
                        },
                      )
                          : imageFile != null && !kIsWeb
                          ? Image.file(
                        imageFile!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(child: Text('Error Loading Image'));
                        },
                      )
                          : const Center(child: Text('No Image')),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: isLoading ? null : _pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text(
                        'Chọn Hình Ảnh',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên Thương Hiệu',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Checkbox(
                            value: isActive,
                            onChanged: (value) => setState(() => isActive = value!),
                          ),
                          const Text('Kích Hoạt'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                minimumSize: const Size(double.infinity, 48),
                              ),
                              child: Text(
                                widget.buttonLabel,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          if (widget.onDelete != null) ...[
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _handleDelete,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  minimumSize: const Size(double.infinity, 48),
                                ),
                                child: const Text(
                                  'Xóa',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}