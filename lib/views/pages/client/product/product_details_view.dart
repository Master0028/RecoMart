import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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

import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:recomart/views/pages/client/product/widgets/similar_product_widget.dart';

import '../../../../models/cart.model.dart';
import '../../../../models/review.model.dart';
import '../../../../provider/cart_provider.dart';
import '../../../../services/review.service.dart';
import '../../../../services/user.service.dart';

TableRow _buildInfoRow(String label, String value) {
  return TableRow(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(value),
      ),
    ],
  );
}

class _ReviewForm extends StatefulWidget {
  final Function(int rating, String comment) onSubmit;
  const _ReviewForm({required this.onSubmit});
  @override
  State<_ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<_ReviewForm> {
  int _rating = 0;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(5, (index) => IconButton(
            onPressed: () => setState(() => _rating = index + 1),
            icon: Icon(
              index < _rating ? Icons.star : Icons.star_border,
              color: Colors.amber,
            ),
          )),
        ),
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: 'Nhập nhận xét của bạn...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () {
              if (_rating == 0 || _controller.text.trim().isEmpty) {
                return;
              }
              widget.onSubmit(_rating, _controller.text.trim());
              setState(() { _rating = 0; _controller.clear(); });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Gửi đánh giá', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}

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
  final ReviewService _reviewService = ReviewService();
  final UserService _userService = UserService();
  ProductModel? _product;
  List<ProductModel> _relatedProducts = [];

  bool _isLoading = true;
  String _errorMessage = '';
  int quantity = 1;

  GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) runAddToCartAnimation;
  final GlobalKey _imageKey = GlobalKey(); 

  @override
  void initState() {
    super.initState();
    _fetchProductData();
  }

  Future<void> _fetchProductData() async {
    try {
      final product = await _productService.getProductById(widget.productId);
      final related = await _productService.getProductsByCategory(widget.categoryId);

      if (mounted) {
        setState(() {
          _product = product;
          _relatedProducts = related.where((p) => p.id != product.id).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Không thể tải chi tiết sản phẩm.';
          _isLoading = false;
        });
      }
    }
  }

  void _handleAddToCart(GlobalKey widgetKey) async {
    if (_product == null) return;

    await runAddToCartAnimation(widgetKey);

    if (!mounted) return;
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    try {
      final newItem = ProductForCartModel(
        productId: _product!.id ?? '',
        productName: _product!.name ?? '',
        quantity: quantity,
        unitPrice: _product!.price,
        discount: _product!.discount,
        image: _product!.imageUrl ?? '',
      );

      await cartProvider.addToCart(newItem);

    } catch (e) {
      if (mounted) {
        showCustomSnackBar(context, 'Lỗi: $e', type: SnackBarType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = utils.Responsive.isMobile(context);
    final bool isDesktop = utils.Responsive.isDesktop(context);
    final double screenWidth = MediaQuery.of(context).size.width;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage.isNotEmpty || _product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết sản phẩm')),
        body: Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red))),
      );
    }

    final product = _product!;
    final double discountedPrice = product.price - (product.price * (product.discount / 100));

    // Bọc Scaffold bằng AddToCartAnimation
    return AddToCartAnimation(
      cartKey: cartKey,
      height: 30,
      width: 30,
      opacity: 0.85,
      dragAnimation: const DragToCartAnimationOptions(
        rotation: true,
      ),
      jumpAnimation: const JumpAnimationOptions(),
      createAddToCartAnimation: (runAddToCartAnimation) {
        this.runAddToCartAnimation = runAddToCartAnimation;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        
        appBar: !isMobile 
            ? AppBarHomeCustom(cartKey: cartKey) 
            : AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                  onPressed: () => context.pop(),
                ),
                title: const Text('Chi tiết', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                centerTitle: true,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: AddToCartIcon(
                      key: cartKey,
                      icon: const Icon(FeatherIcons.shoppingCart, color: Colors.black),
                      badgeOptions: const BadgeOptions(active: true, backgroundColor: Colors.red),
                    ),
                  )
                ],
              ),
        
        bottomNavigationBar: isMobile 
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleAddToCart(_imageKey),
                      icon: const Icon(FeatherIcons.shoppingCart, color: Colors.white, size: 18),
                      label: const Text('Thêm giỏ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        context.push('/checkout', extra: {
                          'productId': product.id,
                          'productName': product.name,
                          'imageUrl': product.imageUrl,
                          'unitPrice': product.price,
                          'quantity': quantity,
                          'discount': product.discount,
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Mua ngay', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            )
          : null,

        body: ListView(
          children: [
            Wrap(
              spacing: 40,
              runSpacing: 20,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: [
                Container(
                  key: _imageKey, // Gán Key để Animation biết vị trí bắt đầu
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

                Container(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 64, vertical: 16),
                  width: screenWidth < 1200 ? double.infinity : screenWidth * 0.43,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 10),
                      
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.end,
                        spacing: 10,
                        children: [
                          Text(
                            formatMoney(discountedPrice),
                            style: TextStyle(fontSize: FontSizes.extraLarge, color: AppColors.secondary, fontWeight: FontWeight.bold),
                          ),
                          if (product.discount > 0)
                            Text(
                              formatMoney(product.price),
                              style: const TextStyle(fontSize: FontSizes.medium, color: Colors.grey, decoration: TextDecoration.lineThrough),
                            ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      
                      // Chọn số lượng
                      Quantity(
                        quantity: quantity,
                        onIncrease: () {
                          if (quantity < product.stock) setState(() => quantity++);
                        },
                        onDecrease: () {
                          if (quantity > 1) setState(() => quantity--);
                        },
                      ),
                      
                      // Nút bấm (Chỉ hiện trên Desktop, Mobile đã có ở BottomBar)
                      if (!isMobile) ...[
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _handleAddToCart(_imageKey),
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
                                  context.push('/checkout', extra: {
                                    'productId': product.id,
                                    'productName': product.name,
                                    'imageUrl': product.imageUrl,
                                    'unitPrice': product.price,
                                    'quantity': quantity,
                                    'discount': product.discount,
                                  });
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
                      ]
                    ],
                  ),
                ),

                // --- MÔ TẢ SẢN PHẨM ---
                Container(
                  width: !isDesktop ? double.infinity : screenWidth * 0.43,
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 64, vertical: 16),
                  child: DescriptionProduct(
                    description: product.description.isNotEmpty ? product.description : 'Không có mô tả chi tiết cho sản phẩm này.',
                  ),
                ),
                
                // --- BẢNG THÔNG SỐ KỸ THUẬT ---
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 64, vertical: 16),
                  child: Container(
                    width: !isDesktop ? double.infinity : screenWidth * 0.43,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thông tin sản phẩm',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 10),
                        Table(
                          columnWidths: const {
                            0: IntrinsicColumnWidth(),
                            1: FlexColumnWidth(),
                          },
                          children: [
                            _buildInfoRow('Thương hiệu', product.brandName ?? 'Không xác định'),
                            _buildInfoRow('Danh mục', product.categoryName ?? 'Không xác định'),
                            _buildInfoRow('Mã sản phẩm', product.id ?? '-'),
                            _buildInfoRow('Tình trạng', product.stock > 0 ? 'Còn hàng' : 'Hết hàng'),
                            _buildInfoRow('Số lượng còn lại', '${product.stock}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // --- PHẦN ĐÁNH GIÁ (REVIEWS) ---
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 64, vertical: 16),
                  child: Container(
                    width: !isDesktop ? double.infinity : screenWidth * 0.43,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Đánh giá & Nhận xét',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),

                        StreamBuilder<List<ReviewModel>>(
                          stream: _reviewService.streamReviewsByProduct(product.id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            final reviews = snapshot.data ?? [];

                            final avgRating = reviews.isNotEmpty
                                ? reviews.map((r) => r.rating ?? 0).reduce((a, b) => a + b) / reviews.length
                                : 0.0;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 28),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${avgRating.toStringAsFixed(1)}/5',
                                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Text('${reviews.length} lượt đánh giá'),
                                  ],
                                ),
                                const Divider(height: 24),

                                if (reviews.isEmpty)
                                  const Text('Chưa có nhận xét nào cho sản phẩm này.')
                                else
                                  ...reviews.map((r) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: List.generate(5, (i) => Icon(
                                            i < (r.rating ?? 0) ? Icons.star : Icons.star_border,
                                            color: Colors.amber,
                                            size: 16,
                                          )),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 14,
                                              backgroundImage: r.user?.avatar.isNotEmpty == true
                                                  ? NetworkImage(r.user!.avatar)
                                                  : const AssetImage('assets/images/avatar_default.png') as ImageProvider,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              r.user?.name ?? 'Người dùng ẩn danh',
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          r.content,
                                          style: const TextStyle(color: Colors.black87, fontSize: 15),
                                        ),
                                        const Divider(),
                                      ],
                                    ),
                                  )),

                                const SizedBox(height: 16),

                                const Text(
                                  'Viết đánh giá của bạn',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                _ReviewForm(
                                  onSubmit: (rating, comment) async {
                                    try {
                                      final currentUser = FirebaseAuth.instance.currentUser;
                                      if (currentUser == null) {
                                        showCustomSnackBar(context, 'Vui lòng đăng nhập để gửi đánh giá!', type: SnackBarType.error);
                                        return;
                                      }
                                      final userId = currentUser.uid;
                                      final userData = await _userService.getUserInfo(userId);

                                      if (userData == null) {
                                        showCustomSnackBar(context, 'Không tìm thấy thông tin người dùng!', type: SnackBarType.error);
                                        return;
                                      }

                                      final userName = userData['name'] ?? 'Người dùng';
                                      final userAvatar = userData['avatar'] ?? 'https://i.pravatar.cc/150?u=$userId';

                                      final newReview = ReviewModel(
                                        id: '',
                                        productId: product.id,
                                        userId: userId,
                                        content: comment,
                                        rating: rating,
                                        user: UserModelForReview(id: userId, name: userName, avatar: userAvatar),
                                        createdAt: DateTime.now(),
                                        updatedAt: DateTime.now(),
                                      );

                                      await _reviewService.addReviewForProduct(product.id, newReview);
                                      showCustomSnackBar(context, 'Cảm ơn bạn đã đánh giá $rating sao!', type: SnackBarType.success);
                                    } catch (e) {
                                      showCustomSnackBar(context, 'Không thể gửi đánh giá: $e', type: SnackBarType.error);
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 64, vertical: 16),
                  child: SimilarProductWidget(productId: product.id ?? '0'),
                ),

                // --- SẢN PHẨM CÙNG DANH MỤC ---
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 64, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sản phẩm cùng danh mục',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.black),
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
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[300]!)),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                                          child: CachedNetworkImage(imageUrl: item.imageUrl, height: 160, width: double.infinity, fit: BoxFit.cover, placeholder: (context, url) => const SkeletonImage(imageHeight: 160), errorWidget: (context, url, error) => Image.asset('assets/images/image_default_error.png')),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                            Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                                            const SizedBox(height: 5),
                                            Text(formatMoney(item.price), style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                                          ]),
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
      ),
    );
  }
}