import 'package:recomart/utils/widget/CustomAppBarMobile.dart';
import 'package:recomart/views/pages/client/review/widgets/item_reviewed_widget.dart';
import 'package:recomart/views/pages/client/review/widgets/text_field_review_widget.dart';
import 'package:flutter/material.dart';
import 'package:recomart/models/product.model.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/config/font.dart';
import 'package:recomart/utils/responsive.dart';
import 'package:feather_icons/feather_icons.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var product = ProductModel(
      id: "1",
      productId: "prod_123",
      variantName: "Macbook Pro 2021",
      variantColor: "Silver",
      variantDescription: "RAM: 16GB, Storage: 512GB SSD",
      price: 13000000,
      discount: 0.1,
      quantity: 100,
      averageRating: 4.5,
      reviewCount: 150,
      images: [
        ProductImage(url: "assets/images/laptop.png", publicId: "public_id_123")
      ],
      isActive: true,
    );
    return MaterialApp(
      title: 'Review App',
      home: ReviewView(product: product),
    );
  }
}

class ReviewView extends StatelessWidget {
  final ProductModel product;
  const ReviewView({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Sử dụng Padding cố định cho mobile, và căn giữa cho desktop
    double horizontalPadding = Responsive.isMobile(context) ? 16.0 : MediaQuery.sizeOf(context).width * 0.1;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBarMobile(title: "Leave Review"),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch, // Dùng stretch để căn chỉnh tốt hơn
            children: [
              const SizedBox(height: 24),
              
              // 1. Sản phẩm đang được đánh giá (Item Reviewed)
              Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ItemReviewedWidget(product: product),
                ),
              ),

              const SizedBox(height: 30),
              
              // 2. Tiêu đề chính
              Center(
                child: Text("How was your experience?",
                    style: TextStyle(
                        fontSize: FontSizes.large * 1.1,
                        color: AppColors.black,
                        fontWeight: FontWeight.w800)),
              ),

              const SizedBox(height: 40),

              // 3. Đánh giá sao (Rating Bar) - Thiết kế công nghệ
              Center(
                child: Column(
                  children: [
                    Text("Your overall rating",
                        style: TextStyle(
                          fontSize: FontSizes.medium,
                          color: AppColors.grey,
                        )),
                    const SizedBox(height: 15),
                    RatingBar.builder(
                      glow: false,
                      initialRating: 3,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 40, // Sao lớn hơn
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        FeatherIcons.star, // Icon ngôi sao hiện đại hơn
                        color: AppColors.primary, // Màu xanh dương chủ đạo
                      ),
                      onRatingUpdate: (rating) {
                        // Logic update rating
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // 4. Viết đánh giá chi tiết
              Text(
                "Write detailed review",
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: FontSizes.medium,
                    color: AppColors.black,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFieldReviewWidget(), // Giả định widget này đã có style hiện đại
              const SizedBox(height: 20),

              // 5. Nút Upload Photo - Thiết kế Outlined (viền xanh)
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: Responsive.isMobile(context) ? 0 : MediaQuery.sizeOf(context).width * 0.1),
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary, width: 2), // Viền xanh dương
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Bo góc hiện đại
                      ),
                    ),
                    onPressed: () {
                      // Logic upload photo
                    },
                    icon: Icon(FeatherIcons.camera, color: AppColors.primary), // Icon camera hiện đại
                    label: const Text(
                      "Upload Photo (Optional)",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // 6. Nút Cancel và Submit
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: Responsive.isMobile(context) ? 0 : MediaQuery.sizeOf(context).width * 0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Nút Cancel
                    Expanded(
                      child: CustomButton(
                          title: "Cancel",
                          onPressed: () {
                            // Logic cancel
                          },
                          backgroundColor: Colors.transparent,
                          textColor: AppColors.primary, // Chữ xanh
                          isOutline: true,
                          borderColor: AppColors.primary.withOpacity(0.5),
                        ),
                    ),
                    const SizedBox(width: 16),
                    // Nút Submit
                    Expanded(
                      child: CustomButton(
                          title: "Submit Review",
                          onPressed: () {
                            // Logic submit
                          },
                          backgroundColor: AppColors.primary,
                          textColor: AppColors.white,
                          isShadowed: true,
                        ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

// CustomButton được thiết kế lại với tùy chọn outline và shadow
class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final bool isOutline;
  final bool isShadowed;
  final Color? borderColor;

  const CustomButton({
    super.key,
    required this.title,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
    this.isOutline = false,
    this.isShadowed = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: isShadowed
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4), // Shadow xanh dương
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            )
          : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Bo góc lớn hơn, hiện đại hơn
            side: isOutline
                ? BorderSide(
                    color: borderColor ?? AppColors.primary,
                    width: 1.5,
                  )
                : BorderSide.none,
          ),
          elevation: isShadowed ? 0 : 2, // Chỉ hiện elevation mặc định khi không có custom shadow
        ),
        child: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: FontSizes.medium,
          ),
        ),
      ),
    );
  }
}