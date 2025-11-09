import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:provider/provider.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/utils/widget/CustomAppBarMobile.dart';

import '../../../../../provider/user_provider.dart';

class LoyaltyPointsPage extends StatefulWidget {
  const LoyaltyPointsPage({super.key});

  @override
  State<LoyaltyPointsPage> createState() => _LoyaltyPointsPageState();
}

class _LoyaltyPointsPageState extends State<LoyaltyPointsPage> {

  @override
  void initState() {
    super.initState();

    // ✅ Gọi load loyalty points khi mở trang
    Future.microtask(() {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.fetchLoyaltyPoints();
    });
  }
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final double totalPoints = userProvider.loyaltyPoints;
    final double totalValue = totalPoints * 1000;

    List<Map<String, dynamic>> transactions = [
      {
        'title': 'Mua hàng #RM-3021',
        'type': 'earned',
        'amount': 120,
        'orderTotal': 1200000,
        'date': DateTime(2025, 11, 1),
      },
      {
        'title': 'Đã sử dụng điểm cho đơn hàng #RM-3025',
        'type': 'redeemed',
        'amount': -80,
        'orderTotal': 800000,
        'date': DateTime(2025, 11, 3),
      },
      {
        'title': 'Mua hàng #RM-3028',
        'type': 'earned',
        'amount': 100,
        'orderTotal': 1000000,
        'date': DateTime(2025, 11, 6),
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const CustomAppBarMobile(
        title: 'Loyalty Points',
        isBack: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🧩 Tổng điểm hiện tại
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(FeatherIcons.award, size: 48, color: Colors.white),
                      const SizedBox(height: 12),
                      const Text(
                        'Điểm khách hàng thân thiết',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${totalPoints.toStringAsFixed(0)} điểm',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Tương đương ${(totalValue).toStringAsFixed(0)} ₫',
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // 🧩 Quy tắc tích điểm
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(FeatherIcons.info, color: AppColors.primary, size: 24),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Bạn sẽ nhận được 10% giá trị đơn hàng dưới dạng điểm.\n'
                                'Ví dụ: đơn hàng 1.000.000₫ = 100 điểm (tương đương 100.000₫).\n'
                                'Điểm có thể sử dụng ngay trong đơn hàng kế tiếp, không giới hạn thời gian.',
                            style: TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // 🧩 Lịch sử giao dịch điểm
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Lịch sử điểm thưởng',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                ListView.builder(
                  itemCount: transactions.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    final bool isEarned = tx['type'] == 'earned';
                    final Color color =
                    isEarned ? Colors.green : Colors.redAccent;

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isEarned
                                ? FeatherIcons.arrowUpCircle
                                : FeatherIcons.arrowDownCircle,
                            color: color,
                          ),
                        ),
                        title: Text(
                          tx['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          'Ngày: ${tx['date'].day}/${tx['date'].month}/${tx['date'].year}\n'
                              'Giá trị đơn hàng: ${tx['orderTotal'].toStringAsFixed(0)} ₫',
                          style: const TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                        trailing: Text(
                          (isEarned ? '+' : '') + '${tx['amount']} điểm',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
