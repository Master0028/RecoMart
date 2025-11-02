import 'package:flutter/material.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/helpers/formatMoney.dart';

class VersionProduct extends StatelessWidget {
  const VersionProduct({
    super.key,
    required this.relatedProductsVariant,
    required this.handleSelectVariant, 
    required this.isSelected,
  });
  
  final List<dynamic> relatedProductsVariant;
  final Function handleSelectVariant;
  final String isSelected;
  
  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 20,
      spacing: 15,
      children: List.generate(
        relatedProductsVariant.length,
        (index) => InkWell(
          onTap: () => {
            handleSelectVariant(relatedProductsVariant[index]['id']), 
          },
          child: Container(
            width: 140,
            height: 70,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.orangePastel, 
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected == relatedProductsVariant[index]['id']
                    ? AppColors.orange
                    : AppColors.white,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  relatedProductsVariant[index]['variantName'] ?? 'Variant Name',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
                Text(
                  formatMoney(
                    relatedProductsVariant[index]['price'] ?? 0.0,
                  ),
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}