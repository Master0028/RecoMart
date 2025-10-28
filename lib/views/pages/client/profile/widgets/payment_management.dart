import 'package:recomart/config/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';

class ModernPaymentListTile extends StatelessWidget {
  const ModernPaymentListTile({
    super.key,
    required this.icon,
    required this.title,
    this.isFirst = false,
    this.isLast = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(16) : Radius.zero,
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Title
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                // Icon mũi tên (chevron)
                Icon(
                  CupertinoIcons.chevron_forward,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
            if (!isLast)
              Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 56.0),
                child: Divider(
                  color: Colors.grey.shade200,
                  thickness: 1,
                  height: 0,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PaymentManagement extends StatefulWidget {
  const PaymentManagement({super.key});

  @override
  State<PaymentManagement> createState() => _PaymentManagementState();
}

class _PaymentManagementState extends State<PaymentManagement> {
  List<Map<String, dynamic>> paymentMethodItems = [
    {'title': 'Cash on Delivery (COD)', 'icon': FeatherIcons.dollarSign},
    {'title': 'Credit/Debit Card', 'icon': FeatherIcons.creditCard},
    {'title': 'E-Wallet (MoMo, ZaloPay,...)', 'icon': CupertinoIcons.money_dollar_circle},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: List.generate(paymentMethodItems.length, (index) {
            final item = paymentMethodItems[index];
            return ModernPaymentListTile(
              icon: item['icon'],
              title: item['title'],
              isFirst: index == 0,
              isLast: index == paymentMethodItems.length - 1,
              onTap: () {
                print('Tapped on ${item['title']}');
              },
            );
          }),
        ),
      ),
    );
  }
}