import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:recomart/components/custom/pagination.dart';
import 'package:recomart/components/custom/skeleton.dart';
import 'package:recomart/components/custom/snackbar.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/config/font.dart';
import 'package:recomart/helpers/formatMoney.dart';
import 'package:recomart/models/product.model.dart';
import 'package:recomart/services/product.service.dart';
import 'package:recomart/utils/responsive.dart' as utils;
import 'package:recomart/views/pages/client/home/widgets/appBar_widget.dart';
import 'package:recomart/views/pages/client/product/widgets/description_product.dart';
import 'package:recomart/views/pages/client/product/widgets/quantity.dart';

class ProductDetailsView extends StatefulWidget {
  const ProductDetailsView({
    super.key,
    required this.productId,
    required this.categoryId,
  });

  final String productId;
  final String categoryId;

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<ProductDetailsView> {
  final ProductService _productService = ProductService();
  ProductModel? _product;
  List<ProductModel> _relatedProducts = [];

  bool _isLoading = true;
  String _errorMessage = '';
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    _fetchProductData();
  }

  Future<void> _fetchProductData() async {
    try {
      final product = await _productService.getProductById(widget.productId);
      final related = await _productService.getProductsByCategory(widget.categoryId);

      setState(() {
        _product = product;
        _relatedProducts = related.where((p) => p.id != product.id).toList();
        _isLoading = false;
      });

      print('✅ Loaded product: ${product.name}');
      print('📦 Related: ${_relatedProducts.length} items');
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải chi tiết sản phẩm.';
        _isLoading = false;
      });
      print('❌ Lỗi khi tải chi tiết: $e');
    }
  }

  void _handleAddToCart() {
    if (_product == null) return;
    showCustomSnackBar(
      context,
      '🛒 Đã thêm "${_product!.name}" vào giỏ hàng',
      type: SnackBarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = utils.Responsive.isMobile(context);
    final bool isDesktop = utils.Responsive.isDesktop(context);
    final double screenWidth = MediaQuery.of(context).size.width;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty || _product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết sản phẩm')),
        body: Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red))),
      );
    }

    final product = _product!;
    final double discountedPrice = product.price - (product.price * (product.discount / 100));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: !isMobile ? const AppBarHomeCustom() : null,
      body: ListView(
        children: [
          Wrap(
            spacing: 40,
            runSpacing: 20,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              // ==================== HÌNH ẢNH ====================
              Container(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 64, vertical: 16),
                height: isMobile ? 300 : 500,
                width: screenWidth < 1200 ? double.infinity : screenWidth * 0.52,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    placeholder: (context, url) => const SkeletonImage(imageHeight: 300),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/images/image_default_error.png',
                      fit: BoxFit.cover,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // ==================== THÔNG TIN CHÍNH ====================
              Container(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 64, vertical: 16),
                width: screenWidth < 1200 ? double.infinity : screenWidth * 0.43,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatMoney(discountedPrice),
                          style: TextStyle(
                            fontSize: FontSizes.extraLarge,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (product.discount > 0)
                          Text(
                            formatMoney(product.price),
                            style: const TextStyle(
                              fontSize: FontSizes.medium,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(product.averageRating.toStringAsFixed(1)),
                        const SizedBox(width: 4),
                        Text('(${product.reviewCount} đánh giá)'),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Quantity(
                      quantity: quantity,
                      onIncrease: () {
                        if (quantity < product.stock) {
                          setState(() {
                            quantity++;
                          });
                        }
                      },
                      onDecrease: () {
                        if (quantity > 1) {
                          setState(() {
                            quantity--;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _handleAddToCart,
                            icon: const Icon(FeatherIcons.shoppingCart, color: Colors.white, size: 20),
                            label: const Text('Thêm vào giỏ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              print('🛍️ Mua ngay ${product.name}');
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(color: AppColors.primary, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Mua ngay', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ==================== MÔ TẢ ====================
              Container(
                width: !isDesktop ? double.infinity : screenWidth * 0.43,
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 64, vertical: 16),
                child: DescriptionProduct(
                  description: product.description.isNotEmpty
                      ? product.description
                      : 'Không có mô tả chi tiết cho sản phẩm này.',
                ),
              ),

              // ==================== ĐÁNH GIÁ ====================
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 64, vertical: 16),
                child: Container(
                  width: !isDesktop ? double.infinity : screenWidth * 0.43,
                  height: 220,
                  color: Colors.grey[100],
                  child: const Center(
                    child: Text('⭐ Khu vực hiển thị đánh giá (review section)'),
                  ),
                ),
              ),

              // ==================== SẢN PHẨM LIÊN QUAN ====================
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 64, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sản phẩm liên quan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _relatedProducts.isEmpty
                        ? const Center(child: Text('Không có sản phẩm liên quan'))
                        : GridView.builder(
                      itemCount: _relatedProducts.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: utils.Responsive.isDesktop(context) ? 4 : 2,
                        childAspectRatio: 0.55,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 320,
                      ),
                      itemBuilder: (context, index) {
                        final item = _relatedProducts[index];
                        return GestureDetector(
                          onTap: () {
                            print('🛒 Navigate to product ${item.id}');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailsView(
                                  productId: item.id,
                                  categoryId: item.categoryId,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                                  child: CachedNetworkImage(
                                    imageUrl: item.imageUrl,
                                    height: 160,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                    const SkeletonImage(imageHeight: 160),
                                    errorWidget: (context, url, error) =>
                                        Image.asset('assets/images/image_default_error.png'),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold, fontSize: 14),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 5),
                                      Text(formatMoney(item.price),
                                          style: TextStyle(
                                              color: AppColors.secondary,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
