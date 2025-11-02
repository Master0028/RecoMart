import 'package:flutter/material.dart';
import 'package:recomart/views/pages/admin/brand/widgets/add_brand_btn.dart';
import 'package:recomart/views/pages/admin/brand/widgets/brand_table.dart';

final List<BrandModel> FE_BRANDS_STUB = [
  BrandModel(id: '1', name: 'Apple', isActive: true, image: BrandImage(url: 'https://placehold.co/40x40.png', publicId: 'a')),
  BrandModel(id: '2', name: 'Samsung', isActive: true, image: BrandImage(url: 'https://placehold.co/40x40.png', publicId: 'b')),
  BrandModel(id: '3', name: 'HP', isActive: false, image: BrandImage(url: 'https://placehold.co/40x40.png', publicId: 'c')),
];

class BrandManagementScreen extends StatefulWidget {
  const BrandManagementScreen({super.key});

  @override
  State<BrandManagementScreen> createState() => _BrandManagementScreenState();
}

class _BrandManagementScreenState extends State<BrandManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final List<BrandModel> brands = FE_BRANDS_STUB;

    return Container(
      color: Colors.grey[100],
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AddBrandButton(), 
            const SizedBox(height: 16),
            BrandTable(brands: brands), 
          ],
        ),
      ),
    );
  }
}