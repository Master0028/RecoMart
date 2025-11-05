import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/helpers/formatMoney.dart';
import 'package:feather_icons/feather_icons.dart';

class PromocodeSectionWidget extends StatefulWidget {
  const PromocodeSectionWidget({super.key, required this.cartItems});
  final List<dynamic> cartItems;

  @override
  State<PromocodeSectionWidget> createState() =>
      _PromocodeSectionWidgetState();
}

class _PromocodeSectionWidgetState extends State<PromocodeSectionWidget> {
  double voucherDiscountMoney = 0;
  bool _isVoucherApplied = false;

  // 🧩 Loyalty Points
  int _loyaltyPoints = 0;
  final int _maxLoyaltyPoints = 2000;

  double get subtotal {
    double total = 10000000;
    total -= voucherDiscountMoney;
    total -= _loyaltyPoints * 1000; // ✅ Mỗi điểm giảm 1.000đ
    if (total < 0) total = 0;
    return total;
  }

  void _showVoucherAppliedNotification(double discount) {
    if (discount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(FeatherIcons.checkCircle, color: AppColors.white),
              const SizedBox(width: 8),
              Text(
                'Voucher applied: ${formatMoney(discount)}',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _handleVoucherSelect() async {
    final result = 100000.0; // mock discount value

    if (result != null) {
      double newDiscount = result;
      setState(() {
        voucherDiscountMoney = newDiscount;
        _isVoucherApplied = newDiscount > 0;
      });
      _showVoucherAppliedNotification(newDiscount);
    }
  }

  void _applyLoyaltyPoints(int points) {
    if (points <= _maxLoyaltyPoints && points >= 0) {
      setState(() {
        _loyaltyPoints = points;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🎁 Đã áp dụng $points điểm (giảm ${formatMoney(points * 1000)})',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: AppColors.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Voucher Section
            InkWell(
              onTap: _handleVoucherSelect,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          FeatherIcons.tag,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Voucher / Coupon',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                                scale: animation, child: child);
                          },
                          child: voucherDiscountMoney > 0
                              ? Container(
                            key: ValueKey<double>(voucherDiscountMoney),
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: AppColors.primary, width: 1),
                            ),
                            child: Text(
                              '- ${formatMoney(voucherDiscountMoney)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                              : Container(
                            key: const ValueKey<String>('NoVoucher'),
                            child: Text(
                              'Select Voucher',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.grey.shade400,
                          size: 14,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Divider(
              color: Colors.grey,
              height: 20,
              thickness: 0.5,
              indent: 16,
              endIndent: 16,
            ),

            // 🔹 Loyalty Points Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        FeatherIcons.gift,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Loyalty Points',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Bạn có $_maxLoyaltyPoints điểm. Mỗi điểm trị giá 1.000đ.',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Nhập số điểm muốn dùng',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (value) {
                            final entered = int.tryParse(value) ?? 0;
                            if (entered <= _maxLoyaltyPoints && entered >= 0) {
                              _applyLoyaltyPoints(entered);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '-${formatMoney(_loyaltyPoints * 1000)}',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(
              color: Colors.black12,
              height: 20,
              thickness: 0.5,
              indent: 16,
              endIndent: 16,
            ),

            // 🔹 Total Pay
            Padding(
              padding:
              const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatMoney(subtotal),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}