import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:recomart/components/custom/skeleton.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/models/category.model.dart';
import 'package:recomart/provider/product_provider.dart';
import 'package:recomart/services/app_exceptions.dart';
import 'package:recomart/utils/responsive.dart';
import 'package:recomart/views/pages/client/product/product_page_view.dart';

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

class AppColors {
  static const Color primary = Color(0xFF1976D2);
  static const Color orangePastel = Color(0xFFFFCC80);
  static const Color lightGray = Color(0xFFF0F0F0);
  static const Color darkText = Color(0xFF212121);
}

// Bắt đầu CategoryWidget
class CategoryWidget extends StatefulWidget {
  const CategoryWidget({super.key});

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  bool isSeeAll = false;
  bool isLoading = true;
  List<CategoryModel> categories = [];

  final List<CategoryModel> defaultCategories = [
    CategoryModel(id: '1', name: 'PC', image: CategoryImage(publicId: '', url: 'assets/images/pc.png'), isActive: true),
    CategoryModel(id: '2', name: 'Monitor', image: CategoryImage(publicId: '', url: 'assets/images/monitor.png'), isActive: true),
    CategoryModel(id: '3', name: 'Laptop', image: CategoryImage(publicId: '', url: 'assets/images/laptop.png'), isActive: true),
    CategoryModel(id: '4', name: 'Best Seller', image: CategoryImage(publicId: '', url: 'assets/images/best_seller.png'), isActive: true),
    CategoryModel(id: '5', name: 'Keyboard', image: CategoryImage(publicId: '', url: 'assets/images/keyboard.png'), isActive: true),
    CategoryModel(id: '6', name: 'Mouse', image: CategoryImage(publicId: '', url: 'assets/images/mouse.png'), isActive: true),
    CategoryModel(id: '7', name: 'Desktop', image: CategoryImage(publicId: '', url: 'assets/images/desktop.png'), isActive: true),
    CategoryModel(id: '8', name: 'Headphone', image: CategoryImage(publicId: '', url: 'assets/images/headphone.png'), isActive: true),
  ];

  final Map<String, String> categoriesIcon = {
    'PC': 'assets/icons/Category00003.svg',
    'Monitor': 'assets/icons/Category00004.svg',
    'Laptop': 'assets/icons/Category00002.svg',
    'Best Seller': 'assets/icons/laptop.svg',
    'Keyboard': 'assets/icons/Category00006.svg',
    'Mouse': 'assets/icons/Category00007.svg',
    'Desktop': 'assets/icons/Category00003.svg',
    'Headphone': 'assets/icons/Category00005.svg',
  };

  final List<ProductPromotion> productsPromotion = [
    ProductPromotion(name: 'Macbook Pro', description: 'Laptop mới nhất với hiệu năng vượt trội.', price: 10000000, discount: 15, imageUrl: 'assets/images/laptop-popular-1.jpg', category: 'Laptop'),
    ProductPromotion(name: 'Dell Inspiron 5000', description: 'Máy tính bàn hiệu suất cao dành cho công việc.', price: 12000000, discount: 10, imageUrl: 'assets/images/laptop-popular-2.jpg', category: 'Desktop'),
    ProductPromotion(name: 'Logitech Mouse', description: 'Chuột Logitech dành cho laptop và máy tính bàn.', price: 500000, discount: 5, imageUrl: 'assets/images/laptop-popular-3.jpg', category: 'Accessories'),
    ProductPromotion(name: 'Dell 24" Monitor', description: 'Màn hình Dell với độ phân giải 4K.', price: 8000000, discount: 20, imageUrl: 'assets/images/laptop-popular-4.jpg', category: 'Accessories'),
    ProductPromotion(name: 'Laptop Vip Dominator', description: 'Laptop bán chạy nhất với năng suất ổn định', price: 8000000, discount: 20, imageUrl: 'assets/images/laptop-popular-5.jpg', category: 'Accessories'),
  ];

  Future<void> fetchCategories() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    try {
      await productProvider.fetchCategories();
      setState(() {
        categories = productProvider.categories.isNotEmpty
            ? productProvider.categories
            : defaultCategories;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        categories = defaultCategories;
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => fetchCategories());
  }

  @override
  Widget build(BuildContext context) {
    final maxVisible = Responsive.isDesktop(context)
        ? categories.length
        : (Responsive.isTablet(context) ? 6 : 4);
    final itemCount = isSeeAll
        ? categories.length
        : (categories.length > maxVisible ? maxVisible : categories.length);

    int crossAxisCount = Responsive.isDesktop(context)
        ? 8 
        : Responsive.isTablet(context)
            ? 6 
            : 4; 

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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Top Categories',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
                    ),
                  ),
                  if (!Responsive.isDesktop(context))
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: TextButton(
                        onPressed: () => setState(() => isSeeAll = !isSeeAll),
                        style: TextButton.styleFrom(
                          backgroundColor: isSeeAll
                              ? AppColors.primary.withOpacity(0.15)
                              : Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          isSeeAll ? 'See less' : 'See all',
                          style: TextStyle(
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

              isLoading
                  ? GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount, 
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.6,
                      ),
                      itemCount: 8,
                      itemBuilder: (context, index) => const SkeletonCategoryItem(),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.6,
                      ),
                      itemCount: itemCount,
                      itemBuilder: (context, index) => ListCategoryWidget(
                        icon: categoriesIcon[categories[index].name] ?? 'assets/icons/Category00008.svg',
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
            Text(
              'Popular Products',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 270,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
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

// ListCategoryWidget Đã Sửa Lỗi Overflow 1.6 Pixels
class ListCategoryWidget extends StatefulWidget {
  final String icon;
  final String text;

  const ListCategoryWidget({super.key, required this.icon, required this.text});

  @override
  State<ListCategoryWidget> createState() => _ListCategoryWidgetState();
}

class _ListCategoryWidgetState extends State<ListCategoryWidget> {
  bool _isHovering = false;

  Future<void> _fetchProducts() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    productProvider.clearFilters();
    try {
      await productProvider.fetchProducts(page: 1, limit: 12);
    } on BadRequestException catch (e) {
      debugPrint('Error: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: () {
          context.push(
            '/product-page-view/${widget.text}',
          ).then((_) => _fetchProducts());
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
                  color: _isHovering ? AppColors.orangePastel.withOpacity(0.8) : AppColors.lightGray,
                  shape: BoxShape.circle,
                  boxShadow: _isHovering
                      ? [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))]
                      : [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: SvgPicture.asset(
                  widget.icon,
                  colorFilter: ColorFilter.mode(
                    _isHovering ? AppColors.primary : AppColors.darkText.withOpacity(0.7),
                    BlendMode.srcIn,
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
                    color: _isHovering ? AppColors.primary : AppColors.darkText.withOpacity(0.8),
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
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.1), BlendMode.darken),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 10)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
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
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${productsPromotion.discount}% OFF',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${productsPromotion.price.toStringAsFixed(0)} VND',
                              style: const TextStyle(fontSize: 12, color: Colors.black87, decoration: TextDecoration.lineThrough),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.add, color: Colors.white, size: 20),
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