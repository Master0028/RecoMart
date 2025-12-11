import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recomart/provider/coupon_provider.dart';
import 'package:recomart/views/pages/admin/coupon/widgets/add_coupon_btn.dart';
import 'package:recomart/views/pages/admin/coupon/widgets/coupon_table.dart';
import 'package:recomart/models/coupon.model.dart';

class CouponManagementScreen extends StatefulWidget {
  const CouponManagementScreen({super.key});

  @override
  State<CouponManagementScreen> createState() => _CouponManagementScreenState();
}

class _CouponManagementScreenState extends State<CouponManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CouponProvider>(context, listen: false).fetchCoupons();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CouponProvider>(context);
    final List<CouponModel> coupons = provider.coupons;
    final bool isLoading = provider.loading;
    final String? errorMessage = provider.error;

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

            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (errorMessage != null)
              Center(child: Text(errorMessage))
            else if (coupons.isEmpty)
                const Center(child: Text('There are not any coupons here!'))
              else
                CouponTable(coupons: coupons),
          ],
        ),
      ),
    );
  }
}
