import 'package:flutter/material.dart';
import 'package:recomart/utils/widget/CustomAppBarMobile.dart';
import 'package:recomart/views/pages/client/review/widgets/item_reviewed_widget.dart';
import 'package:recomart/views/pages/client/review/widgets/text_field_review_widget.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/utils/responsive.dart';
import 'package:feather_icons/feather_icons.dart';

class ProductImageFE {
  final String url;
  ProductImageFE({required this.url});
}

final Map<String, dynamic> FE_PRODUCT_STUB = {
  'variantName': "FE Product Name",
  'variantDescription': "FE Description",
  'price': 13000000.0,
  'discount': 0.1,
  'images': [ProductImageFE(url: "assets/images/laptop.png")]
};

class ReviewView extends StatelessWidget {
  final dynamic product; 
  const ReviewView({super.key, required this.product});

  void _handleSubmitReview() {
    print("Submit Review Clicked");
  }
  
  void _handleUploadPhoto() {
    print("Upload Photo Clicked");
  }
  
  void _handleCancel() {
    print("Cancel Clicked");
  }
  
  void _handleRatingUpdate(double rating) {
      print("Rating updated to: $rating");
  }


  @override
  Widget build(BuildContext context) {
    double horizontalPadding = Responsive.isMobile(context) ? 16.0 : MediaQuery.sizeOf(context).width * 0.1;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBarMobile(title: "Leave Review"),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              
              Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ItemReviewedWidget(product: product), 
                ),
              ),

              const SizedBox(height: 30),
              
              const Center(
                child: Text("How was your experience?",
                    style: TextStyle(
                        fontSize: 20.0,
                        color: AppColors.black,
                        fontWeight: FontWeight.w800)),
              ),

              const SizedBox(height: 40),

              Center(
                child: Column(
                  children: [
                    const Text("Your overall rating",
                        style: TextStyle(
                          fontSize: 14.0, 
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
                      itemSize: 40,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(
                        FeatherIcons.star, 
                        color: AppColors.primary,
                      ),
                      onRatingUpdate: _handleRatingUpdate,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              const Text(
                "Write detailed review",
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 16.0,
                    color: AppColors.black,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFieldReviewWidget(),
              const SizedBox(height: 20),

              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: Responsive.isMobile(context) ? 0 : MediaQuery.sizeOf(context).width * 0.1),
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _handleUploadPhoto, // Logic FE
                    icon: const Icon(FeatherIcons.camera, color: AppColors.primary),
                    label: const Text(
                      "Upload Photo (Optional)",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: Responsive.isMobile(context) ? 0 : MediaQuery.sizeOf(context).width * 0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CustomButton(
                          title: "Cancel",
                          onPressed: _handleCancel,
                          backgroundColor: Colors.transparent,
                          textColor: AppColors.primary,
                          isOutline: true,
                          borderColor: AppColors.primary.withOpacity(0.5),
                        ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                          title: "Submit Review",
                          onPressed: _handleSubmitReview,
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
    const double fontSizeMedium = 16.0; 
    
    return Container(
      height: 50,
      decoration: isShadowed
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4), 
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
            borderRadius: BorderRadius.circular(12),
            side: isOutline
                ? BorderSide(
                    color: borderColor ?? AppColors.primary,
                    width: 1.5,
                  )
                : BorderSide.none,
          ),
          elevation: isShadowed ? 0 : 2,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: fontSizeMedium,
          ),
        ),
      ),
    );
  }
}