import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';

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
import 'package:recomart/views/pages/client/product/widgets/similar_product_widget.dart';

import '../../../../models/cart.model.dart';
import '../../../../models/review.model.dart';
import '../../../../provider/cart_provider.dart';
import '../../../../provider/user_provider.dart';
import '../../../../services/review.service.dart';

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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            hintText: 'Enter your review...', 
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
                showCustomSnackBar(context, 'Please provide rating and comment', type: SnackBarType.warning);
                return;
              }
              widget.onSubmit(_rating, _controller.text.trim());
              setState(() { _rating = 0; _controller.clear(); });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Submit Review', style: TextStyle(color: Colors.white)),
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
          _errorMessage = 'Failed to load product details.';
          _isLoading = false;
        });
      }
    }
  }

  void _handleAddToCart(GlobalKey widgetKey) async {
    if (_product == null) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    if (userProvider.user == null) {
      showCustomSnackBar(context, 'Please login to add to cart!', type: SnackBarType.warning);
      return;
    }

    await runAddToCartAnimation(widgetKey);

    if (!mounted) return;

    try {
      final newItem = ProductForCartModel(
        productId: _product!.id,
        productName: _product!.name,
        quantity: quantity,
        unitPrice: _product!.price,
        discount: _product!.discount,
        image: _product!.imageUrl,
      );

      await cartProvider.addToCart(newItem, userProvider.user!.id);
      showCustomSnackBar(context, 'Added to cart!', type: SnackBarType.success);
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(context, 'Error: $e', type: SnackBarType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context); 
    final currentUser = userProvider.user;

    final bool isMobile = utils.Responsive.isMobile(context);
    final bool isDesktop = utils.Responsive.isDesktop(context);
    final double screenWidth = MediaQuery.of(context).size.width;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage.isNotEmpty || _product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Details')),
        body: Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red))),
      );
    }

    final product = _product!;
    final double discountedPrice = product.price - (product.price * (product.discount / 100));

    return AddToCartAnimation(
      cartKey: cartKey,
      height: 30,
      width: 30,
      opacity: 0.85,
      dragAnimation: const DragToCartAnimationOptions(rotation: true),
      jumpAnimation: const JumpAnimationOptions(),
      createAddToCartAnimation: (runAnimation) {
        runAddToCartAnimation = runAnimation;
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
                title: const Text('Details', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
          ? _buildMobileBottomActions(product)
          : null,

        body: ListView(
          children: [
            Wrap(
              spacing: 0,
              runSpacing: 20,
              children: [
                Container(
                  key: _imageKey, 
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 64, vertical: 16),
                  height: isMobile ? 300 : 500,
                  width: screenWidth < 1200 ? screenWidth : screenWidth * 0.5,
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
                  width: screenWidth < 1200 ? screenWidth : screenWidth * 0.5,
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
                            style: const TextStyle(fontSize: FontSizes.extraLarge, color: AppColors.secondary, fontWeight: FontWeight.bold),
                          ),
                          if (product.discount > 0)
                            Text(
                              formatMoney(product.price),
                              style: const TextStyle(fontSize: FontSizes.medium, color: Colors.grey, decoration: TextDecoration.lineThrough),
                            ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Quantity(
                        quantity: quantity,
                        onIncrease: () {
                          if (quantity < product.stock) setState(() => quantity++);
                        },
                        onDecrease: () {
                          if (quantity > 1) setState(() => quantity--);
                        },
                      ),
                      if (!isMobile) _buildDesktopButtons(product),
                      const SizedBox(height: 30),
                      DescriptionProduct(
                        description: product.description.isNotEmpty ? product.description : 'No detailed description available.',
                      ),
                    ],
                  ),
                ),

                _buildSpecifications(product, isMobile, isDesktop, screenWidth),
                _buildReviewsSection(product, currentUser, isMobile, isDesktop, screenWidth),
                
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 64, vertical: 16),
                  child: SimilarProductWidget(productId: product.id),
                ),

                _buildRelatedProductsGrid(isMobile, isDesktop),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileBottomActions(ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _handleAddToCart(_imageKey),
              icon: const Icon(FeatherIcons.shoppingCart, color: Colors.white, size: 18),
              label: const Text('Add to Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              onPressed: () => _navigateToCheckout(product),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Buy Now', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopButtons(ProductModel product) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _handleAddToCart(_imageKey),
              icon: const Icon(FeatherIcons.shoppingCart, color: Colors.white, size: 20),
              label: const Text('Add to Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              onPressed: () => _navigateToCheckout(product),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Buy Now', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCheckout(ProductModel product) {
    context.push('/checkout', extra: {
      'productId': product.id,
      'productName': product.name,
      'imageUrl': product.imageUrl,
      'unitPrice': product.price,
      'quantity': quantity,
      'discount': product.discount,
    });
  }

  Widget _buildSpecifications(ProductModel product, bool isMobile, bool isDesktop, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 64, vertical: 16),
      child: SizedBox(
        width: screenWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Product Specifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Table(
              columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
              children: [
                _buildInfoRow('Brand', product.brandName ?? 'Unknown'),
                _buildInfoRow('Category', product.categoryName ?? 'Unknown'),
                _buildInfoRow('SKU', product.id),
                _buildInfoRow('Status', product.stock > 0 ? 'In Stock' : 'Out of Stock'),
                _buildInfoRow('Stock', '${product.stock}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsSection(ProductModel product, dynamic currentUser, bool isMobile, bool isDesktop, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 64, vertical: 16),
      child: Container(
        width: screenWidth,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: StreamBuilder<List<ReviewModel>>(
          stream: _reviewService.streamReviewsByProduct(product.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            final reviews = snapshot.data ?? [];
            final avgRating = reviews.isNotEmpty ? reviews.map((r) => r.rating ?? 0).reduce((a, b) => a + b) / reviews.length : 0.0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      const Icon(Icons.star, color: Colors.amber, size: 28),
                      const SizedBox(width: 8),
                      Text('${avgRating.toStringAsFixed(1)}/5', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ]),
                    Text('${reviews.length} reviews'),
                  ],
                ),
                const Divider(height: 24),
                if (reviews.isEmpty) const Text('No reviews yet.') else ...reviews.map((r) => _buildReviewItem(r)),
                const SizedBox(height: 16),
                const Text('Write your review', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                _ReviewForm(onSubmit: (rating, comment) => _submitReview(product, currentUser, rating, comment)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildReviewItem(ReviewModel r) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: List.generate(5, (i) => Icon(i < (r.rating ?? 0) ? Icons.star : Icons.star_border, color: Colors.amber, size: 16))),
          const SizedBox(height: 4),
          Row(children: [
            CircleAvatar(
              radius: 14,
              backgroundImage: (r.user?.avatar != null && r.user!.avatar.isNotEmpty)
                  ? NetworkImage(r.user!.avatar)
                  : const AssetImage('assets/images/avatar_default.png') as ImageProvider,
            ),
            const SizedBox(width: 8),
            Text(r.user?.name ?? 'Anonymous', style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 4),
          Text(r.content, style: const TextStyle(color: Colors.black87, fontSize: 15)),
          const Divider(),
        ],
      ),
    );
  }

  Future<void> _submitReview(ProductModel product, dynamic currentUser, int rating, String comment) async {
    try {
      if (currentUser == null) {
        showCustomSnackBar(context, 'Please login to submit a review!', type: SnackBarType.error);
        return;
      }
      final newReview = ReviewModel(
        id: '',
        productId: product.id,
        userId: currentUser.id,
        content: comment,
        rating: rating,
        user: UserModelForReview(
          id: currentUser.id, 
          name: currentUser.fullName, 
          avatar: currentUser.avatar ?? 'https://i.pravatar.cc/150?u=${currentUser.id}'
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _reviewService.addReviewForProduct(product.id, newReview);
      showCustomSnackBar(context, 'Review submitted!', type: SnackBarType.success);
    } catch (e) {
      showCustomSnackBar(context, 'Failed to submit review: $e', type: SnackBarType.error);
    }
  }

  Widget _buildRelatedProductsGrid(bool isMobile, bool isDesktop) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 64, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Related Products', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _relatedProducts.isEmpty
              ? const Center(child: Text('No related products found'))
              : GridView.builder(
                  itemCount: _relatedProducts.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isDesktop ? 4 : 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) {
                    final item = _relatedProducts[index];
                    return _buildProductCard(item);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductModel item) {
    return GestureDetector(
      onTap: () => context.push('/product-details/${item.id}/${item.categoryId}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(16), 
          border: Border.all(color: Colors.grey[300]!)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: item.imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => const SkeletonImage(imageHeight: 160),
                errorWidget: (context, url, error) => Image.asset('assets/images/image_default_error.png'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Text(formatMoney(item.price), style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}