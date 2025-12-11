import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/models/recommendation_model.dart';
import 'package:recomart/services/recommendation_service.dart';
import 'package:recomart/views/pages/client/product/product_details_view.dart';

class SimilarProductWidget extends StatefulWidget {
  final String productId;

  const SimilarProductWidget({super.key, required this.productId});

  @override
  State<SimilarProductWidget> createState() => _SimilarProductWidgetState();
}

class _SimilarProductWidgetState extends State<SimilarProductWidget> {
  final RecommendationService _service = RecommendationService();
  List<ProductRecommendation> _similarItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant SimilarProductWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productId != widget.productId) {
      _loadData();
    }
  }

  void _loadData() async {
    setState(() => _isLoading = true);
    // Call AI API
    var data = await _service.getSimilarProducts(widget.productId);
    if (mounted) {
      setState(() {
        _similarItems = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_similarItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Header Section ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.purple, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                "Recommended for you",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          height: 280,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _similarItems.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final item = _similarItems[index];

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .doc(item.id.toString())
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const SizedBox.shrink();
                  }

                  var data = snapshot.data!.data() as Map<String, dynamic>;

                  return _ModernProductCard(
                    data: data,
                    id: item.id.toString(),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ModernProductCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String id;

  const _ModernProductCard({
    required this.data,
    required this.id,
  });

  String formatCurrency(num price) {
    final format = NumberFormat.currency(locale: 'en_US', symbol: '', decimalDigits: 0);
    return '${format.format(price)} đ';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsView(
              productId: id,
              categoryId: 'Unknown',
            ),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(bottom: 10), // Margin for shadow
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  children: [
                    Container(
                      color: Colors.grey[50], // Background placeholder
                      width: double.infinity,
                      height: double.infinity,
                      child: Image.network(
                        data['imageUrl'] ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    // Optional: Discount Badge
                    if (data['discount'] != null && data['discount'] > 0)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '-${data['discount']}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Product Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['name'] ?? 'Unknown Product',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Rating star example
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              "${data['rating'] ?? '4.5'}",
                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                            ),
                          ],
                        )
                      ],
                    ),
                    Text(
                      formatCurrency(data['price'] ?? 0),
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}