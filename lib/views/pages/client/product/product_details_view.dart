import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recomart/components/custom/bottom_navigation_bar.dart';
import 'package:recomart/components/custom/pagination.dart';
import 'package:recomart/components/custom/skeleton.dart';
import 'package:recomart/components/custom/snackbar.dart';
import 'package:recomart/components/ui/slider_product.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/config/font.dart';
import 'package:recomart/helpers/formatMoney.dart';
import 'package:recomart/utils/responsive.dart' as utils;
import 'package:recomart/views/pages/client/home/widgets/appBar_widget.dart';
import 'package:recomart/views/pages/client/product/widgets/description_product.dart';
import 'package:recomart/views/pages/client/product/widgets/quantity.dart';
import 'package:recomart/views/pages/client/product/widgets/title_product.dart';
import 'package:recomart/views/pages/client/product/widgets/version_product.dart';
import 'package:feather_icons/feather_icons.dart';


class ProductImageFE {
  final String url;
  ProductImageFE({required this.url});
}

final Map<String, dynamic> FE_PRODUCT_STUB = {
  'id': 'stub_id',
  'variantName': 'FE Product Name',
  'variantColor': 'FE Color',
  'variantDescription': 'FE Description for the product.',
  'price': 5000000.0,
  'discount': 0.1,
  'quantity': 10,
  'averageRating': 4.7,
  'reviewCount': 150,
  'images': [ProductImageFE(url: 'https://picsum.photos/id/400/600/400')],
  'categoryId': 'FE_CAT_ID',
  'isActive': true,
};

final List<Map<String, dynamic>> FE_RELATED_VARIANTS = [
  {'id': 'v1', 'variantName': 'Variant 1', 'variantColor': 'Gray', 'images': [ProductImageFE(url: 'https://picsum.photos/id/401/600/400')], 'price': 5000000.0, 'discount': 0.05, 'averageRating': 4.5, 'reviewCount': 100},
  {'id': 'v2', 'variantName': 'Variant 2', 'variantColor': 'Silver', 'images': [ProductImageFE(url: 'https://picsum.photos/id/402/600/400')], 'price': 5500000.0, 'discount': 0.0, 'averageRating': 4.8, 'reviewCount': 120},
];

final List<dynamic> FE_REVIEWS = List.generate(3, (i) => {'id': 'rv_$i', 'rating': 5, 'content': 'Review FE $i'});
final List<dynamic> FE_COMMENTS = List.generate(2, (i) => {'id': 'cmt_$i', 'rating': 0, 'content': 'Comment FE $i'});


class MockSocketServiceFE { 
  void connect({required String productVariantId}) {
    debugPrint('FE: Connect Socket stub to $productVariantId');
  }
  void disconnect() {
    debugPrint('FE: Disconnect Socket stub');
  }
  void onNewReview(Function(Map<String, dynamic> data) callback) {
    debugPrint('FE: Listen for new review stub');
  }
}


class ProductDetailsView extends StatefulWidget {
  const ProductDetailsView(
      {super.key, required this.productId, required this.categoryId});
  final String productId;
  final String categoryId;

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<ProductDetailsView> {
  final MockSocketServiceFE socketService = MockSocketServiceFE(); 

  Map<String, dynamic> product = FE_PRODUCT_STUB;
  List<dynamic> relatedProductsVariant = [];

  List<dynamic> reviews = [];
  List<dynamic> comments = [];
  int currentPage = 1;
  int totalPages = 5;
  bool isLoadingReview = false;
  bool isLoadingComment = false;
  bool isLoading = false;

  double averageRating = 0.0;
  int reviewCount = 0;

  List<String> images = ['https://placehold.co/600x400.png'];
  int quantity = 1;

  Future<void> fetchProductDetails() async {
    setState(() {
      isLoading = true;
    });
    await Future.delayed(const Duration(milliseconds: 500)); 

    setState(() {
      product = FE_RELATED_VARIANTS.firstWhere(
          (v) => v['id'] == widget.productId,
          orElse: () => FE_PRODUCT_STUB);
          
      relatedProductsVariant = FE_RELATED_VARIANTS;
      images = (product['images'] as List<ProductImageFE>).map((img) => img.url).toList();
      averageRating = product['averageRating'] ?? 0.0;
      reviewCount = product['reviewCount'] ?? 0;
      isLoading = false;
    });
  }

  void handleSelectVariant(String variantId) async {
    setState(() {
      isLoadingReview = true;
      isLoadingComment = true;
    });

    final newProduct = relatedProductsVariant.firstWhere(
        (variant) => variant['id'] == variantId,
        orElse: () => product);

    socketService.disconnect();
    socketService.connect(productVariantId: newProduct['id']);

    setState(() {
      product = newProduct;
      images = (newProduct['images'] as List<ProductImageFE>).map((img) => img.url).toList();
    });

    await Future.delayed(const Duration(milliseconds: 300)); 

    setState(() {
      reviews = FE_REVIEWS;
      comments = FE_COMMENTS;
      isLoadingReview = false;
      isLoadingComment = false;
    });
  }

  Future<void> fetchReviewsRating({int page = 1}) async {
    setState(() {
      isLoadingReview = true;
    });
    await Future.delayed(const Duration(milliseconds: 300)); 
    setState(() {
      reviews = FE_REVIEWS;
      totalPages = 5;
      currentPage = page;
      averageRating = 4.7;
      reviewCount = 150;
      isLoadingReview = false;
    });
  }

  Future<void> fetchComments({int page = 1}) async {
    setState(() {
      isLoadingComment = true;
    });
    await Future.delayed(const Duration(milliseconds: 300)); 
    setState(() {
      comments = FE_COMMENTS;
      totalPages = 5;
      currentPage = page;
      isLoadingComment = false;
    });
  }

  Future<void> _initSocketAndLoadData() async {
    socketService.connect(productVariantId: product['id']);
  }

  @override
  void initState() {
    super.initState();
    product = FE_PRODUCT_STUB; 

    fetchProductDetails().then((_) {
      _initSocketAndLoadData();
    });
    fetchReviewsRating();
    fetchComments();
  }

  @override
  void dispose() {
    super.dispose();
    socketService.disconnect();
  }
  
  void _handleAddToCartFE() {
      showCustomSnackBar(
          context,
          'You have added to cart (FE Action)',
          type: SnackBarType.success,
        );
  }


  @override
  Widget build(BuildContext context) {
    double isWrap = MediaQuery.of(context).size.width;
    bool isMobile = utils.Responsive.isMobile(context);
    bool isDesktop = utils.Responsive.isDesktop(context);
    
    final currentProduct = product; 
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: !isMobile ? const AppBarHomeCustom() : null,
      body: ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index) => Stack(
          children: [
            SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: 40,
                runSpacing: 20,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 300,
                      minHeight: 300,
                    ),
                    child: Container(
                        padding: !isMobile
                            ? const EdgeInsets.only(
                                top: 16,
                                left: 64,
                                right: 64,
                              )
                            : const EdgeInsets.only(
                                left: 16,
                                right: 16,
                              ),
                        height: isMobile ? 300 : 500,
                        width: isWrap < 1200 ? double.infinity : isWrap * 0.52,
                        child: SliderProductCustom(
                          imagesUrl: images,
                          isLoading: isLoading,
                        )),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 300,
                    ),
                    child: Container(
                      padding: !isMobile
                          ? const EdgeInsets.only(
                              top: 16,
                              left: 64,
                              right: 64,
                            )
                          : const EdgeInsets.only(
                              left: 16,
                              right: 16,
                            ),
                      width: isWrap < 1200 ? double.infinity : isWrap * 0.43,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TitleProduct(
                            title: currentProduct['variantName'] ?? 'FE Product',
                            price: currentProduct['price'] ?? 0.0,
                            discount: currentProduct['discount'] ?? 0.0,
                          ),
                          const SizedBox(height: 20),
                          VersionProduct(
                            relatedProductsVariant: relatedProductsVariant,
                            handleSelectVariant: handleSelectVariant,
                            isSelected: currentProduct['id'],
                          ),
                          const SizedBox(height: 20),
                          Quantity(
                            quantity: quantity,
                            onIncrease: () {
                              if (quantity < 99) {
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
                          if (!isMobile)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 50,
                                    margin: const EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton.icon(
                                      onPressed: _handleAddToCartFE, 
                                      icon: const Icon(FeatherIcons.shoppingCart,
                                          color: Colors.white, size: 20),
                                      label: const Text(
                                        'Add to cart',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 50,
                                    margin: const EdgeInsets.only(left: 10),
                                    child: OutlinedButton(
                                      onPressed: () {
                                        print('Buy now clicked');
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.primary,
                                        side: BorderSide(
                                            color: AppColors.primary, width: 2),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                      ),
                                      child: Text(
                                        'Buy now',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: !isDesktop ? double.infinity : isWrap * 0.43,
                    padding: !isMobile
                        ? const EdgeInsets.only(
                            top: 16,
                            left: 64,
                            right: 64,
                          )
                        : const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 16,
                          ),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DescriptionProduct(
                          description: currentProduct['variantDescription'] ?? 'FE Description',
                        ),
                        const SizedBox(height: 20),
                        Container(
                          height: 200, 
                          color: Colors.grey[100], 
                          child: const Center(child: Text('Product Review Section (FE Placeholder)')),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Related Products',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: !isMobile
                        ? const EdgeInsets.only(
                            top: 16,
                            left: 64,
                            right: 64,
                          )
                        : const EdgeInsets.only(
                            left: 16,
                            right: 16,
                          ),
                    child: Container(
                        height: 350, 
                        width: isWrap < 1200 ? double.infinity : isWrap * 0.43,
                        color: Colors.grey[100], 
                        child: const Center(child: Text('Product Relevant Section (FE Placeholder)'))
                    ),
                  ),
                  Padding(
                    padding: !isMobile
                        ? const EdgeInsets.only(
                            top: 16,
                            left: 64,
                            right: 64,
                          )
                        : const EdgeInsets.only(
                            left: 16,
                            right: 16,
                          ),
                    child: Container(
                        height: 200, 
                        width: isWrap < 1200 ? double.infinity : isWrap * 0.43,
                        color: Colors.grey[100], 
                        child: const Center(child: Text('Product Comment Section (FE Placeholder)'))
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            if (utils.Responsive.isTablet(context))
              Positioned(
                top: 0,
                left: 64,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () {
                        Navigator.pop(context); 
                      },
                    ),
                    const Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            if (isMobile)
              Positioned(
                top: 20,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButtonCustom(
                      icon: Icons.arrow_back_ios_rounded,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    IconButtonCustom(
                      icon: CupertinoIcons.square_grid_2x2,
                      onPressed: () {
                         Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: isMobile
          ? Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, -5),
                  ),
                ],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              width: double.infinity,
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.5)),
                      ),
                      margin: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        onPressed: () {
                          print('Chat button clicked');
                        },
                        icon: Icon(
                          FeatherIcons.messageCircle,
                          color: AppColors.primary,
                          size: 25,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.5)),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: IconButton(
                        onPressed: () {
                          debugPrint('Go to Cart');
                        },
                        icon: Icon(
                          FeatherIcons.shoppingCart,
                          color: AppColors.primary,
                          size: 25,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: double.infinity,
                      margin: const EdgeInsets.only(left: 8),
                      child: ElevatedButton(
                        onPressed: _handleAddToCartFE,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                          shadowColor: AppColors.primary.withOpacity(0.5),
                        ),
                        child: Text(
                          'Add to cart',
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          : null,
    );
  }
}

class IconButtonCustom extends StatelessWidget {
  const IconButtonCustom({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () {
          onPressed();
        },
        icon: Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class ProductRelevant extends StatefulWidget {
  const ProductRelevant({
    super.key,
    required this.categoryId,
  });

  final String categoryId;
  @override
  State<ProductRelevant> createState() => _ProductRelevantState();
}

class _ProductRelevantState extends State<ProductRelevant> {
  bool _isLoading = true;
  List<dynamic> products = [];
  int totalPage = 1;
  int currentPage = 1;
  String errorMessage = '';
  
  final List<Map<String, dynamic>> FE_RELEVANT_PRODUCTS = List.generate(
      4,
      (index) => {
          'id': 'rel_var_id_$index', 
          'categoryId': 'FE_CAT_ID',
          'variantName': 'Relevant Product $index', 
          'variantDescription': 'FE relevant description $index',
          'price': 1000000.0 * (index + 1),
          'averageRating': 4.0 + index * 0.2,
          'images': [ProductImageFE(url: 'https://picsum.photos/id/${500 + index}/600/400')],
      });


  @override
  void initState() {
    super.initState();
    _fetchProductsRelevant();
  }

  Future<void> _fetchProductsRelevant() async {
    setState(() {
      _isLoading = true;
      errorMessage = '';
    });
    await Future.delayed(const Duration(milliseconds: 700)); 

    setState(() {
      products = FE_RELEVANT_PRODUCTS;
      totalPage = 10;
      _isLoading = false;
    });
  }

  Future<void> handleOnPageChanged(int page) async {
    setState(() {
      currentPage = page;
    });
    await _fetchProductsRelevant();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (errorMessage.isNotEmpty && products.isEmpty) {
      return SizedBox(
        height: 350,
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
          itemCount: _isLoading ? 4 : products.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: utils.Responsive.isDesktop(context) ? 4 : 2,
            childAspectRatio: 0.55,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 300,
          ),
          itemBuilder: (context, index) {
            final variant =
                !_isLoading && index < products.length ? products[index] : null;
            return _isLoading
                ? const Skeleton()
                : ProductView(
                    id: variant?['id'] ?? '',
                    categoryId: variant?['categoryId'] ?? '',
                    variantName: variant?['variantName'] ?? '',
                    images: (variant?['images'] as List<ProductImageFE>),
                    price: (variant?['price'] as double),
                    variantDescription: variant?['variantDescription'] ??
                        'No description available',
                    averageRating: variant?['averageRating']?.toStringAsFixed(1) ?? '0.0',
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
            handleOnPageChanged(page);
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
  final String variantName;
  final List<dynamic> images; 
  final double price;
  final String variantDescription;
  final String averageRating;
  final String id;
  final String categoryId;

  const ProductView({
    super.key,
    required this.id,
    required this.variantName,
    required this.images,
    required this.price,
    required this.variantDescription,
    required this.averageRating,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
          print('Navigate to product detail ID: $id');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 150,
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: images.isNotEmpty ? images[0].url : 'default_image_url',
                  placeholder: (context, url) => const SkeletonImage(
                    imageHeight: 140,
                  ),
                  errorWidget: (context, url, error) =>
                      Image.asset('assets/images/image_default_error.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          variantName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          variantDescription,
                          style: TextStyle(
                            fontSize: FontSizes.small,
                            color: Colors.black54,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatMoney(price.toDouble()),
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            fontSize: FontSizes.large,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              averageRating,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}