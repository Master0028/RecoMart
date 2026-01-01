import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recomart/models/recommendation_model.dart';
import 'package:recomart/services/recommendation_service.dart';
import 'package:go_router/go_router.dart';
import 'package:recomart/helpers/formatMoney.dart';
import 'package:recomart/config/color.dart';

class RecommendationWidget extends StatefulWidget {
  final int userId;

  const RecommendationWidget({super.key, required this.userId});

  @override
  State<RecommendationWidget> createState() => _RecommendationWidgetState();
}

class _RecommendationWidgetState extends State<RecommendationWidget> {
  final RecommendationService _service = RecommendationService();
  List<ProductRecommendation> _recommendations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.userId > 0) {
      _loadData();
    } else {
      _isLoading = false;
    }
  }

  @override
  void didUpdateWidget(covariant RecommendationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId && widget.userId > 0) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      debugPrint("DEBUG: Fetching recommendations for UserID: ${widget.userId}");
      final data = await _service.getRecommendations(widget.userId);
      debugPrint("DEBUG: API returned ${data.length} items");

      if (!mounted) return;

      setState(() {
        _recommendations = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("DEBUG ERROR in _loadData: $e");
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_recommendations.isEmpty) {
      debugPrint("DEBUG: Recommendations list is empty, hiding widget.");
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            "Recommended for you",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _recommendations.length,
            itemBuilder: (context, index) {
              final item = _recommendations[index];
              // FORCE ID TO STRING TO MATCH FIRESTORE
              final String productId = item.id.toString();

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .where('id', isEqualTo: productId)
                    .limit(1)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    debugPrint("DEBUG ERROR for Product $productId: ${snapshot.error}");
                    return const SizedBox.shrink();
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingCard();
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    debugPrint("DEBUG: No Firestore doc found for ID: '$productId' (Type: String)");
                    return _buildLoadingCard(); // This will loop if ID doesn't exist
                  }

                  final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;

                  final String imageUrl = data['imageUrl'] ?? '';
                  final String name = data['name'] ?? item.name;
                  final num priceVal = data['price'] ?? 0;
                  final double price = priceVal.toDouble();

                  return GestureDetector(
                    onTap: () {
                      context.push('/product-detail/$productId');
                    },
                    child: Container(
                      width: 150,
                      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: imageUrl.isNotEmpty
                                  ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder: (_, __, ___) {
                                        return const Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    )
                                  : const Center(
                                      child: Icon(
                                        Icons.image,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  formatMoney(price),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: 150,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}