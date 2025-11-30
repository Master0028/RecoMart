import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:recomart/components/custom/pagination.dart';
import 'package:recomart/components/custom/range_slider.dart';
import 'package:recomart/components/custom/skeleton.dart';
import 'package:recomart/components/custom/snackbar.dart';
// Import model và service của bạn (đảm bảo đường dẫn đúng)
import '../../../../../models/category.model.dart';
import '../../../../../provider/product_provider.dart';
import '../../../../../services/category.service.dart';

// ================= ĐỊNH NGHĨA ENUM & CONSTANT =================
enum RatingFilterValue { all, fiveStar, fourStar, threeStar, twoStar, oneStar }

class AppColors {
  static const Color primary = Color(0xFF1976D2);
  static const Color orangePastel = Color(0xFFFFCC80);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color darkText = Color(0xFF212121);
  static const Color lightGray = Color(0xFFF0F0F0);
}

// ================= MODELS GIẢ LẬP =================
class CategoryModelFE { final String id; final String name; CategoryModelFE({required this.id, required this.name}); }
class BrandModelFE { final String id; final String name; BrandModelFE({required this.id, required this.name}); }

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

// ================= UTILS =================
class Responsive {
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1000;
  }
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1000;
  }
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }
}

// ================= WIDGETS PHỤ TRỢ =================

class MyButton extends StatelessWidget {
  final String text;
  final Function(dynamic) onTap;
  final bool variantIsOutline;

  const MyButton({
    super.key, 
    required this.text, 
    required this.onTap, 
    this.variantIsOutline = false
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onTap(null),
      style: ElevatedButton.styleFrom(
        backgroundColor: variantIsOutline ? Colors.white : AppColors.primary,
        foregroundColor: variantIsOutline ? AppColors.primary : Colors.white,
        side: variantIsOutline ? const BorderSide(color: AppColors.primary) : null,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(text),
    );
  }
}

class SkeletonCategoryItem extends StatelessWidget {
  const SkeletonCategoryItem({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle)),
        const SizedBox(height: 8),
        Container(width: 50, height: 12, color: Colors.grey[300]),
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
        onTap: () => context.push('/product-page-view/${widget.text}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 60, height: 60, padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isHovering ? AppColors.orangePastel.withOpacity(0.8) : AppColors.lightGray,
                  shape: BoxShape.circle,
                  boxShadow: _isHovering
                      ? [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))]
                      : [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: ClipOval(
                  child: widget.icon.endsWith('.svg')
                      ? SvgPicture.network(widget.icon, fit: BoxFit.cover, width: 60, height: 60)
                      : Image.network(widget.icon, fit: BoxFit.cover, width: 60, height: 60, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey)),
                ),
              ),
              const SizedBox(height: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 75),
                child: Text(
                  widget.text, textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: _isHovering ? AppColors.primary : AppColors.darkText.withOpacity(0.8)),
                  maxLines: 2, overflow: TextOverflow.ellipsis,
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
              height: 270, width: 280,
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage(productsPromotion.imageUrl), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.1), BlendMode.darken)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 10))],
              ),
            ),
          ),
          Positioned(
            bottom: 20, left: 15, right: 15,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  height: 90,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), border: Border.all(color: Colors.white.withOpacity(0.4), width: 1), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(productsPromotion.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText), overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text('${productsPromotion.discount}% OFF', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                            const SizedBox(height: 2),
                            Text('${productsPromotion.price.toStringAsFixed(0)} VND', style: const TextStyle(fontSize: 12, color: Colors.black87, decoration: TextDecoration.lineThrough)),
                          ],
                        ),
                      ),
                      Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: IconButton(onPressed: () {}, icon: const Icon(Icons.add, color: Colors.white, size: 20), padding: EdgeInsets.zero)),
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

class RatingFilter extends StatelessWidget {
  final RatingFilterValue selectedRatingValue;
  final Function(RatingFilterValue) onChanged;

  const RatingFilter({super.key, required this.selectedRatingValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Rating', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (_, __) => const SizedBox(height: 5),
            itemBuilder: (context, index) {
              final ratingValue = RatingFilterValue.values[index + 1];
              final starCount = 5 - index;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: List.generate(5, (i) => Icon(i < starCount ? Icons.star : Icons.star_border, color: Colors.amber, size: 20))),
                  Radio<RatingFilterValue>(value: ratingValue, groupValue: selectedRatingValue, onChanged: (val) => onChanged(val!), activeColor: AppColors.primary),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class DropdownCustom extends StatefulWidget {
  final List<String> items;
  final String? value;
  final ValueChanged<String> onChanged;
  const DropdownCustom({super.key, required this.items, required this.onChanged, this.value});
  @override
  State<DropdownCustom> createState() => _DropdownCustomState();
}

class _DropdownCustomState extends State<DropdownCustom> {
  String? _selectedValue;
  @override
  void initState() { super.initState(); _selectedValue = widget.value; }
  @override
  void didUpdateWidget(DropdownCustom oldWidget) {
     super.didUpdateWidget(oldWidget);
     if (widget.value != oldWidget.value) setState(() => _selectedValue = widget.value);
  }
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _selectedValue, underline: const SizedBox(),
      items: widget.items.map((e) => DropdownMenuItem<String>(value: e, child: Text(e))).toList(),
      onChanged: (val) { if (val != null) { setState(() => _selectedValue = val); widget.onChanged(val); } },
    );
  }
}

// ================= WIDGETS CHÍNH =================

// 1. CATEGORY WIDGET
class CategoryWidget extends StatefulWidget {
  const CategoryWidget({super.key});
  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  bool isSeeAll = false;
  bool isLoading = true;
  List<CategoryModel> categories = [];
  final CategoryService _categoryService = CategoryService();

  final List<ProductPromotion> productsPromotion = [
    ProductPromotion(name: 'Macbook Pro', description: 'Laptop mới', price: 10000000, discount: 15, imageUrl: 'assets/images/laptop-popular-1.jpg', category: 'Laptop'),
    ProductPromotion(name: 'Dell Inspiron 5000', description: 'Máy tính bàn', price: 12000000, discount: 10, imageUrl: 'assets/images/laptop-popular-2.jpg', category: 'Desktop'),
    ProductPromotion(name: 'Logitech Mouse', description: 'Chuột', price: 500000, discount: 5, imageUrl: 'assets/images/laptop-popular-3.jpg', category: 'Accessories'),
    ProductPromotion(name: 'Dell 24" Monitor', description: 'Màn hình', price: 8000000, discount: 20, imageUrl: 'assets/images/laptop-popular-4.jpg', category: 'Accessories'),
    ProductPromotion(name: 'Laptop Vip', description: 'Laptop', price: 8000000, discount: 20, imageUrl: 'assets/images/laptop-popular-5.jpg', category: 'Accessories'),
  ];

  @override
  void initState() { super.initState(); _fetchCategories(); }

  Future<void> _fetchCategories() async {
    try {
      final data = await _categoryService.getCategories();
      if (mounted) setState(() { categories = data; isLoading = false; });
    } catch (e) {
      print('Lỗi tải categories: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = Responsive.isDesktop(context) ? 8 : (Responsive.isTablet(context) ? 6 : 4);
    final int defaultVisibleCount = crossAxisCount * 1; 
    final int itemCount = isSeeAll ? categories.length : (categories.length > defaultVisibleCount ? defaultVisibleCount : categories.length);
    final bool showSeeAllButton = categories.length > defaultVisibleCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('All Categories', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.darkText)),
                  if (showSeeAllButton)
                    TextButton(
                      onPressed: () => setState(() => isSeeAll = !isSeeAll),
                      style: TextButton.styleFrom(backgroundColor: isSeeAll ? AppColors.primary.withOpacity(0.15) : Colors.transparent, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      child: Text(isSeeAll ? 'See less' : 'See all', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              if (isLoading) const Center(child: CircularProgressIndicator())
              else GridView.builder(
                  shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.9),
                  itemCount: itemCount,
                  itemBuilder: (context, index) => ListCategoryWidget(icon: categories[index].imageUrl, text: categories[index].name),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Popular Products', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.darkText))),
            const SizedBox(height: 20),
            SizedBox(
              height: 270,
              child: ListView.separated(
                scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12),
                itemBuilder: (context, index) => ProductCardWidget(productsPromotion: productsPromotion[index]),
                separatorBuilder: (_, __) => const SizedBox(width: 30),
                itemCount: productsPromotion.length,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// 2. SHOW LIST PRODUCT WIDGET
class ShowListProductWidget extends StatefulWidget {
  const ShowListProductWidget({super.key, this.categoryId});
  final String? categoryId;
  @override
  State<ShowListProductWidget> createState() => _ShowListProductWidgetState();
}

class _ShowListProductWidgetState extends State<ShowListProductWidget> {
  final List<String> sortOptions = ['All Products', 'Name: A to Z', 'Name: Z to A', 'Price: Low to High', 'Price: High to Low'];
  void _handleRemoveFilterFE(String removedFilter) { showCustomSnackBar(context, '$removedFilter removed'); }

  @override
  Widget build(BuildContext context) {
    final List<String> filters = ['Category: PC', 'Price: > 5M'];
    final bool isMobile = Responsive.isMobile(context);
    final provider = Provider.of<ProductProvider>(context);

    return Container(
      padding: !isMobile ? const EdgeInsets.all(16) : null,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: !isMobile ? const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))] : null),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            runSpacing: 10, spacing: 20, alignment: WrapAlignment.start, crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (!isMobile) const Text('Product List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Sort by: ', style: TextStyle(fontSize: 14, color: Colors.black54)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8), height: 40,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black45, width: 0.5)),
                    child: DropdownCustom(items: sortOptions, value: provider.currentSort, onChanged: (value) => provider.sortProducts(value)),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16, runSpacing: 16,
            children: List.generate(filters.length, (index) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: AppColors.primary.withAlpha(25), borderRadius: BorderRadius.circular(16)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(filters[index], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 10),
                  IconButton(onPressed: () => _handleRemoveFilterFE(filters[index]), icon: const Icon(Icons.close, color: AppColors.primary), iconSize: 16, constraints: const BoxConstraints(), padding: EdgeInsets.zero),
                ]),
              );
            }),
          ),
          const SizedBox(height: 20),
          ProductList(categoryId: widget.categoryId),
        ],
      ),
    );
  }
}

// 👇 ĐỊNH NGHĨA LẠI WIDGET HIỂN THỊ CARD SẢN PHẨM 👇
class ProductView extends StatelessWidget {
  final String id;
  final String? categoryId;
  final String name;
  final String image;
  final double price;
  final String averageRating;

  const ProductView({
    super.key,
    required this.id,
    this.categoryId,
    required this.name,
    required this.image,
    required this.price,
    required this.averageRating,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/product-detail/$id'),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(image, fit: BoxFit.cover, width: double.infinity),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('$price VND', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    Text(averageRating, style: const TextStyle(fontSize: 12)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 3. PRODUCT LIST
class ProductList extends StatefulWidget {
  const ProductList({super.key, this.categoryId});
  final String? categoryId;
  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProductsFilter(reset: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    if (provider.loading && provider.products.isEmpty) {
      return GridView.builder(
        itemCount: 10, physics: const NeverScrollableScrollPhysics(), shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: Responsive.isDesktop(context) ? 4 : 2, childAspectRatio: 0.55, crossAxisSpacing: 20, mainAxisSpacing: 20, mainAxisExtent: 350),
        itemBuilder: (context, index) => const Skeleton(),
      );
    }
    if (provider.products.isEmpty) return const Center(child: Text('No products found!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)));

    return Column(
      children: [
        GridView.builder(
          itemCount: provider.products.length, physics: const NeverScrollableScrollPhysics(), shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: Responsive.isDesktop(context) ? 4 : 2, childAspectRatio: 0.55, crossAxisSpacing: 20, mainAxisSpacing: 20, mainAxisExtent: 350),
          itemBuilder: (context, index) {
            final p = provider.products[index];
            return ProductView(id: p.id, categoryId: p.categoryId, name: p.name, image: p.imageUrl, price: p.price, averageRating: p.averageRating.toString());
          },
        ),
        const SizedBox(height: 20),
        PaginationWidget(
          currentPage: provider.currentPage, totalPages: 9,
          onPageChanged: (page) async {
            if (provider.hasMore) await provider.nextPage(); else showCustomSnackBar(context, "No more products!");
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

// 4. FILTER WIDGET
class FilterWidget extends StatefulWidget {
  const FilterWidget({super.key});
  @override
  State<FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  late double minPrice; late double maxPrice;
  late RangeValues _rangeValues;
  late RatingFilterValue _selectedRatingValue;
  List<CategoryModelFE> categories = []; List<BrandModelFE> brands = [];
  Map<String, bool> isExpanded = {'Category': false, 'Brand': false};
  Map<String, Set<String>> selectedItems = {'Category': {}, 'Brand': {}};

  Future<void> fetchData() async {
     final provider = Provider.of<ProductProvider>(context, listen: false);
     await Future.wait([provider.fetchCategories(), provider.fetchBrands()]);
     setState(() {
       categories = provider.categoriesMap.entries.map((entry) => CategoryModelFE(id: entry.key, name: entry.value)).toList();
       brands = provider.brandsMap.entries.map((entry) => BrandModelFE(id: entry.key, name: entry.value)).toList();
     });
  }

  @override
  void initState() {
    super.initState();
    minPrice = 100000; maxPrice = 100000000;
    _rangeValues = RangeValues(minPrice, maxPrice);
    _selectedRatingValue = RatingFilterValue.all;
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Filter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  if (Responsive.isMobile(context)) TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(fontSize: 14, color: Colors.black))),
               ]),
              const SizedBox(height: 16),
              RangeSliderCustom(title: 'Price', divisions: 50, minValue: minPrice, maxValue: maxPrice, rangeValues: _rangeValues, onChanged: (values) => setState(() => _rangeValues = values)),
              const SizedBox(height: 16),
              RatingFilter(selectedRatingValue: _selectedRatingValue, onChanged: (value) => setState(() => _selectedRatingValue = value)),
              const SizedBox(height: 16),
               Row(
                children: [
                  Expanded(child: MyButton(text: 'Reset', variantIsOutline: true, onTap: (_) {
                    Provider.of<ProductProvider>(context, listen: false).resetFilters();
                    setState(() { selectedItems = {'Category': {}, 'Brand': {}}; _rangeValues = RangeValues(minPrice, maxPrice); _selectedRatingValue = RatingFilterValue.all; });
                    if (Responsive.isMobile(context)) Navigator.pop(context);
                  })),
                  const SizedBox(width: 10),
                  Expanded(child: MyButton(text: 'Apply', onTap: (_) { if (Responsive.isMobile(context)) Navigator.pop(context); })),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
class ProductPageBody extends StatelessWidget {
  const ProductPageBody({
    super.key,
    this.categoryId,
  });
  final String? categoryId;

  @override
  Widget build(BuildContext context) {
    bool isMobile = Responsive.isMobile(context);
    
    // Lấy arguments an toàn (tránh lỗi null)
    final args = ModalRoute.of(context)?.settings.arguments;
    final Map<String, dynamic>? arguments = args is Map<String, dynamic> ? args : null;
    final showBackButton = arguments?['showBackButton'] ?? false;
    
    void handleGoBack() {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/home'); // Fallback nếu không pop được
        }
    }

    return SafeArea(
      child: ListView(
        children: [
          // 1. Nút Back (Chỉ hiện trên Mobile nếu được yêu cầu)
          if (isMobile && showBackButton)
            Container(
              padding: const EdgeInsets.only(top: 16, left: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: handleGoBack,
                  ),
                  const Text(
                    'Home',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

          // 2. Nội dung chính
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nút Filter cho Mobile
                      ElevatedButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent, // Để bo góc đẹp hơn
                            builder: (context) => DraggableScrollableSheet(
                              initialChildSize: 0.9,
                              minChildSize: 0.5,
                              maxChildSize: 0.95,
                              builder: (_, controller) => Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                ),
                                child: const FilterWidget(),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.filter_list,
                          color: Colors.black,
                          size: 16,
                        ),
                        label: const Text(
                          'Filter',
                          style: TextStyle(color: Colors.black, fontSize: 14),
                        ),
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                            (states) {
                              if (states.contains(WidgetState.hovered)) {
                                return Colors.grey[100];
                              }
                              return Colors.white;
                            },
                          ),
                          elevation: WidgetStateProperty.all(0),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              side: const BorderSide(
                                color: Colors.black45,
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Danh sách sản phẩm
                      ShowListProductWidget(
                        categoryId: categoryId,
                      ),
                    ],
                  )
                : Column( // Layout cho Desktop/Tablet
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: 200,
                              maxWidth: 300,
                            ),
                            child: FilterWidget(),
                          ),
                          const SizedBox(width: 16),
                          
                          Expanded(
                            child: ShowListProductWidget(
                              categoryId: categoryId,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}