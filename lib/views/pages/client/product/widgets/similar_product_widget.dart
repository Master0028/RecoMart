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
    // Gọi API AI
    var data = await _service.getSimilarProducts(widget.productId);
    if (mounted) {
      setState(() {
        _similarItems = data;
        _isLoading = false;
      });
    }
  }

  String formatCurrency(num price) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return format.format(price);
  }

 @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
    
    if (_similarItems.isEmpty) return const SizedBox.shrink(); 

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.purple, size: 20),
              SizedBox(width: 8),
              Text(
                "Có thể bạn cũng thích (AI)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple),
              ),
            ],
          ),
        ),
        
        SizedBox(
          height: 260, 
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _similarItems.length,
            itemBuilder: (context, index) {
              final item = _similarItems[index];

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('products').doc(item.id.toString()).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) return const SizedBox();

                  var data = snapshot.data!.data() as Map<String, dynamic>;
                  
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsView(productId: item.id.toString(), categoryId: 'Unknown')));
                    },
                    child: Container(
                      width: 150, // Tăng chiều rộng chút cho thoải mái
                      margin: const EdgeInsets.only(right: 12, bottom: 5), // Thêm margin bottom cho shadow
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple.withOpacity(0.2)),
                        boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ảnh (Dùng Expanded để chiếm phần lớn diện tích)
                          Expanded(
                            flex: 3, // Chiếm 3 phần
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: Image.network(
                                data['imageUrl'] ?? '',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (_,__,___) => const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                              ),
                            ),
                          ),
                          
                          // Thông tin (Chiếm ít hơn)
                          Expanded(
                            flex: 2, // Chiếm 2 phần
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Căn đều
                                children: [
                                  Text(
                                    data['name'] ?? 'Unknown',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis, // Cắt chữ nếu dài quá
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    formatCurrency(data['price'] ?? 0),
                                    style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
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
      ],
    );
  }
}