import 'package:cached_network_image/cached_network_image.dart';
import 'package:recomart/components/custom/bottom_navigation_bar.dart';
import 'package:recomart/components/custom/pagination.dart';
import 'package:recomart/components/custom/skeleton.dart';
import 'package:recomart/components/custom/snackbar.dart';
import 'package:recomart/components/ui/slider_product.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/config/font.dart';
import 'package:recomart/helpers/formatMoney.dart';
import 'package:recomart/models/product.model.dart';
import 'package:recomart/models/review.model.dart';
import 'package:recomart/provider/cart_provider.dart';
import 'package:recomart/services/product.service.dart';
import 'package:recomart/services/review.service.dart';
import 'package:recomart/services/socket_io_client.dart';
import 'package:recomart/utils/responsive.dart';
import 'package:recomart/views/pages/client/home/widgets/appBar_widget.dart';
import 'package:recomart/views/pages/client/product/widgets/description_product.dart';
import 'package:recomart/views/pages/client/product/widgets/product_comment.dart';
import 'package:recomart/views/pages/client/product/widgets/product_review_section.dart';
import 'package:recomart/views/pages/client/product/widgets/quantity.dart';
import 'package:recomart/views/pages/client/product/widgets/title_product.dart';
import 'package:recomart/views/pages/client/product/widgets/version_product.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductDetailsView extends StatefulWidget {
  const ProductDetailsView(
      {super.key, required this.productId, required this.categoryId});
  final String productId;
  final String categoryId;

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<ProductDetailsView> {
  late ProductModel product;
  List<ProductModel> relatedProductsVariant = [];

  List<ReviewModel> reviews = [];
  List<ReviewModel> comments = [];
  int currentPage = 0;
  int totalPages = 0;
  bool isLoadingReview = false;
  bool isLoadingComment = false;

  double averageRating = 0.0;
  int reviewCount = 0;

  List<String> images = ['https://placehold.co/600x400.png'];
  int quantity = 1;
  bool isLoading = false;

  final SocketService socketService = SocketService();
  ProductService productService = ProductService();
  ReviewService reviewService = ReviewService();

  Future<void> fetchProductDetails() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response =
          await productService.getProductVariantsById(widget.productId);
      final newProduct = ProductModel.fromJson(response['productVariant']);
      final newRelated = (response['relatedVariants'] as List)
          .map((item) => ProductModel.fromJson(item))
          .toList();

      setState(() {
        product = newProduct;
        relatedProductsVariant = [newProduct, ...newRelated];
        images = newProduct.images.map((image) => image.url).toList();
      });
    } catch (e) {
      // Handle any errors that occur during the fetch
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void handleSelectVariant(String variantId) async {
    final newProduct =
        relatedProductsVariant.firstWhere((variant) => variant.id == variantId);

    setState(() {
      product = newProduct;
      images = newProduct.images.map((image) => image.url).toList();
    });

    // Ngắt kết nối socket hiện tại (nếu cần), rồi kết nối lại
    socketService.disconnect();
    await socketService.connect(productVariantId: newProduct.id);

    // Đăng ký lại lắng nghe review mới
    socketService.onNewReview((data) {
      final newReview = ReviewModel.fromJson(data);
      if (newReview.rating != 0) {
        setState(() {
          reviews.insert(0, newReview);
          reviewCount += 1;

          if (reviewCount == 1) {
            averageRating = newReview.rating!.toDouble();
          } else {
            averageRating =
                ((averageRating * (reviewCount - 1)) + newReview.rating!) /
                    reviewCount;
          }
        });
      } else {
        setState(() {
          comments.insert(0, newReview);
        });
      }
    });

    await fetchReviewsRating();
    await fetchComments();
  }

  Future<void> fetchReviewsRating({int page = 1}) async {
    setState(() {
      isLoadingReview = true;
      reviews.clear();
    });
    try {
      final res = await reviewService.getAllReviews(
        productVariantId: product.id,
        page: page,
        limit: 200,
      );
      //Only get reviews with rating
      final filterReviewsRating = res['data']
          .where((review) => review.userId != null && review.rating != 0)
          .toList();
      if (res['data'].isNotEmpty) {
        setState(() {
          reviews.addAll(
            filterReviewsRating,
          );
          totalPages = res['totalPage'];
          currentPage = res['page'];
          averageRating = (res['average_rating'] ?? 0).toDouble();
          reviewCount = res['reviews_with_rating'];
        });
      } else {
        setState(() {
          averageRating = 0;
          reviewCount = 0;
        });
      }
    } catch (e) {
      print('Error fetching comments: $e');
    }

    setState(() {
      isLoadingReview = false;
    });
  }

  Future<void> fetchComments({int page = 1}) async {
    setState(() {
      isLoadingComment = true;
      comments.clear();
    });
    try {
      final res = await reviewService.getAllReviews(
        productVariantId: product.id,
        page: page,
        limit: 200,
      );
      //only get comments without rating
      final filterReview =
          res['data'].where((review) => review.rating == 0).toList();

      if (res['data'].isNotEmpty) {
        setState(() {
          comments.addAll(
            filterReview,
          );
          totalPages = res['totalPage'];
          currentPage = res['page'];
        });
      }
    } catch (e) {
      print('Error fetching comments: $e');
    }

    setState(() {
      isLoadingComment = false;
    });
  }

  Future<void> _initSocketAndLoadData() async {
    await socketService.connect(productVariantId: product.id);
    socketService.onNewReview((data) async {
      final newReview = ReviewModel.fromJson(data);
      // Chỉ thêm nếu có rating hợp lệ
      if (newReview.rating != 0) {
        setState(() {
          reviews.insert(0, newReview);
          reviewCount = reviews.length;

          if (reviewCount == 1) {
            averageRating = newReview.rating!.toDouble();
          } else {
            averageRating =
                ((averageRating * (reviewCount - 1)) + newReview.rating!) /
                    reviewCount;
          }
        });
      } else {
        setState(() {
          comments.insert(0, newReview);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    product = ProductModel(
      id: widget.productId,
      productId: '',
      variantName: '',
      variantColor: '',
      variantDescription: '',
      price: 0,
      discount: 0,
      quantity: 0,
      averageRating: 0,
      reviewCount: 0,
      images: [
        ProductImage(url: 'https://placehold.co/600x400.png', publicId: '')
      ],
      isActive: true,
    );
    fetchProductDetails().then((_) {
      _initSocketAndLoadData(); // Chỉ gọi sau khi đã có product.id chính xác
    });
    fetchReviewsRating();
    fetchComments();
  }

  @override
  void dispose() {
    super.dispose();
    socketService.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    double isWrap = MediaQuery.of(context).size.width;
    bool isMobile = Responsive.isMobile(context);
    bool isDesktop = Responsive.isDesktop(context);
    bool isTablet = Responsive.isTablet(context);

    //get data from route arguments
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: !isMobile ? AppBarHomeCustom() : null,
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
                    constraints: BoxConstraints(
                      minWidth: 300,
                      minHeight: 300,
                    ),
                    child: Container(
                        padding: !isMobile
                            ? EdgeInsets.only(
                                top: 16,
                                left: 64,
                                right: 64,
                              )
                            : EdgeInsets.only(
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
                    constraints: BoxConstraints(
                      minWidth: 300,
                    ),
                    child: Container(
                      padding: !isMobile
                          ? EdgeInsets.only(
                              top: 16,
                              left: 64,
                              right: 64,
                            )
                          : EdgeInsets.only(
                              left: 16,
                              right: 16,
                            ),
                      width: isWrap < 1200 ? double.infinity : isWrap * 0.43,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // Dùng Column với spacing 
                        children: [
                          TitleProduct(
                            title: product.variantName,
                            price: product.price,
                            discount: product.discount,
                          ),
                          const SizedBox(height: 20),
                          VersionProduct(
                            relatedProductsVariant: relatedProductsVariant,
                            handleSelectVariant: handleSelectVariant,
                            isSelected: product.id,
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
                                // Nút Add to cart - Màu Xanh dương Chính
                                Expanded(
                                  child: Container(
                                    height: 50,
                                    margin: const EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12), // Bo góc lớn hơn
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        final provider =
                                            Provider.of<CartProvider>(context,
                                                listen: false);
                                        provider.handleAddToCart(
                                          product.id,
                                          quantity,
                                        );
                                        showCustomSnackBar(
                                          context,
                                          'You have added to cart',
                                          type: SnackBarType.success,
                                        );
                                      },
                                      icon: const Icon(FeatherIcons.shoppingCart, color: Colors.white, size: 20),
                                      label: const Text(
                                        'Add to cart',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold, // Chữ in đậm
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                    ),
                                  ),
                                ),
                                // Nút Buy now - Màu Xanh dương Outline
                                Expanded(
                                  child: Container(
                                    height: 50,
                                    margin: const EdgeInsets.only(left: 10),
                                    child: OutlinedButton( // Dùng OutlinedButton cho style hiện đại
                                      onPressed: () {
                                        // Logic Buy now
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.primary,
                                        side: BorderSide(
                                            color: AppColors.primary,
                                            width: 2), // Viền dày hơn
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
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
                        ? EdgeInsets.only(
                            top: 16,
                            left: 64,
                            right: 64,
                          )
                        : EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 16,
                          ),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // Dùng Column với spacing 
                      children: [
                        DescriptionProduct(
                          description: product.variantDescription,
                        ),
                        const SizedBox(height: 20),
                        ProductReviewSection(
                          productId: product.id,
                          productName: product.variantName,
                          averageRating: averageRating,
                          reviewCount: reviewCount,
                          images: images,
                          socketService: socketService,
                          reviews: reviews,
                          isLoading: isLoadingReview,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Related Products',
                          style: TextStyle(
                            fontSize: 20, // Tăng kích thước font
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: !isMobile
                        ? EdgeInsets.only(
                            top: 16,
                            left: 64,
                            right: 64,
                          )
                        : EdgeInsets.only(
                            left: 16,
                            right: 16,
                          ),
                    child: ProductRelevant(
                      categoryId: widget.categoryId,
                    ),
                  ),
                  Padding(
                    padding: !isMobile
                        ? EdgeInsets.only(
                            top: 16,
                            left: 64,
                            right: 64,
                          )
                        : EdgeInsets.only(
                            left: 16,
                            right: 16,
                          ),
                    child: ProductComment(
                      socketService: socketService,
                      productId: product.id,
                      comments: comments,
                      isLoading: isLoadingComment,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            if (isTablet)
              Positioned(
                top: 0,
                left: 64,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BottomNavigationBarCustom(),
                          ),
                          (Route<dynamic> route) => false,
                        );
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
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BottomNavigationBarCustom(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            // isMobile ? DraggableScrollCustom() : SizedBox(),
          ],
        ),
      ),
      bottomNavigationBar: isMobile
          ? Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1), // Shadow hiện đại hơn
                    blurRadius: 15, // Blur rộng hơn
                    offset: const Offset(0, -5),
                  ),
                ],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20), // Bo góc cho thanh bottom bar
                  topRight: Radius.circular(20),
                ),
              ),
              width: double.infinity,
              height: 70, // Chiều cao tối ưu hơn
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Nút Chat - Icon màu xanh dương
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                      ),
                      margin: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        onPressed: () {
                          // Logic Chat
                        },
                        icon: Icon(
                          FeatherIcons.messageCircle,
                          color: AppColors.primary,
                          size: 25,
                        ),
                      ),
                    ),
                  ),
                  // Nút Cart - Icon màu xanh dương
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, 'cart');
                        },
                        icon: Icon(
                          FeatherIcons.shoppingCart,
                          color: AppColors.primary,
                          size: 25,
                        ),
                      ),
                    ),
                  ),
                  // Nút Add to cart - Màu Xanh dương Chính
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: double.infinity,
                      margin: const EdgeInsets.only(left: 8),
                      child: ElevatedButton(
                        onPressed: () {
                          final provider =
                              Provider.of<CartProvider>(context, listen: false);
                          provider.handleAddToCart(
                            product.id,
                            quantity,
                          );
                          showCustomSnackBar(
                            context,
                            'You have added to cart',
                            type: SnackBarType.success,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), // Bo góc
                          ),
                          elevation: 5, // Thêm elevation để nổi bật
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
          color: AppColors.primary, // Icon màu xanh dương
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
  List<ProductModel> products = [];
  int totalPage = 0;
  int currentPage = 1;
  String errorMessage = '';
  final ProductService productSerice = ProductService();

  @override
  void initState() {
    super.initState();
    _fetchProductsRelevant();
  }

  Future<void> _fetchProductsRelevant() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final getProductVariants = await productSerice
          .searchProductVariants(categoryIds: [widget.categoryId]);

      setState(() {
        products = getProductVariants['data'];
        totalPage = getProductVariants['totalPages'];
        currentPage = getProductVariants['page'];
      });
    } catch (e) {
      print('Error fetching products: $e');
      showCustomSnackBar(
        context,
        'Please check your internet connection',
      );
      setState(() {
        errorMessage = 'Please check your internet connection';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                'assets/images/No_Internet.png', // Đường dẫn ảnh bạn muốn hiển thị
                width: 250, // Chiều rộng bạn muốn
                height: 250, // Chiều cao bạn muốn
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
          itemCount: _isLoading ? 4 : products.length, // Giảm xuống 4 cho mobile/tablet
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: Responsive.isDesktop(context) ? 4 : 2,
            childAspectRatio: 0.55,
            crossAxisSpacing: 16, // Giảm spacing một chút
            mainAxisSpacing: 16, // Giảm spacing một chút
            mainAxisExtent: 300, // Chiều cao hợp lý hơn cho card sản phẩm
          ),
          itemBuilder: (context, index) {
            final variant =
                !_isLoading && index < products.length ? products[index] : null;
            return _isLoading
                ? const Skeleton()
                : ProductView(
                    id: variant?.id ?? '',
                    categoryId: variant?.categoryId ?? '',
                    variantName: variant?.variantName ?? '',
                    images: (variant?.images as List<ProductImage>),
                    price: (variant?.price as double),
                    variantDescription: variant?.variantDescription ??
                        'No description available',
                    averageRating: variant?.averageRating.toString() ?? '0.0',
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
  final List<ProductImage> images;
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
      onTap: () =>
          Navigator.pushNamed(context, '/product-details/$id', arguments: {
        'categoryId': categoryId,
      }),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16), // Bo góc lớn hơn
          border: Border.all(color: AppColors.primary.withOpacity(0.1)), // Viền nhẹ
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05), // Shadow màu xanh nhẹ
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Khu vực ảnh sản phẩm
            Container(
              width: double.infinity,
              height: 150, // Chiều cao ảnh cố định
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12)), // Bo góc ảnh
                child: CachedNetworkImage(
                  imageUrl: images[0].url,
                  placeholder: (context, url) => const SkeletonImage(
                    imageHeight: 140,
                  ),
                  errorWidget: (context, url, error) =>
                      Image.asset('assets/images/image_default_error.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Khu vực thông tin sản phẩm
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
                            fontSize: 16, // Font lớn hơn
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
                            fontWeight: FontWeight.w900, // Rất đậm
                            color: AppColors.primary, // Màu xanh dương nổi bật
                            fontSize: FontSizes.large, // Font to hơn
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              double.parse(averageRating).toStringAsFixed(1),
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