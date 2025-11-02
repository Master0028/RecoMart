import 'package:flutter/material.dart';
import 'product_form.dart';

class AddProductButton extends StatelessWidget {
  const AddProductButton({super.key});

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
          content: Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: const InputDecorationTheme(
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange, width: 2),
                ),
                labelStyle: TextStyle(color: Colors.black),
                floatingLabelStyle: TextStyle(color: Colors.orange),
              ),
            ),
            child: ProductForm(
              buttonLabel: "Add Product",
              onSubmit: (productData) {
                print("FE Action: Attempt to add product with data: $productData");
                Navigator.of(context).pop();
              },
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