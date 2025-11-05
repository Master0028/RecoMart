import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import '../../../../../models/product.model.dart';
import '../../../../../provider/product_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DropdownEntry {
  final String id;
  final String name;
  DropdownEntry({required this.id, required this.name});
}

class ProductForm extends StatefulWidget {
  final void Function(Map<String, dynamic>) onSubmit;
  final void Function()? onDelete;
  final String buttonLabel;
  final Map<String, dynamic>? initialProduct;

  const ProductForm({
    super.key,
    required this.onSubmit,
    this.onDelete,
    required this.buttonLabel,
    this.initialProduct,
  });

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late TextEditingController discountController;
  late TextEditingController stockController;
  late TextEditingController avgRatingController;
  late TextEditingController reviewCountController;

  String? imageUrl;
  Uint8List? imageBytes;
  File? imageFile;

  String? selectedCategoryId;
  String? selectedBrandId;
  bool isActive = true;
  bool isLoading = false;

  final ImagePicker _picker = ImagePicker();

  List<DropdownEntry> categories = [];
  List<DropdownEntry> brands = [];

  @override
  void initState() {
    super.initState();
    final data = widget.initialProduct;

    nameController = TextEditingController(text: data?['name'] ?? '');
    descriptionController = TextEditingController(text: data?['description'] ?? '');
    priceController = TextEditingController(text: data?['price']?.toString() ?? '');
    discountController = TextEditingController(text: data?['discount']?.toString() ?? '');
    stockController = TextEditingController(text: data?['stock']?.toString() ?? '');
    avgRatingController = TextEditingController(text: data?['averageRating']?.toString() ?? '');
    reviewCountController = TextEditingController(text: data?['reviewCount']?.toString() ?? '');

    imageUrl = data?['imageUrl'];
    selectedCategoryId = data?['categoryId'];
    selectedBrandId = data?['brandId'];
    isActive = data?['isActive'] ?? true;

    _loadDropdownData();
  }

  /// 🔹 Lấy danh sách Category và Brand từ Firestore
  Future<void> _loadDropdownData() async {
    try {
      final categorySnapshot = await FirebaseFirestore.instance.collection('categories').get();
      final brandSnapshot = await FirebaseFirestore.instance.collection('brands').get();

      setState(() {
        categories = categorySnapshot.docs
            .map((doc) => DropdownEntry(id: doc.id, name: doc['name']))
            .toList();
        brands = brandSnapshot.docs
            .map((doc) => DropdownEntry(id: doc.id, name: doc['name']))
            .toList();
      });
    } catch (e) {
      debugPrint("⚠️ Lỗi load category/brand: $e");
    }
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

  /// 🔹 Submit sản phẩm (add/update vào Firebase)
  Future<void> _handleSubmit() async {
    setState(() => isLoading = true);
    try {
      if (nameController.text.trim().isEmpty) throw Exception('Please enter the product name');
      if (selectedCategoryId == null) throw Exception('Select category');
      if (imageUrl == null || imageUrl!.isEmpty) throw Exception('Select product image');

      final productData = {
        'id': widget.initialProduct?['id'] ?? '',
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'categoryId': selectedCategoryId,
        'brandId': selectedBrandId,
        'price': double.tryParse(priceController.text) ?? 0,
        'discount': double.tryParse(discountController.text) ?? 0,
        'isActive': isActive,
        'imageUrl': imageUrl ?? '',
        'averageRating': double.tryParse(avgRatingController.text) ?? 0,
        'reviewCount': int.tryParse(reviewCountController.text) ?? 0,
        'stock': int.tryParse(stockController.text) ?? 0,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // 🔹 Chuyển Map → ProductModel
      final productModel = ProductModel.fromJson(productData);

      final provider = Provider.of<ProductProvider>(context, listen: false);

      if (widget.initialProduct == null) {
        await provider.addProduct(productModel);
      } else {
        await provider.updateProduct(productModel.id, productModel);
      }

      widget.onSubmit(productData);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop();
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }


  Future<void> _handleDelete() async {
    if (widget.onDelete == null) return;
    setState(() => isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));
    widget.onDelete!();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final navigator = Navigator.of(context);
      if (navigator.canPop()) {
        navigator.pop();
      }
    });

    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    discountController.dispose();
    stockController.dispose();
    avgRatingController.dispose();
    reviewCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 800,
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Cột trái: ảnh
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildImagePreview(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: isLoading ? null : _pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text('Choose Image', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // 🔹 Cột phải: form
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTextField(nameController, 'Product Name'),
                      const SizedBox(height: 16),
                      _buildTextField(descriptionController, 'Description', maxLines: 3),
                      const SizedBox(height: 16),
                      _buildDropdownCategory('Category', selectedCategoryId, categories),
                      const SizedBox(height: 16),
                      _buildDropdownCategory('Brand', selectedBrandId, brands),
                      const SizedBox(height: 16),
                      _buildTextField(priceController, 'Price', inputType: TextInputType.number),
                      const SizedBox(height: 16),
                      _buildTextField(discountController, 'Discount (%)', inputType: TextInputType.number),
                      const SizedBox(height: 16),
                      _buildTextField(stockController, 'Stock', inputType: TextInputType.number),
                      const SizedBox(height: 16),
                      _buildTextField(avgRatingController, 'Rating (readonly)', readOnly: true),
                      const SizedBox(height: 16),
                      _buildTextField(reviewCountController, 'Count Review (readonly)', readOnly: true),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: isActive,
                            onChanged: (v) => setState(() => isActive = v!),
                          ),
                          const Text('Product is available'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                minimumSize: const Size(double.infinity, 48),
                              ),
                              child: Text(widget.buttonLabel,
                                  style: const TextStyle(color: Colors.white)),
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
                                child: const Text('Delete',
                                    style: TextStyle(color: Colors.white)),
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
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    if (imageBytes != null) {
      return Image.memory(imageBytes!, fit: BoxFit.cover);
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(imageUrl!, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Center(child: Text('Không tải được ảnh')));
    } else if (imageFile != null && !kIsWeb) {
      return Image.file(imageFile!, fit: BoxFit.cover);
    } else {
      return const Center(child: Text('Chưa có ảnh'));
    }
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1, bool readOnly = false, TextInputType? inputType}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
      ),
    );
  }

  Widget _buildDropdownCategory(String label, String? value, List<DropdownEntry> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: list.any((item) => item.id == value) ? value : null,
          items: list
              .map((item) => DropdownMenuItem(
            value: item.id,
            child: Text(item.name),
          ))
              .toList(),
          onChanged: (v) {
            setState(() {
              if (label == 'Category') {
                selectedCategoryId = v;
              } else {
                selectedBrandId = v;
              }
            });
          },
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
      ],
    );
  }
}
