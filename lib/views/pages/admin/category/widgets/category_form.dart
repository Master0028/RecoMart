import 'dart:io' show File;
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CategoryForm extends StatefulWidget {
  final void Function(Map<String, dynamic>) onSubmit;
  final void Function()? onDelete;
  final String buttonLabel;
  final Map<String, dynamic>? initialCategory;

  const CategoryForm({
    super.key,
    required this.onSubmit,
    this.onDelete,
    required this.buttonLabel,
    this.initialCategory,
  });

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  File? imageFile;
  Uint8List? imageBytes;
  Map<String, dynamic>? categoryImage;
  bool isActive = true;
  bool isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final data = widget.initialCategory;

    nameController = TextEditingController(text: data?['category_name']?.toString() ?? '');
    descriptionController = TextEditingController(text: data?['category_description']?.toString() ?? '');
    isActive = data?['isActive'] is bool ? data!['isActive'] : true;

    if (data?['category_image'] != null && data!['category_image'] is Map<String, dynamic>) {
      final imageMap = data['category_image'] as Map<String, dynamic>;
      if (imageMap['url'] != null && imageMap['url'].toString().isNotEmpty) {
        categoryImage = {
          'url': imageMap['url'].toString(),
          'public_id': imageMap['public_id']?.toString() ?? '',
        };
      }
    }
  }

  // Logic chọn và xử lý hình ảnh (FE Only)
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
        categoryImage = {
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

  // Logic Submit/Update (FE Only)
  Future<void> _handleSubmit() async {
    setState(() {
      isLoading = true;
    });

    try {
      final categoryName = nameController.text.trim();
      if (categoryName.isEmpty) {
        throw Exception('Tên danh mục không được để trống');
      }
      if (categoryImage == null || categoryImage!['url'] == null || categoryImage!['url'].isEmpty) {
        throw Exception('URL không được để trống');
      }
      
      await Future.delayed(const Duration(milliseconds: 500));

      final categoryData = {
        'category_name': categoryName,
        'category_image': categoryImage!,
        'category_description': descriptionController.text.trim(),
        'isActive': isActive,
        if (widget.initialCategory != null) '_id': widget.initialCategory!['_id'] ?? 'FE_ID',
        if (widget.initialCategory == null) '_id': 'FE_NEW_ID',
      };
      
      widget.onSubmit(categoryData);
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category saved successfully')),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save category: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Logic Delete (FE Only)
  Future<void> _handleDelete() async {
    if (widget.initialCategory == null || widget.onDelete == null) return;

    final categoryId = widget.initialCategory!['_id']?.toString();
    if (categoryId == null || categoryId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid category ID')),
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
        const SnackBar(content: Text('Category deleted successfully')),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete category')),
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
                      child: categoryImage != null && categoryImage!['url'] != null && categoryImage!['url'].isNotEmpty
                          ? Image.network(
                        categoryImage!['url'],
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
                        'Choose Image',
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
                      // Input Tên Danh mục
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Category Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Input Mô tả
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Category Description (Optional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      // Checkbox Active
                      Row(
                        children: [
                          Checkbox(
                            value: isActive,
                            onChanged: (value) => setState(() => isActive = value!),
                          ),
                          const Text('Active'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Nút Submit/Update và Delete
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
                                  'Delete',
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
    descriptionController.dispose();
    super.dispose();
  }
}