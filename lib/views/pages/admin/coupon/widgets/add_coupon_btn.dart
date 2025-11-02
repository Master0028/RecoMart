import 'package:flutter/material.dart';
import 'package:recomart/views/pages/admin/coupon/widgets/coupon_form.dart'; 

class AddCouponButton extends StatelessWidget {
  const AddCouponButton({super.key});

  void _showAddCouponDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            "Add Coupon",
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
            child: CouponForm(
              buttonLabel: "Add Coupon",
              onSubmit: (couponData) {
                print("Coupon data submitted (FE action): $couponData");
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
      onPressed: () => _showAddCouponDialog(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        "ADD COUPON",
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}