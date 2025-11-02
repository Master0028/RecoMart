import 'package:flutter/material.dart';
import 'package:recomart/views/pages/admin/coupon/widgets/add_coupon_btn.dart';
import 'package:recomart/views/pages/admin/coupon/widgets/coupon_table.dart';

final List<Map<String, dynamic>> FE_COUPONS_STUB = [
  {'id': 'c1', 'code': 'SALE2024', 'discount': 0.1, 'min_amount': 500000},
  {'id': 'c2', 'code': 'FREESHIP', 'discount': 20000, 'min_amount': 0},
];

class CouponManagementScreen extends StatelessWidget {
  CouponManagementScreen({super.key});

  final bool _isLoading = false;
  final String? _errorMessage = null;
  
  final List<Map<String, dynamic>> _coupons = FE_COUPONS_STUB;

  @override
  Widget build(BuildContext context) {

    return Container(
      color: Colors.grey[100],
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AddCouponButton(),
            const SizedBox(height: 16),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              Center(child: Text(_errorMessage!))
            else if (_coupons.isEmpty)
              const Center(child: Text('No coupons found'))
            else
              CouponTable(
                coupons: _coupons,
              ),
          ],
        ),
      ),
    );
  }
}