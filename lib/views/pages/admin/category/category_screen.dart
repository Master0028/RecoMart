import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recomart/provider/category_provider.dart';
import 'package:recomart/views/pages/admin/category/widgets/add_category_btn.dart';
import 'package:recomart/views/pages/admin/category/widgets/category_table.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  @override
  void initState() {
    super.initState();
    // 🧠 Lấy dữ liệu thật từ Firestore khi mở màn hình
    Future.microtask(() =>
        Provider.of<CategoryProvider>(context, listen: false).fetchCategories());
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

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

            if (categoryProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (categoryProvider.categories.isEmpty)
              const Text("Không có danh mục nào trong Firestore.")
            else
              CategoryTable(categories: categoryProvider.categories),
          ],
        ),
      ),
    );
  }
}
