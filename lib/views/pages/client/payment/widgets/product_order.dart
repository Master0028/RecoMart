import 'package:flutter/material.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/helpers/formatMoney.dart';

final Map<String, dynamic> _placeholderItem = {
  'productVariantName': 'Tên sản phẩm (Placeholder)',
  'quantity': 2,
  'unitPrice': 100000.0,
  'discount': 0.1, // 10%
  'images': {
    'url': 'https://via.placeholder.com/150/0000FF/808080?text=Product',
  },
};

class ProductOrdered extends StatelessWidget {
  final dynamic item;

  const ProductOrdered({
    super.key,
    this.item = const {}, 
  });

  String get _productVariantName => item['productVariantName'] ?? _placeholderItem['productVariantName'];
  int get _quantity => item['quantity'] ?? _placeholderItem['quantity'];
  double get _unitPrice => item['unitPrice'] ?? _placeholderItem['unitPrice'];
  double get _discount => item['discount'] ?? _placeholderItem['discount'];
  String get _imageUrl => item['images']?['url'] ?? _placeholderItem['images']['url'];

  @override
  Widget build(BuildContext context) {
    double discountedPrice = _unitPrice - (_unitPrice * _discount);
    double totalPrice = discountedPrice * _quantity;

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(_imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _productVariantName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatMoney(discountedPrice),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 1,
              child: Text(
                'x$_quantity',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            Expanded(
              flex: 1,
              child: Text(
                formatMoney(totalPrice),
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}