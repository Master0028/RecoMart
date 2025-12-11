import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show Uint8List;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../../models/brand.model.dart';
import '../../../../../provider/brand_provider.dart';

class BrandForm extends StatefulWidget {
  final BrandModel? initialBrand;

  const BrandForm({super.key, this.initialBrand});

  @override
  State<BrandForm> createState() => _BrandFormState();
}

class _BrandFormState extends State<BrandForm> {
  late TextEditingController nameController;
  bool isActive = true;
  File? imageFile;
  Uint8List? imageBytes;
  String? imageUrl;
  bool isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final brand = widget.initialBrand;
    nameController = TextEditingController(text: brand?.name ?? '');
    imageUrl = brand?.imageUrl ?? '';
    isActive = brand?.isActive ?? true;
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
      debugPrint("Upload Cloudinary failed: $e");
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Image upload failed')));
      }
    }
  }

  Future<void> _handleSubmit() async {
    final brandProvider = Provider.of<BrandProvider>(context, listen: false);
    final name = nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Brand name cannot be empty')));
      return;
    }

    setState(() => isLoading = true);

    try {
      final newBrand = BrandModel(
        id: widget.initialBrand?.id ?? '',
        name: name,
        isActive: isActive,
        imageUrl: imageUrl ?? '',
      );

      if (widget.initialBrand == null) {
        await brandProvider.addBrand(newBrand);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Brand added successfully')));
      } else {
        await brandProvider.updateBrand(newBrand);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Brand updated successfully')));
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _handleDelete() async {
    if (widget.initialBrand == null) return;

    final brandProvider = Provider.of<BrandProvider>(context, listen: false);

    setState(() => isLoading = true);
    try {
      await brandProvider.deleteBrand(widget.initialBrand!.id);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Brand deleted successfully')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Delete error: $e')));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
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
                      child: imageUrl != null && imageUrl!.isNotEmpty
                          ? Image.network(imageUrl!, fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(child: Icon(Icons.broken_image)))
                          : imageBytes != null
                              ? Image.memory(imageBytes!, fit: BoxFit.cover)
                              : const Center(child: Text('No Image')),
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
                          labelText: 'Brand Name',
                          border: OutlineInputBorder(),
                        ),
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
                                minimumSize: const Size(double.infinity, 48),
                              ),
                              child: Text(
                                widget.initialBrand == null
                                    ? 'Add Brand'
                                    : 'Update Brand',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          if (widget.initialBrand != null) ...[
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
            Positioned.fill(
              child: Container(
                color: Colors.black12,
                child: const Center(child: CircularProgressIndicator()),
              ),
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