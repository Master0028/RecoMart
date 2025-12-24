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

  /// Handles removing the item from the cart
  void _handleRemoveItem(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => isProcessing = true);
    try {
      await Provider.of<CartProvider>(context, listen: false)
          .removeItem(user.uid, productId);

      if (mounted) {
        showCustomSnackBar(
          context,
          'Item removed from cart!',
          type: SnackBarType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(
          context,
          'Error removing item: $e',
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // PRODUCT COLUMN
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: widget.itemCart.image ?? '',
                          fit: BoxFit.cover,
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.itemCart.productName ?? 'Product',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              formatMoney(
                                widget.itemCart.unitPrice -
                                    (widget.itemCart.unitPrice *
                                        widget.itemCart.discount /
                                        100),
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

                // QUANTITY COLUMN
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
                            // FIXED: Added required named parameters
                            await Provider.of<CartProvider>(context, listen: false)
                                .updateItemQuantity(
                              userId: user.uid,
                              productId: widget.itemCart.productId ?? '',
                              newQuantity: newQuantity,
                            );

                            if (mounted) {
                              showCustomSnackBar(
                                context,
                                'Quantity updated!',
                                type: SnackBarType.success,
                              );
                              widget.onQuantityChanged?.call(newQuantity);
                            }
                          } catch (e) {
                            if (mounted) {
                              showCustomSnackBar(
                                context,
                                'Error updating quantity: $e',
                                type: SnackBarType.error,
                              );
                            }
                          } finally {
                            if (mounted) setState(() => isProcessing = false);
                          }
                        },
                        maxQuantity: widget.maxQuantity,
                        isProcessing: isProcessing,
                        onChangeProgressing: (value) {
                          setState(() => isProcessing = value);
                        },
                      ),
                    ],
                  ),
                ),

                // TOTAL PRICE & DELETE (Desktop/Web)
                if (!Responsive.isMobile(context)) ...[
                  Expanded(
                    flex: 1,
                    child: Text(
                      formatMoney(
                        (widget.itemCart.unitPrice -
                                (widget.itemCart.unitPrice *
                                    widget.itemCart.discount /
                                    100)) *
                            widget.itemCart.quantity,
                      ),
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        _handleRemoveItem(widget.itemCart.productId ?? ''),
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Processing Overlay
        if (isProcessing)
          Positioned.fill(
            child: AbsorbPointer(
              child: Container(
                color: Colors.white.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
            ),
          ),
      ],
    );
  }
}