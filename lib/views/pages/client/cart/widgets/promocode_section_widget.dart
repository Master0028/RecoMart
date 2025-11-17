import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/helpers/formatMoney.dart';
import 'package:recomart/components/custom/snackbar.dart';
import 'package:recomart/services/coupon.service.dart';
import 'package:recomart/services/user.service.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../provider/cart_provider.dart';

class PromocodeSectionWidget extends StatefulWidget {
  const PromocodeSectionWidget({super.key, required this.cartItems});
  final List<dynamic> cartItems;

  @override
  State<PromocodeSectionWidget> createState() =>
      _PromocodeSectionWidgetState();
}

class _PromocodeSectionWidgetState extends State<PromocodeSectionWidget> {
  final _couponController = TextEditingController();
  final _pointsController = TextEditingController();

  final _couponService = CouponService();
  final _userService = UserService();

  double _couponDiscountMoney = 0;
  bool _isApplyingCoupon = false;
  double _availablePoints = 0;
  int _usedPoints = 0;

  @override
  void initState() {
    super.initState();
    _loadUserPoints();
  }

  Future<void> _loadUserPoints() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final points = await _userService.getLoyaltyPoints(uid);
    setState(() => _availablePoints = points);
  }

  Future<void> _applyCoupon() async {
    final provider = Provider.of<CartProvider>(context, listen: false);
    final code = _couponController.text.trim();

    if (code.isEmpty) {
      showCustomSnackBar(context, 'Vui lòng nhập mã giảm giá trước khi áp dụng',
          type: SnackBarType.error);
      return;
    }

    setState(() => _isApplyingCoupon = true);

    try {
      // 🔹 Lấy toàn bộ coupon từ Firestore
      final coupons = await _couponService.fetchCoupons();

      // 🔹 Tìm coupon khớp mã
      final coupon = coupons.firstWhere(
            (c) => c.code.toLowerCase() == code.toLowerCase(),
        orElse: () => throw Exception('Mã giảm giá không hợp lệ'),
      );

      // 🔹 Kiểm tra số lượt dùng
      if (coupon.usedCount >= coupon.maxUsage) {
        throw Exception('Mã giảm giá "$code" đã hết lượt sử dụng');
      }

      // 🔹 Áp dụng giảm giá
      setState(() {
        _couponDiscountMoney = coupon.discountValue;
        _isApplyingCoupon = false;
      });

      provider.applyCoupon(coupon);

      showCustomSnackBar(
        context,
        'Áp dụng mã $code thành công (-${formatMoney(coupon.discountValue)})',
        type: SnackBarType.success,
      );
    } catch (e) {
      setState(() => _isApplyingCoupon = false);
      showCustomSnackBar(context, e.toString(), type: SnackBarType.error);
    }
  }

  void _applyLoyaltyPoints() {
    final provider = Provider.of<CartProvider>(context, listen: false);
    final input = int.tryParse(_pointsController.text.trim()) ?? 0;

    if (input <= 0) {
      showCustomSnackBar(context, 'Nhập số điểm hợp lệ để sử dụng',
          type: SnackBarType.error);
      return;
    }

    if (input > _availablePoints) {
      showCustomSnackBar(context, 'Bạn không đủ điểm để sử dụng!',
          type: SnackBarType.error);
      return;
    }

    setState(() => _usedPoints = input);
    provider.setDiscounts(points: _usedPoints);

    showCustomSnackBar(
      context,
      'Dùng $_usedPoints điểm (-${formatMoney(_usedPoints * 1000)})',
      type: SnackBarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: AppColors.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(FeatherIcons.tag, color: AppColors.primary, size: 20),
                SizedBox(width: 10),
                Text('Voucher / Coupon',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    decoration: InputDecoration(
                      hintText: 'Nhập mã giảm giá',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isApplyingCoupon ? null : _applyCoupon,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary),
                  child: _isApplyingCoupon
                      ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                      : const Text('Áp dụng'),
                ),
              ],
            ),
            if (_couponDiscountMoney > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Giảm ${formatMoney(_couponDiscountMoney)} được áp dụng',
                  style: const TextStyle(color: Colors.green, fontSize: 13),
                ),
              ),
            const Divider(height: 30, color: Colors.black12),
            const Row(
              children: [
                Icon(FeatherIcons.gift, color: AppColors.primary, size: 20),
                SizedBox(width: 10),
                Text('Loyalty Points',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Bạn có ${_availablePoints.toStringAsFixed(0)} điểm (1 điểm = 1.000đ).',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pointsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Nhập số điểm muốn dùng',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _applyLoyaltyPoints,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary),
                  child: const Text('Dùng điểm'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}