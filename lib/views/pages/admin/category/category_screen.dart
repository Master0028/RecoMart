import 'package:flutter/material.dart';
import 'package:recomart/views/pages/admin/category/widgets/add_category_btn.dart';
import 'package:recomart/views/pages/admin/category/widgets/category_table.dart';

final List<Map<String, dynamic>> FE_CATEGORIES_DATA_STUB = [
  {
    'id': 'c1', 
    'name': 'Laptop & Notebooks',
    'description': 'High performance machines.',
    'isActive': true,
    'image': {'url': 'https://placehold.co/40x40.png'},
  },
  {
    'id': 'c2', 
    'name': 'Monitors & Displays',
    'description': 'Visual clarity devices.',
    'isActive': false,
    'image': {'url': 'https://placehold.co/40x40.png'},
  },
];
const int FE_CATEGORIES_COUNT = 2;

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {

  @override
  Widget build(BuildContext context) {
    final List<dynamic> categories = FE_CATEGORIES_DATA_STUB;

    return Container(
      color: Colors.grey[100],
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AddCategoryButton(), 
            const SizedBox(height: 16),
            CategoryTable(categories: categories as dynamic), 
          ],
        ),
      ),
    );
  }
}