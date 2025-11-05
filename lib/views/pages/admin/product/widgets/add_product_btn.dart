import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../provider/product_provider.dart';
import '../../../../../models/product.model.dart';
import 'product_form.dart';

class AddProductButton extends StatelessWidget {
  final VoidCallback onProductAdded; // ✅ callback từ cha (ProductTable)

  const AddProductButton({super.key, required this.onProductAdded});

  void _handleAddProduct(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            "Add Product",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: ProductForm(
            buttonLabel: "Add Product",
            onSubmit: (productData) async {
              print("Adding product: $productData");
              // Sau khi thêm xong, gọi callback để cha reload data
              onProductAdded();

              // Đóng dialog an toàn
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (Navigator.of(context).canPop()) Navigator.of(context).pop();
              });
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _handleAddProduct(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        "ADD PRODUCT",
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}
