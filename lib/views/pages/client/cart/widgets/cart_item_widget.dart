import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:recomart/components/custom/skeleton.dart';
import 'package:recomart/components/custom/snackbar.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/helpers/formatMoney.dart';
import 'package:recomart/utils/responsive.dart';
import 'package:recomart/views/pages/client/cart/widgets/quantity_widget.dart';

import '../../../../../provider/cart_provider.dart';

class CartItemWidget extends StatefulWidget {
  final bool isRemove;
  final dynamic itemCart; 
  final ValueChanged<int>? onQuantityChanged;
  final int? maxQuantity;

  const CartItemWidget({
    super.key,
    required this.itemCart, 
    this.onQuantityChanged,
    this.isRemove = false,
    this.maxQuantity,
  });

  @override
  State<CartItemWidget> createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  bool isProcessing = false;

  void _handleRemoveItem(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await Provider.of<CartProvider>(context, listen: false)
          .removeItemFromCart(user.uid, productId);

      showCustomSnackBar(
        context,
        '🗑️ Đã xóa sản phẩm khỏi giỏ hàng!',
        type: SnackBarType.success,
      );
    } catch (e) {
      showCustomSnackBar(
        context,
        'Lỗi khi xóa sản phẩm: $e',
        type: SnackBarType.error,
      );
    }
  }


  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // PRODUCT
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      // Hiển thị ảnh
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: CachedNetworkImage(
                          imageUrl: widget.itemCart.image ?? 'default_url',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 350, 
                          placeholder: (context, url) => const SkeletonImage(
                            imageHeight: 80,
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/images/image_default_error.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Tên và giá
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 200,
                              child: Text(
                                widget.itemCart.productName ?? 'Product Name',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.black,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              // Logic tính giá FE
                              formatMoney(
                                widget.itemCart.unitPrice * (1 - widget.itemCart.discount),
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // QUANTITY
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: Responsive.isMobile(context)
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      QuantitySelector(
                        productId: widget.itemCart.productId ?? '0',
                        initialQuantity: widget.itemCart.quantity ?? 1,
                        onQuantityChanged: (newQuantity) async {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) return;

                          setState(() => isProcessing = true);
                          try {
                            await Provider.of<CartProvider>(context, listen: false)
                                .updateItemQuantity(user.uid, widget.itemCart.productId ?? '', newQuantity);

                            showCustomSnackBar(
                              context,
                              '✅ Đã cập nhật số lượng!',
                              type: SnackBarType.success,
                            );

                            widget.onQuantityChanged?.call(newQuantity);
                          } catch (e) {
                            showCustomSnackBar(
                              context,
                              '⚠️ Lỗi khi cập nhật: $e',
                              type: SnackBarType.error,
                            );
                          } finally {
                            setState(() => isProcessing = false);
                          }
                        },
                        maxQuantity: widget.maxQuantity,
                        isProcessing: isProcessing,
                        onChangeProgressing: (value) {
                          setState(() {
                            isProcessing = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // TOTAL
                if (!Responsive.isMobile(context))
                  Expanded(
                    flex: 1,
                    child: Text(
                      formatMoney(
                        widget.itemCart.unitPrice * widget.itemCart.quantity,
                      ),
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                // REMOVE
                if (!Responsive.isMobile(context))
                  IconButton(
                    onPressed: () => _handleRemoveItem(widget.itemCart.productId ?? ''),
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),

        if (isProcessing)
          Positioned.fill(
            child: AbsorbPointer(
              absorbing: true,
              child: Container(
                color: Colors.black.withAlpha(50),
                alignment: Alignment.center,
                child: const CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}