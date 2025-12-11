import 'package:flutter/material.dart';
import 'brand_form.dart';

class AddBrandButton extends StatelessWidget {
  const AddBrandButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                "Add Brand",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: BrandForm(),
            );
          },
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        "ADD BRAND",
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}