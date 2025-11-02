import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:recomart/components/custom/pagination.dart';
import 'package:recomart/components/custom/skeleton.dart';
// import 'package:recomart/components/custom/snackbar.dart';
// import 'package:recomart/provider/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:recomart/helpers/formatMoney.dart';
import 'package:recomart/models/product.model.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/config/font.dart';
import 'package:recomart/utils/responsive.dart';
import '../../../../../services/product.service.dart';

class ProductListViewWidget extends StatefulWidget {
  const ProductListViewWidget({
    super.key,
  });

  @override
  State<ProductListViewWidget> createState() => _ProductListViewWidgetState();
}

class _ProductListViewWidgetState extends State<ProductListViewWidget> {
  bool _isLoading = true;
  String errorMessage = '';
  List<ProductModel> mockProducts = [];
  final ProductService _productService = ProductService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _simulateFetchProducts();
    });
  }

  Future<void> _simulateFetchProducts() async {
    setState(() {
      _isLoading = true;
      errorMessage = '';
    });

    try {
      // Lấy dữ liệu từ Firestore
      final products = await _productService.getProducts();

      setState(() {
        mockProducts = products;
        _isLoading = false;
      });

      print("Đã tải ${products.length} sản phẩm từ Firebase");
    } catch (e) {
      print('Lỗi khi tải sản phẩm: $e');
      setState(() {
        errorMessage = 'Không thể tải danh sách sản phẩm. Vui lòng thử lại!';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<ProductModel> products = _isLoading ? [] : mockProducts;
    const int totalPage = 5; // Giá trị cố định cho FE
    const int currentPage = 1; // Giá trị cố định cho FE

    if (errorMessage.isNotEmpty && products.isEmpty) {
      final mediaQuery = MediaQuery.of(context);
      final remainingHeight = mediaQuery.size.height - 350;

      return SizedBox(
        height: remainingHeight,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/No_Internet.png',
                width: 250,
                height: 250,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 300,
                child: Text(
                  errorMessage,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        GridView.builder(
          itemCount: _isLoading ? 10 : products.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: Responsive.isDesktop(context) ? 4 : 2,
            childAspectRatio: 0.55,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            mainAxisExtent: 350,
          ),
          itemBuilder: (context, index) {
            final variant =
                !_isLoading && index < products.length ? products[index] : null;
            return _isLoading
                ? const Skeleton()
                : ProductView(
                    id: variant?.id ?? '',
                    categoryId: variant?.categoryId ?? '',
                    name: variant?.name ?? '',
                    image: variant!.imageUrl,
                    price: (variant?.price as double),
                    averageRating: variant?.averageRating?.toString() ?? '0.0',
                  );
          },
        ),
        const SizedBox(
          height: 20,
        ),
        PaginationWidget(
          currentPage: currentPage,
          totalPages: totalPage,
          onPageChanged: (page) {
          },
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}

class ProductView extends StatelessWidget {
  final String name;
  final String image;
  final double price;
  final String averageRating;
  final String id;
  final String categoryId;

  const ProductView({
    super.key,
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.averageRating,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(

      onTap: () {
        print('🛒 Đang mở chi tiết sản phẩm có ID: $id'); // 👉 In ra ID trong log

        context.push(
          '/product-details/$id',
          extra: {
            'categoryId': categoryId,
          },
        );
      },

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color.fromARGB(255, 219, 219, 219)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 150, maxHeight: 350),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(5),
                height: 180,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  child: CachedNetworkImage(
                          imageUrl: image,
                          placeholder: (context, url) => const SkeletonImage(
                            imageHeight: 160,
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                              'assets/images/image_default_error.png'),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatMoney(price.toDouble()),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                      fontSize: FontSizes.medium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 15, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(double.parse(averageRating).toStringAsFixed(1)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterHomeProduct extends StatefulWidget {
  const FilterHomeProduct({super.key});

  @override
  State<FilterHomeProduct> createState() => _FilterHomeProductState();
}

class _FilterHomeProductState extends State<FilterHomeProduct> {
  final List<String> filtersList = [
    'All',
    'Newest',
    'Best Seller',
    'Low to High',
    'High to Low',
  ];

  late String isSelectedList;
  @override
  void initState() {
    super.initState();
    isSelectedList = filtersList[0];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(),
        const SizedBox(height: 20),
        Text(
          'Product',
          style: TextStyle(
              fontSize: lerpDouble(
                  16, 18, (MediaQuery.of(context).size.width - 300) / 300),
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 40,
          child: ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            scrollDirection: Axis.horizontal,
            itemCount: filtersList.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  setState(() {
                    isSelectedList = filtersList[index];
                    debugPrint('Lọc theo: ${filtersList[index]}');
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelectedList == filtersList[index]
                        ? AppColors.orangePastel
                        : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(
                      filtersList[index],
                      style: TextStyle(
                          color: isSelectedList == filtersList[index]
                              ? AppColors.primary
                              : Colors.black,
                          fontWeight: FontWeight.w600),
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