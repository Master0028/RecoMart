import 'package:flutter/material.dart';
import 'package:recomart/helpers/formatMoney.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/config/font.dart';

class ItemReviewedWidget extends StatelessWidget {
  const ItemReviewedWidget({
    super.key,
    required this.product,
  });

  final dynamic product; 

  @override
  Widget build(BuildContext context) {
        final imageUrl = product['images']?[0]?['url'] ?? 'assets/images/image_default_error.png';
    final name = product['variantName'] ?? 'Product Name';
    final description = product['variantDescription'] ?? 'Product description';
    final priceValue = product['price'] ?? 0.0;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
            image: DecorationImage(
              image: imageUrl.startsWith('assets') 
                ? Image.asset(imageUrl).image
                : Image.asset('assets/images/image_default_error.png').image, 
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 20),
        
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: FontSizes.large,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                description,
                style:
                    const TextStyle(fontSize: FontSizes.large, color: AppColors.black),
                overflow: TextOverflow.ellipsis,
              maxLines: 3,
              ),
              Text(
                formatMoney(priceValue),
                style: const TextStyle(
                  fontSize: FontSizes.large,
                  color: AppColors.black,
                ),
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        )
      ],
    );
  }
}