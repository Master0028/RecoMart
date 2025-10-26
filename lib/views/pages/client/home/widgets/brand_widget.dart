import 'package:flutter/material.dart';
import 'dart:ui';

class AppColors {
  static const Color primary = Color(0xFF1E88E5);
  static const Color orangePastel = Color(0xFFFFC071);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color darkText = Color(0xFF212121);
}

class BrandWidget extends StatefulWidget {
  const BrandWidget({super.key});

  @override
  State<BrandWidget> createState() => _BrandWidgetState();
}

class _BrandWidgetState extends State<BrandWidget> {
  final List<String> brands = [
    'All',
    'New',
    'Low to High',
    'High to Low',
    'Rate',
  ];

  int isSelectedList = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Section
        Text(
          'Product Filters',
          style: TextStyle(
              fontSize: 22,
              color: AppColors.darkText,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5),
        ),
        const SizedBox(height: 16),

        SizedBox(
          height: 40,
          child: ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            scrollDirection: Axis.horizontal,
            itemCount: brands.length,
            itemBuilder: (context, index) {
              final isSelected = isSelectedList == index;

              return InkWell(
                onTap: () {
                  // --- LOGIC CŨ ĐƯỢC GIỮ NGUYÊN ---
                  setState(
                    () {
                      isSelectedList = index;
                    },
                  );
                  // --- END LOGIC CŨ ---
                },
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer( 
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.orangePastel : AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(20),
                    // Tạo hiệu ứng viền/bóng mờ cho cảm giác hiện đại hơn (Tech Look)
                    border: Border.all(
                      color: isSelected ? AppColors.primary.withOpacity(0.5) : Colors.transparent,
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                  ),
                  child: Center(
                    child: Text(
                      brands[index],
                      style: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.darkText.withOpacity(0.7),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}