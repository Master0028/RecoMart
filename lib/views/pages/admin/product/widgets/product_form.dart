import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../helpers/formatMoney.dart';
import 'product_variant_form.dart';

class ProductImage {
  final String? url;
  final String? publicId;

  ProductImage({this.url, this.publicId});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'url': url,
      'public_id': publicId,
    };
  }

  factory ProductImage.fromMap(Map<String, dynamic> map) {
    return ProductImage(
      url: map['url'] as String?,
      publicId: map['public_id'] as String?,
    );
  }
}

class DropdownEntry {
  final String id;
  final String name;
  DropdownEntry({required this.id, required this.name});
}

final List<DropdownEntry> FE_CATEGORIES = [
  DropdownEntry(id: 'cat_id_1', name: 'Category A'),
  DropdownEntry(id: 'cat_id_2', name: 'Category B'),
];

final List<DropdownEntry> FE_BRANDS = [
  DropdownEntry(id: 'brand_id_1', name: 'Brand X'),
  DropdownEntry(id: 'brand_id_2', name: 'Brand Y'),
];

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
  File? imageFile;
  Uint8List? imageBytes;
  ProductImage? productImage;
  String? selectedCategoryId;
  String? selectedBrandId;
  bool isDisabled = false;
  List<Map<String, dynamic>> variants = [];
  bool isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final data = widget.initialProduct;

    nameController = TextEditingController(text: data?['product_name']?.toString() ?? '');
    selectedCategoryId = data?['category']?.toString();
    selectedBrandId = data?['brand']?.toString();
    isDisabled = data?['disabled']?.toString().toLowerCase() == 'true';

    if (data?['product_image'] != null) {
      productImage = ProductImage.fromMap(data!['product_image'] as Map<String, dynamic>);
    }

    if (data?['variants'] != null && data!['variants'] is List) {
      variants = List<Map<String, dynamic>>.from(data['variants']);
    } else {
      variants = [];
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
        productImage = ProductImage(
          url: FE_IMAGE_URL,
          publicId: FE_PUBLIC_ID,
        );
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

  Future<void> _handleAddProduct() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (nameController.text.trim().isEmpty) {
        throw Exception('Product name is required');
      }
      if (selectedCategoryId == null || selectedCategoryId!.trim().isEmpty) {
        throw Exception('Please select a category');
      }
      if (productImage == null || productImage!.url == null || productImage!.url!.isEmpty) {
        throw Exception('Please upload a product image');
      }

      await Future.delayed(const Duration(milliseconds: 500)); 

      final productData = {
        'product_name': nameController.text.trim(),
        'category_id': selectedCategoryId!.trim(),
        'brand_id': selectedBrandId?.trim(),
        'product_image': productImage!.toMap(),
        '_id': 'FE_NEW_ID',
        'variants': variants,
      };

      widget.onSubmit(productData);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add product: ${e.toString().replaceAll('Exception: ', '')}')),
      );
    }
  }

  Future<void> _handleUpdateProduct() async {
    if (widget.initialProduct == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final productId = widget.initialProduct!['_id']?.toString();
      if (productId == null) {
        throw Exception('Invalid product ID');
      }
      
      await Future.delayed(const Duration(milliseconds: 500)); 

      final productData = {
          'product_name': nameController.text.trim(),
          'category_id': selectedCategoryId,
          '_id': productId,
          'variants': variants,
      };

      widget.onSubmit(productData); 
      
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update product: ${e.toString().replaceAll('Exception: ', '')}')),
      );
    }
  }
  
  Future<void> _handleDelete() async {
    if (widget.initialProduct == null || widget.onDelete == null) return;

    final productId = widget.initialProduct!['_id']?.toString();
    if (productId == null || productId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid product ID')),
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
        const SnackBar(content: Text('Product deleted successfully')),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete product')),
      );
    }
  }
  
  void _showVariantForm({Map<String, dynamic>? initialVariant, int? index}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            initialVariant == null ? 'Add Product Variant' : 'Edit Product Variant',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: ProductVariantForm(
            onSubmit: (variantData) async {
              setState(() {
                if (index != null) {
                  variants[index] = variantData;
                } else {
                  variants.add(variantData);
                }
              });
              Navigator.of(context).pop();
            },
            initialProduct: widget.initialProduct,
            initialVariant: initialVariant,
          ),
        );
      },
    );
  }
  
  @override
  void dispose() {
    nameController.dispose();
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
                      child: productImage?.url != null
                          ? Image.network(
                        productImage!.url!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(child: Text('Error Loading Image'));
                        },
                      )
                          : imageBytes != null && imageBytes is Uint8List
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
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Product Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Category',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return SizedBox(
                                width: double.infinity,
                                child: DropdownMenu<String>(
                                  width: constraints.maxWidth,
                                  initialSelection: selectedCategoryId,
                                  onSelected: (value) => setState(() => selectedCategoryId = value),
                                  dropdownMenuEntries: FE_CATEGORIES
                                      .map((category) => DropdownMenuEntry(
                                    value: category.id,
                                    label: category.name,
                                  ))
                                      .toList(),
                                  textStyle: const TextStyle(fontSize: 14, color: Colors.black),
                                  menuStyle: MenuStyle(
                                    maximumSize: WidgetStatePropertyAll(
                                      Size(constraints.maxWidth, double.infinity),
                                    ),
                                    backgroundColor: const WidgetStatePropertyAll(Colors.white),
                                  ),
                                  inputDecorationTheme: const InputDecorationTheme(
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding:
                                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Brand',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return SizedBox(
                                width: double.infinity,
                                child: DropdownMenu<String>(
                                  width: constraints.maxWidth,
                                  initialSelection: selectedBrandId,
                                  onSelected: (value) => setState(() => selectedBrandId = value),
                                  dropdownMenuEntries: FE_BRANDS
                                      .map((brand) => DropdownMenuEntry(
                                    value: brand.id,
                                    label: brand.name,
                                  ))
                                      .toList(),
                                  textStyle: const TextStyle(fontSize: 14, color: Colors.black),
                                  menuStyle: MenuStyle(
                                    maximumSize: WidgetStatePropertyAll(
                                      Size(constraints.maxWidth, double.infinity),
                                    ),
                                    backgroundColor: const WidgetStatePropertyAll(Colors.white),
                                  ),
                                  inputDecorationTheme: const InputDecorationTheme(
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding:
                                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      
                      Row(
                        children: [
                          Checkbox(
                            value: isDisabled,
                            onChanged: (value) => setState(() => isDisabled = value!),
                          ),
                          const Text('Disable Product'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      if (widget.initialProduct != null)
                        ElevatedButton(
                          onPressed: isLoading ? null : () => _showVariantForm(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: const Text(
                            'Add Variant',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      const SizedBox(height: 20),
                      
                      if (variants.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Variants',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            ...variants.asMap().entries.map((entry) {
                              final index = entry.key;
                              final variant = entry.value;
                              
                              final imageList = variant['images'] as List<dynamic>?;
                              String? imageUrl;
                              if (imageList != null && imageList.isNotEmpty) {
                                final firstImage = imageList[0] as Map<String, dynamic>?;
                                imageUrl = firstImage != null ? firstImage['url'] as String? : null;
                              } else {
                                imageUrl = null;
                              }
                              
                              return InkWell(
                                onTap: () => _showVariantForm(initialVariant: variant, index: index),
                                child: ListTile(
                                  leading: SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: imageUrl != null
                                        ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Text('No Image');
                                      },
                                    )
                                        : const Text('No Image'),
                                  ),
                                  title: Text(variant['variantName']?.toString() ?? 'N/A'),
                                  subtitle: Text(
                                    'Color: ${variant['variantColor'] ?? 'N/A'}, Price: ${formatMoney(variant['price'] ?? 0)}, Quantity: ${variant['quantity']?.toString() ?? 'N/A'}, Rating: ${variant['averageRating']?.toString() ?? 'N/A'}',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        variants.removeAt(index);
                                      });
                                    },
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 20),
                          ],
                        ),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : (widget.initialProduct == null ? _handleAddProduct : _handleUpdateProduct),
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
}