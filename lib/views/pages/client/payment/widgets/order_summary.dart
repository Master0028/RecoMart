import 'package:flutter/material.dart';

class _ProductOrderedPlaceholder extends StatelessWidget {
  final dynamic item;
  const _ProductOrderedPlaceholder({required this.item});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.shopping_bag_outlined, color: Colors.blueGrey),
          SizedBox(width: 12),
          Text('Product Item (FE Placeholder)', style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

class _SkeletonHorizontalProductPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 2,
      shrinkWrap: true,
      itemBuilder: (context, index) => Container(
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.grey[200],
      ),
    );
  }
}

class OrderSummary extends StatelessWidget {
  final List<dynamic> cartItems;

  const OrderSummary(
      {super.key, required this.cartItems, this.isLoading = false});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    double height = cartItems.isEmpty ? 1 * 120 : cartItems.length * 80;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Summary Order',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const SizedBox(
          width: 300,
          child: Text(
            'Check your order summary before payment for better experience',
            style: TextStyle(fontSize: 12),
          ),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 320,
          ),
          child: Container(
            width: 500,
            height: height.clamp(120, 320),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black54, width: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: isLoading
                ? Center(
                    child: _SkeletonHorizontalProductPlaceholder(), 
                  )
                : ListView.separated(
                    separatorBuilder: (context, index) => const Divider(),
                    shrinkWrap: true,
                    itemCount: cartItems.length, 
                    itemBuilder: (context, index) {
                      return _ProductOrderedPlaceholder(item: cartItems[index]);
                    },
                  ),
          ),
        ),
      ],
    );
  }
}