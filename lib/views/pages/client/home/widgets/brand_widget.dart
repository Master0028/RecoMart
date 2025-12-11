import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1E88E5);
  static const Color orangePastel = Color(0xFFFFC071);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color darkText = Color(0xFF212121);
}

class ProductFilterWidget extends StatefulWidget {
  final ValueChanged<String> onFilterSelected;

  const ProductFilterWidget({
    super.key,
    required this.onFilterSelected,
  });

  @override
  State<ProductFilterWidget> createState() => _ProductFilterWidgetState();
}

class _ProductFilterWidgetState extends State<ProductFilterWidget> {
  final List<String> filterOptions = [
    'All',
    'New',
    'Low to High',
    'High to Low',
    'Rate',
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Filters',
          style: TextStyle(
            fontSize: 22,
            color: AppColors.darkText,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 40,
          child: ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            scrollDirection: Axis.horizontal,
            itemCount: filterOptions.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedIndex == index;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                  widget.onFilterSelected(filterOptions[index]);
                },
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.orangePastel
                        : AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.5)
                          : Colors.transparent,
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
                      filterOptions[index],
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.darkText.withOpacity(0.7),
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