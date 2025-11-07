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
  late TextEditingController nameController;
  late TextEditingController descriptionController;
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
  }

  /// 🔹 Chọn và upload ảnh thật lên Cloudinary
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
        setState(() {
          imageBytes = bytes;
          imageUrl = data['secure_url'];
          imageFile = null;
          isLoading = false;
        });
      } else {
        throw Exception("Upload failed: ${data['error']}");
      }
    } catch (e) {
      debugPrint("❌ Upload Cloudinary failed: $e");
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Upload ảnh thất bại')));
      }
    }
  }

  // 💾 Lưu lên Firebase qua Provider
  Future<void> _handleSubmit() async {
    final name = nameController.text.trim();
    final desc = descriptionController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Tên không được để trống')));
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
              ? 'Thêm danh mục thành công!'
              : 'Cập nhật danh mục thành công!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lưu danh mục: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ❌ Xóa khỏi Firestore
  Future<void> _handleDelete() async {
    if (widget.initialCategory == null) return;

    final provider = Provider.of<CategoryProvider>(context, listen: false);
    setState(() => isLoading = true);

    try {
      await provider.deleteCategory(widget.initialCategory!.id.toString());
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa danh mục')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa: $e')),
      );
    } finally {
      setState(() => isLoading = false);
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
                      child: Builder(
                        builder: (context) {
                          // Ưu tiên URL ảnh
                          if (imageUrl != null && imageUrl!.isNotEmpty) {
                            return Image.network(
                              imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(child: Text('Invalid Image URL')),
                            );
                          }

                          // Nếu có bytes — kiểm tra định dạng
                          if (imageBytes != null && imageBytes!.isNotEmpty) {
                            // Kiểm tra header (8 byte đầu)
                            final header = imageBytes!.take(8).toList();
                            // Header XML/SVG: [0x3c, 0x3f, 0x78, 0x6d, 0x6c] = "<?xml"
                            final isXml = header.length >= 5 &&
                                header[0] == 0x3c &&
                                header[1] == 0x3f &&
                                header[2] == 0x78 &&
                                header[3] == 0x6d &&
                                header[4] == 0x6c;

                            if (isXml) {
                              return SvgPicture.memory(imageBytes!);
                            }

                            try {
                              return Image.memory(
                                imageBytes!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(child: Text('Invalid image data')),
                              );
                            } catch (_) {
                              return const Center(child: Text('Invalid image data'));
                            }
                          }

                          // Nếu không có ảnh
                          return const Center(child: Text('No Image'));
                        },
                      ),

                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: isLoading ? null : _pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text('Choose Image',
                          style: TextStyle(color: Colors.white)),
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
                          labelText: 'Category Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (optional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Checkbox(
                            value: isActive,
                            onChanged: (v) => setState(() => isActive = v!),
                          ),
                          const Text('Active'),
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
                                minimumSize:
                                const Size(double.infinity, 48),
                              ),
                              child: Text(
                                widget.initialCategory == null
                                    ? 'Add Category'
                                    : 'Update',
                                style:
                                const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          if (widget.initialCategory != null) ...[
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _handleDelete,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  minimumSize:
                                  const Size(double.infinity, 48),
                                ),
                                child: const Text('Delete',
                                    style: TextStyle(color: Colors.white)),
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
