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
    _loadData();
  }

  // 👇 QUAN TRỌNG: Load lại dữ liệu nếu User ID thay đổi (ví dụ từ Guest -> Login)
  @override
  void didUpdateWidget(covariant RecommendationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _loadData();
    }
  }

  void _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      var data = await _service.getRecommendations(widget.userId);
      if (mounted) {
        setState(() {
          _recommendations = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Lỗi tải gợi ý: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Loading ban đầu khi gọi API Python
    if (_isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_recommendations.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.amber),
              SizedBox(width: 8),
              Text(
                "Gợi ý riêng cho bạn",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
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

              // Lấy chi tiết sản phẩm từ Firebase
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .doc(item.id.toString())
                    .snapshots(),
                builder: (context, snapshot) {
                  // 1. Nếu có lỗi -> Ẩn item này đi, đừng loading mãi
                  if (snapshot.hasError) {
                    // print("Lỗi item ${item.id}: ${snapshot.error}");
                    return const SizedBox.shrink();
                  }
                  
                  // 2. Nếu đang load hoặc document không tồn tại -> Hiện khung xương
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                     return _buildLoadingCard(); 
                  }

                  // 3. Parse dữ liệu an toàn
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final String imageUrl = data['imageUrl'] ?? '';
                  final String name = data['name'] ?? item.name;
                  
                  // Xử lý giá tiền (Firestore có thể trả về int hoặc double)
                  final num priceVal = data['price'] ?? 0; 
                  final double price = priceVal.toDouble();

                  return GestureDetector(
                    onTap: () {
                      context.push('/product-detail/${item.id}');
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
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ảnh sản phẩm
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: imageUrl.isNotEmpty
                                  ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)));
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Center(child: Icon(Icons.image_not_supported, color: Colors.grey, size: 40));
                                      },
                                    )
                                  : const Center(child: Icon(Icons.image, color: Colors.grey, size: 40)),
                            ),
                          ),
                          
                          // Thông tin
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.2),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  formatMoney(price), 
                                  style: const TextStyle(
                                    fontSize: 13, 
                                    fontWeight: FontWeight.bold, 
                                    color: AppColors.primary 
                                  ),
                                ),
                              ],
                            ),
                          )
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
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
    );
  }
}