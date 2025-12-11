import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../../models/category.model.dart';
import '../../../../../services/category.service.dart';

class AppColors {
  static const Color primary = Color(0xFF1976D2);
  static const Color orangePastel = Color(0xFFFFCC80);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color darkText = Color(0xFF212121);
  static const Color lightGray = Color(0xFFF0F0F0);
}

class CategoryImage {
  final String publicId;
  final String url;
  const CategoryImage({required this.publicId, required this.url});
}

class ProductPromotion {
  final String name;
  final String description;
  final double price;
  final int discount;
  final String imageUrl;
  final String category;

  ProductPromotion({
    required this.name,
    required this.description,
    required this.price,
    required this.discount,
    required this.imageUrl,
    required this.category,
  });
}

class Responsive {
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1000;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1000;
  }
}

class SkeletonCategoryItem extends StatelessWidget {
  const SkeletonCategoryItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 50,
          height: 12,
          color: Colors.grey[300],
        ),
      ],
    );
  }
}

class ListCategoryWidget extends StatefulWidget {
  final String icon;
  final String text;

  const ListCategoryWidget({super.key, required this.icon, required this.text});

  @override
  State<ListCategoryWidget> createState() => _ListCategoryWidgetState();
}

class _ListCategoryWidgetState extends State<ListCategoryWidget> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: () {
          context.push(
            '/product-page-view/${widget.text}',
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 60,
                height: 60,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isHovering
                      ? AppColors.orangePastel.withOpacity(0.8)
                      : AppColors.lightGray,
                  shape: BoxShape.circle,
                  boxShadow: _isHovering
                      ? [
                          BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 8))
                        ]
                      : [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 4))
                        ],
                ),
                child: ClipOval(
                  child: widget.icon.endsWith('.svg')
                      ? SvgPicture.network(
                          widget.icon,
                          fit: BoxFit.cover,
                          placeholderBuilder: (_) => const Center(
                              child:
                                  CircularProgressIndicator(strokeWidth: 2)),
                          width: 60,
                          height: 60,
                        )
                      : Image.network(
                          widget.icon,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image, color: Colors.grey),
                          width: 60,
                          height: 60,
                        ),
                ),
              ),
              const SizedBox(height: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 75,
                ),
                child: Text(
                  widget.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: _isHovering
                        ? AppColors.primary
                        : AppColors.darkText.withOpacity(0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductCardWidget extends StatelessWidget {
  final ProductPromotion productsPromotion;

  const ProductCardWidget({super.key, required this.productsPromotion});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              height: 270,
              width: 280,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(productsPromotion.imageUrl),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.1), BlendMode.darken),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 10)),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 15,
            right: 15,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.4), width: 1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              productsPromotion.name,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkText),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${productsPromotion.discount}% OFF',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${productsPromotion.price.toStringAsFixed(0)} VND',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                  decoration: TextDecoration.lineThrough),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                            color: AppColors.primary, shape: BoxShape.circle),
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.add,
                              color: Colors.white, size: 20),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryWidget extends StatefulWidget {
  const CategoryWidget({super.key});

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  bool isSeeAll = false;
  bool isLoading = true; // Start as true to show loading
  List<CategoryModel> categories = [];

  final CategoryService _categoryService = CategoryService();

  final List<ProductPromotion> productsPromotion = [
    ProductPromotion(
        name: 'Macbook Pro',
        description: 'Latest laptop with superior performance.',
        price: 10000000,
        discount: 15,
        imageUrl: 'assets/images/laptop-popular-1.jpg',
        category: 'Laptop'),
    ProductPromotion(
        name: 'Dell Inspiron 5000',
        description: 'High-performance desktop suitable for work.',
        price: 12000000,
        discount: 10,
        imageUrl: 'assets/images/laptop-popular-2.jpg',
        category: 'Desktop'),
    ProductPromotion(
        name: 'Logitech Mouse',
        description: 'Logitech mouse for laptops and desktops.',
        price: 500000,
        discount: 5,
        imageUrl: 'assets/images/laptop-popular-3.jpg',
        category: 'Accessories'),
    ProductPromotion(
        name: 'Dell 24" Monitor',
        description: 'Dell monitor with 4K resolution.',
        price: 8000000,
        discount: 20,
        imageUrl: 'assets/images/laptop-popular-4.jpg',
        category: 'Accessories'),
    ProductPromotion(
        name: 'Laptop Vip Dominator',
        description: 'Best-selling laptop with stable productivity.',
        price: 8000000,
        discount: 20,
        imageUrl: 'assets/images/laptop-popular-5.jpg',
        category: 'Accessories'),
  ];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final data = await _categoryService.getCategories();
      if (mounted) {
        setState(() {
          categories = data;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Determine column count
    int crossAxisCount = Responsive.isDesktop(context)
        ? 8
        : Responsive.isTablet(context)
            ? 6
            : 4;

    // 2. Determine default visible count (1 row)
    final int defaultVisibleCount = crossAxisCount * 1;

    // 3. Calculate actual item count to render
    final int itemCount = isSeeAll
        ? categories.length
        : (categories.length > defaultVisibleCount
            ? defaultVisibleCount
            : categories.length);

    // Check if See All button is needed
    final bool showSeeAllButton = categories.length > defaultVisibleCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header + See All Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'All Categories',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
                    ),
                  ),
                  if (showSeeAllButton)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: TextButton(
                        onPressed: () => setState(() => isSeeAll = !isSeeAll),
                        style: TextButton.styleFrom(
                          backgroundColor: isSeeAll
                              ? AppColors.primary.withOpacity(0.15)
                              : Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          isSeeAll ? 'See less' : 'See all',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: itemCount,
                  itemBuilder: (context, index) => ListCategoryWidget(
                    icon: categories[index].imageUrl,
                    text: categories[index].name,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Popular Products',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 270,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemBuilder: (context, index) => ProductCardWidget(
                  productsPromotion: productsPromotion[index],
                ),
                separatorBuilder: (context, index) => const SizedBox(width: 30),
                itemCount: productsPromotion.length,
              ),
            ),
          ],
        ),
      ],
    );
  }
}