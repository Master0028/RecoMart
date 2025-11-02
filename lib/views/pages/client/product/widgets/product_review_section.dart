import 'package:flutter/material.dart';
import 'package:recomart/components/custom/pagination.dart';
import 'package:recomart/components/custom/skeleton.dart';
import 'package:recomart/components/custom/snackbar.dart';
import 'package:recomart/helpers/formatMoney.dart';
import 'package:recomart/config/color.dart';

final List<dynamic> FE_REVIEWS_DATA = [
  {
    'content': 'Great product, highly recommend! (FE Review 1)',
    'rating': 5.0,
    'user': {'name': 'FE User 1'},
    'createdAt': DateTime.now().subtract(const Duration(days: 1)).toString(),
  },
  {
    'content': 'Decent value for the price. (FE Review 2)',
    'rating': 4.0,
    'user': {'name': 'FE User 2'},
    'createdAt': DateTime.now().subtract(const Duration(hours: 5)).toString(),
  },
  {
    'content': 'It was okay, nothing special. (FE Review 3)',
    'rating': 3.0,
    'user': {'name': 'FE User 3'},
    'createdAt': DateTime.now().subtract(const Duration(days: 3)).toString(),
  },
];

String formatDate(String date) {
    return '2 days ago';
}

class ProductReviewSection extends StatefulWidget {
  const ProductReviewSection({
    super.key,
    required this.productId,
    required this.productName,
    required this.averageRating,
    required this.reviewCount,
    required this.images,
    required this.socketService,
    required this.reviews,
    this.isLoading = false,
  });

  final String productId;
  final String productName;
  final double averageRating;
  final int reviewCount;
  final List<String> images;
  final dynamic socketService;
  final List<dynamic> reviews;
  final bool isLoading;

  @override
  State<ProductReviewSection> createState() => _ProductReviewSectionState();
}

class _ProductReviewSectionState extends State<ProductReviewSection> {
  final TextEditingController _commentController = TextEditingController();
  int currentPage = 1;
  int totalPage = 1;
  int limit = 10;
  bool _showAll = false;

  void _addReviewRating(int rating, String content) {
    try {
      showCustomSnackBar(
        context,
        'Review sent successfully! (FE Action)',
        type: SnackBarType.success,
      );

      setState(() {
        _commentController.clear();
      });
    } catch (e) {
      showCustomSnackBar(context, 'Failed to add comment. Please try again.');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final allReviews = FE_REVIEWS_DATA; 
    
    final totalPage = allReviews.length > 10 ? (allReviews.length / 10).ceil() : 1;

    final reviewPagination =
        allReviews.skip((currentPage - 1) * limit).take(limit).toList();

    final reviewsToShow =
        _showAll ? reviewPagination : reviewPagination.take(2).toList();

    const String userId = 'FE_LOGGED_IN_USER'; 

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reviews ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < widget.averageRating
                          ? Icons.star
                          : index < widget.averageRating + 0.5
                              ? Icons.star_half
                              : Icons.star_border,
                      size: 18,
                      color: AppColors.yellow,
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.reviewCount} review${widget.reviewCount == 1 ? '' : 's'} (FE Count)',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
            Column(
              children: [
                RatingReviewBar(
                  rating: 5,
                  count: reviewPagination.where((review) => review['rating'] == 5.0).length,
                ),
                RatingReviewBar(
                  rating: 4,
                  count: reviewPagination.where((review) => review['rating'] == 4.0).length,
                ),
                RatingReviewBar(
                  rating: 3,
                  count: reviewPagination.where((review) => review['rating'] == 3.0).length,
                ),
                RatingReviewBar(
                  rating: 2,
                  count: reviewPagination.where((review) => review['rating'] == 2.0).length,
                ),
                RatingReviewBar(
                  rating: 1,
                  count: reviewPagination.where((review) => review['rating'] == 1.0).length,
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 10),

        widget.isLoading
            ? ListView.separated( 
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) => const SkeletonHorizontalProduct(),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reviewsToShow.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final review = reviewsToShow[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.grey.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tên + thời gian
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              review['user']?['name'] ?? 'Anonymous',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              formatDate(review['createdAt'].toString()),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Rating
                        Row(
                          children: List.generate(5, (i) {
                            return Icon(
                              i < (review['rating'] ?? 0.0)
                                  ? Icons.star
                                  : i < ((review['rating'] ?? 0.0) + 0.5)
                                      ? Icons.star_half
                                      : Icons.star_border,
                              size: 18,
                              color: AppColors.yellow,
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                        // Nội dung
                        Text(
                          review['content'] ?? 'Review content missing',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  );
                },
              ),
        
        if (_showAll)
          Column(
            children: [
              const SizedBox(height: 20),
              PaginationWidget(
                currentPage: currentPage,
                totalPages: totalPage,
                onPageChanged: (page) {
                  setState(() {
                    currentPage = page;
                  });
                },
              ),
            ],
          ),
        const SizedBox(height: 20),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (reviewPagination.length > 2)
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _showAll = !_showAll;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: Text(
                      _showAll
                          ? 'Collapse'
                          : 'View ${widget.reviewCount} reviews',
                      style: const TextStyle(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
            if (userId.isNotEmpty)
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      _openReviewDialog(
                        context,
                        images: widget.images,
                        productName: widget.productName,
                        handleReviewRating: (rating, content) {
                          _addReviewRating(rating, content);
                          Navigator.pop(context);
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.primary,
                      ),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Write a review',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        )
      ],
    );
  }
}

class RatingReviewBar extends StatelessWidget {
  const RatingReviewBar({
    super.key,
    required this.rating,
    required this.count,
  });

  final int rating;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 10,
          child: Text(
            rating.toString(),
            style: const TextStyle(
              fontSize: 14,
              color: Color.fromARGB(255, 179, 179, 179),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Icon(
          Icons.star,
          size: 18,
          color: AppColors.yellow,
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            value: count / 5,
            backgroundColor: Colors.grey[300],
            color: AppColors.yellow,
            minHeight: 12,
            borderRadius: BorderRadius.circular(8),
          ),
        )
      ],
    );
  }
}

void _openReviewDialog(
  BuildContext context, {
  required List<String> images,
  required String productName,
  required Function(int rating, String content) handleReviewRating,
}) {
  int selectedRating = 0;
  bool showForm = false;
  TextEditingController commentController = TextEditingController();
  bool recommend = false;
  String errorMessage = '';

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        insetAnimationCurve: Curves.easeInOut,
        insetAnimationDuration: const Duration(milliseconds: 1000),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 660),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: StatefulBuilder(
              builder: (context, setState) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Review Product',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Image.network(
                        images.isNotEmpty ? images[0] : 'placeholder_image_url',
                        height: 100,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        productName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(5, (index) {
                          return Column(
                            children: [
                              IconButton(
                                icon: Icon(
                                  index < selectedRating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: AppColors.yellow,
                                  size: 32,
                                ),
                                onPressed: () {
                                  setState(() {
                                    selectedRating = index + 1;
                                    showForm = selectedRating > 0;
                                  });
                                },
                              ),
                              const SizedBox(height: 4),
                              Text(
                                [
                                  'Terrible',
                                  'Poor',
                                  'Average',
                                  'Good',
                                  'Excelent'
                                ][index],
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                      if (showForm) ...[
                        TextField(
                          controller: commentController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Write your review here',
                            border: const OutlineInputBorder(),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.grey,
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.primary,
                              ),
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              errorMessage,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Checkbox(
                              value: recommend,
                              onChanged: (val) {
                                setState(() {
                                  recommend = val ?? false;
                                });
                              },
                              checkColor: Colors.white,
                              activeColor: AppColors.primary,
                            ),
                            const Expanded(
                              child: Text(
                                'I will recommend this product to my friends',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            if (commentController.text.isEmpty) {
                              setState(() {
                                errorMessage = 'Please enter your review';
                              });
                              return;
                            }
                            handleReviewRating(
                              selectedRating,
                              commentController.text,
                            );
                          },
                          child: const Text(
                            'Gửi đánh giá',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ]
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
    },
  );
}