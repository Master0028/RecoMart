import 'package:go_router/go_router.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/helpers/formatMoney.dart';
import 'package:recomart/models/cart.model.dart';
import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';

class PromocodeSectionWidget extends StatefulWidget {
  const PromocodeSectionWidget({super.key, required this.cartItems});
  final List<ProductForCartModel> cartItems;

  @override
  State<PromocodeSectionWidget> createState() => _PromocodeSectionWidgetState();
}

class _PromocodeSectionWidgetState extends State<PromocodeSectionWidget> {
  String _selectedShippingMethod = 'Express delivery';
  double voucherDiscountMoney = 0;

  final List<String> _shippingMethods = [
    'Pickup at store',
    'Express delivery',
  ];

  bool _isVoucherApplied = false;

  double get subtotal {
    double total = widget.cartItems.fold(
      0,
      (sum, item) =>
          sum +
          (item.unitPrice - item.unitPrice * item.discount) * item.quantity,
    );
    total -= voucherDiscountMoney;
    if (total < 0) total = 0;
    return total;
  }

  void _showVoucherAppliedNotification(double discount) {
    if (discount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(FeatherIcons.checkCircle, color: AppColors.white),
              const SizedBox(width: 8),
              Text(
                'Voucher applied: ${formatMoney(discount)}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            // Promocode/Voucher Section
            InkWell(
              onTap: () async {
                final result = await context.push('/voucher');
                if (result != null) {
                  double newDiscount = result as double;
                  setState(() {
                    voucherDiscountMoney = newDiscount;
                    _isVoucherApplied = newDiscount > 0;
                  });
                  _showVoucherAppliedNotification(newDiscount);
                }
              },
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
                        const SizedBox(width: 10),
                        const Text(
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
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return ScaleTransition(scale: animation, child: child);
                          },
                          child: voucherDiscountMoney > 0
                              ? Container(
                                  key: ValueKey<double>(voucherDiscountMoney),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1), 
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.primary, width: 1),
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                       Icon(
                        FeatherIcons.truck,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Shipping Method',
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.w600, 
                          color: Colors.black87
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        icon: Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                        elevation: 1,
                        dropdownColor: Colors.white,
                        value: _selectedShippingMethod,
                        style: TextStyle(color: Colors.black, fontSize: 14),
                        items: _shippingMethods.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedShippingMethod = newValue;
                            });
                          }
                        },
                      ),
                    ),
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
            
            // Total Pay & Checkout Button
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
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
                          'Total Pay',
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
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          context.push(
                            '/payment', 
                            extra: {
                              'shippingMethod': _selectedShippingMethod,
                              'voucherDiscountMoney': voucherDiscountMoney,
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          elevation: 10, // Shadow mạnh hơn
                          shadowColor: AppColors.primary.withOpacity(0.5),
                        ),
                        child: const Text(
                          'Checkout',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
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