import 'package:flutter/material.dart';
import 'product_form.dart';

class AddProductButton extends StatelessWidget {
  final VoidCallback onProductAdded;

  const AddProductButton({super.key, required this.onProductAdded});

  void _handleAddProduct(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 850, 
            height: MediaQuery.of(context).size.height * 0.85, 
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Text(
                  "Add Product",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(height: 24, thickness: 1),

                Expanded(
                  child: SingleChildScrollView(
                    child: ProductForm(
                      buttonLabel: "Add Product",
                      onSubmit: (productData) async {
                        print("Adding product: $productData");
                        onProductAdded();
                        // Đóng dialog
                        if (Navigator.of(dialogContext).canPop()) {
                          Navigator.of(dialogContext).pop();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
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
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 4,
      ),
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        "ADD PRODUCT",
        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}