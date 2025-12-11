import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../../models/category.model.dart';
import '../../../../../provider/category_provider.dart';

class CategoryForm extends StatefulWidget {
  final void Function(Map<String, dynamic>) onSubmit;
  final void Function()? onDelete;
  final String buttonLabel;
  final CategoryModel? initialCategory;

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
  // Controllers
  late TextEditingController nameController;
  late TextEditingController descriptionController;

  // State Variables
  File? imageFile;
  Uint8List? imageBytes;
  String? imageUrl;
  bool isActive = true;
  bool isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameController =
        TextEditingController(text: widget.initialCategory?.name ?? '');
    descriptionController =
        TextEditingController(text: widget.initialCategory?.description ?? '');
    imageUrl = widget.initialCategory?.imageUrl;
    isActive = widget.initialCategory?.isActive ?? true;
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => isLoading = true);

    try {
      final bytes = await picked.readAsBytes();
      
      final uri = Uri.parse("https://api.cloudinary.com/v1_1/dqiclelb9/image/upload");
      final uploadPreset = "dacntt";

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: picked.name,
        ));

      final response = await request.send();
      final resBody = await response.stream.bytesToString();
      final data = jsonDecode(resBody);

      if (response.statusCode == 200 && data['secure_url'] != null) {
        if (mounted) {
          setState(() {
            imageBytes = bytes;
            imageUrl = data['secure_url'];
            imageFile = null;
            isLoading = false;
          });
        }
      } else {
        throw Exception("Upload failed: ${data['error']?['message'] ?? 'Unknown error'}");
      }
    } catch (e) {
      debugPrint("Cloudinary upload error: $e");
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Image upload failed: $e')));
      }
    }
  }

  Future<void> _handleSubmit() async {
    final name = nameController.text.trim();
    final desc = descriptionController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Category Name cannot be empty')));
      return;
    }

    setState(() => isLoading = true);

    try {
      final provider = Provider.of<CategoryProvider>(context, listen: false);
      final category = CategoryModel(
        id: widget.initialCategory?.id ?? 0,
        name: name,
        description: desc,
        isActive: isActive,
        imageUrl: imageUrl ?? '',
      );

      if (widget.initialCategory == null) {
        await provider.addCategory(category);
      } else {
        await provider.updateCategory(category);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.initialCategory == null
              ? 'Category added successfully!'
              : 'Category updated successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving category: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _handleDelete() async {
    if (widget.initialCategory == null) return;

    // Show Confirmation Dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Category"),
        content: const Text("Are you sure you want to delete this category?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final provider = Provider.of<CategoryProvider>(context, listen: false);
    setState(() => isLoading = true);

    try {
      await provider.deleteCategory(widget.initialCategory!.id.toString());
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category deleted successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting category: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
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
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade50,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildImageWidget(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : _pickImage,
                      icon: const Icon(Icons.upload_file, size: 18),
                      label: const Text('Choose Image'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              
              // --- Form Fields Section (Right) ---
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Category Name',
                          hintText: 'e.g., Electronics',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description (Optional)',
                          hintText: 'Brief description of the category...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Is Active'),
                        subtitle: const Text('Visible to customers'),
                        value: isActive,
                        onChanged: (val) => setState(() => isActive = val),
                        activeColor: Colors.green,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                widget.initialCategory == null
                                    ? 'Add Category'
                                    : 'Save Changes',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          if (widget.initialCategory != null) ...[
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 100,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _handleDelete,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade50,
                                  foregroundColor: Colors.red,
                                  elevation: 0,
                                  minimumSize: const Size(0, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(color: Colors.red.shade200),
                                  ),
                                ),
                                child: const Text('Delete'),
                              ),
                            ),
                          ]
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // --- Loading Overlay ---
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.7),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageWidget() {
    // 1. Show Network Image if available
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      if (imageUrl!.endsWith('.svg')) {
        return SvgPicture.network(
          imageUrl!,
          fit: BoxFit.contain,
          placeholderBuilder: (_) => const Center(child: CircularProgressIndicator()),
        );
      }
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, color: Colors.grey, size: 40),
              Text("Image Error", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    if (imageBytes != null && imageBytes!.isNotEmpty) {
      try {
        final header = imageBytes!.take(5).toList();
        if (header.length >= 2 && header[0] == 0x3C && header[1] == 0x3F) {
           return SvgPicture.memory(imageBytes!, fit: BoxFit.contain);
        }
        
        return Image.memory(
          imageBytes!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Center(child: Text('Invalid Data')),
        );
      } catch (_) {
        return const Center(child: Text('Preview Error'));
      }
    }

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, color: Colors.grey, size: 48),
          SizedBox(height: 8),
          Text("No Image Selected", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}