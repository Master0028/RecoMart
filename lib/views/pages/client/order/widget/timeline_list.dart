import 'package:flutter/material.dart';
import 'package:recomart/config/color.dart'; 

class TimelineList extends StatelessWidget {
  final List<dynamic> orders; 
  final String state;
  
  const TimelineList({super.key, required this.orders, required this.state});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> filteredOrders = []; 

    if (filteredOrders.isEmpty) {
      return const Center(
        child: Text(
          "No orders available",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filteredOrders.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Icon(
                  state == "Track Order"
                      ? Icons.local_shipping
                      : (state == "Review"
                          ? Icons.rate_review
                          : Icons.shopping_cart),
                  color: state == "Track Order"
                      ? AppColors.blue
                      : (state == "Review"
                          ? AppColors.green
                          : AppColors.red),
                  size: 24,
                ),
                if (index != filteredOrders.length - 1)
                  Container(
                    width: 2,
                    height: 50,
                    color: Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  "Placeholder for OrderItem - State: $state, Index: $index",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}