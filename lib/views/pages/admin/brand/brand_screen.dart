import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recomart/models/brand.model.dart';
import 'package:recomart/provider/brand_provider.dart';
import 'package:recomart/views/pages/admin/brand/widgets/add_brand_btn.dart';
import 'package:recomart/views/pages/admin/brand/widgets/brand_table.dart';

class BrandManagementScreen extends StatefulWidget {
  const BrandManagementScreen({super.key});

  @override
  State<BrandManagementScreen> createState() => _BrandManagementScreenState();
}

class _BrandManagementScreenState extends State<BrandManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<BrandProvider>(context, listen: false).fetchBrands());
  }

  @override
  Widget build(BuildContext context) {
    final brandProvider = Provider.of<BrandProvider>(context);
    final List<BrandModel> brands = brandProvider.brands;

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
            if (brandProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (brands.isEmpty)
              const Text("We have no any brand in Firestore.")
            else
              BrandTable(brands: brands),
          ],
        ),
      ),
    );
  }
}
