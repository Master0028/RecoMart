import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:recomart/components/custom/skeleton.dart';
import 'package:recomart/components/custom/snackbar.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/helpers/formatMoney.dart';
import 'package:recomart/utils/responsive.dart';
import 'package:recomart/utils/widget/CustomAppBarMobile.dart';
import 'package:recomart/utils/widget/footer.dart';
import 'package:recomart/views/pages/client/cart/widgets/cart_item_widget.dart';
import 'package:recomart/views/pages/client/cart/widgets/promocode_section_widget.dart';
import 'package:recomart/views/pages/client/cart/widgets/remove_cart_widget.dart';
import 'package:recomart/views/pages/client/login/widgets/button.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:recomart/provider/cart_provider.dart';
import 'package:recomart/models/cart.model.dart';

enum ShippingMethod {
  pickupAtStore,
  expressDelivery,
}

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  _CartViewState createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  ShippingMethod _selectedMethod = ShippingMethod.expressDelivery;
  int? _itemToRemove;
  final int _quantityToRemove = 1;

  void _cancelRemoveItem() {
    setState(() {
      _itemToRemove = null;
    });
  }

  void _handleRemoveItem(String productVariantId) {
    showCustomSnackBar(
      context,
      'Xóa sản phẩm $productVariantId khỏi giỏ hàng thành công',
      type: SnackBarType.success,
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchCartData();
  }

  Future<void> _fetchCartData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await Provider.of<CartProvider>(context, listen: false)
          .fetchCartByUserId(user.uid);
    }
  }

  Widget _buildHeaderRow() => Column(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('PRODUCT',
                    style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold)),
              ),
              Expanded(
                  flex: 1,
                  child: Text('QUANTITY',
                      style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold))),
              Expanded(
                  flex: 1,
                  child: Text('TOTAL',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold))),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
    ],
  );

  Widget _buildSummary(List<ProductForCartModel> cartItems) {
    double subtotal = cartItems.fold(
        0, (sum, item) => sum + item.unitPrice * item.quantity);
    double discount = cartItems.fold(
        0, (sum, item) => sum + (item.unitPrice * item.discount));
    double total = subtotal - discount;
    if (total < 0) total = 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Summary',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const Divider(height: 30),
          _buildRowWithLabel(label: 'Subtotal', value: formatMoney(subtotal)),
          _buildRowWithLabel(
              label: 'Discount', value: '-${formatMoney(discount)}'),
          const Divider(height: 30),
          _buildRowWithLabel(
            label: 'Total Payment',
            value: formatMoney(total),
            labelStyle:
            const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            valueStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                print('Proceed to checkout');
              },
              icon: const Icon(FeatherIcons.checkCircle,
                  color: Colors.white, size: 20),
              label: const Text(
                'Proceed to Checkout',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 8,
                shadowColor: AppColors.primary.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowWithLabel({
    required String label,
    Widget? child,
    String? value,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
    Color valueColor = Colors.black,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
              labelStyle ?? const TextStyle(fontSize: 14, color: Colors.black87)),
          child ??
              Text(value ?? '',
                  style: valueStyle ??
                      TextStyle(
                          fontSize: 14,
                          color: valueColor,
                          fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final isMobile = Responsive.isMobile(context);

    if (FirebaseAuth.instance.currentUser == null) {
      return Scaffold(
        appBar: CustomAppBarMobile(title: 'My Cart', isBack: true),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(FeatherIcons.userX, size: 80, color: AppColors.primary),
              const SizedBox(height: 10),
              const Text('Vui lòng đăng nhập để xem giỏ hàng',
                  style: TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              MyButton(
                text: 'Đăng nhập ngay',
                onTap: (_) => print("Đi tới trang đăng nhập"),
              )
            ],
          ),
        ),
      );
    }

    if (cartProvider.isLoading) {
      return Scaffold(
        appBar: CustomAppBarMobile(title: 'My Cart', isBack: true),
        body: ListView.builder(
          itemCount: 5,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) => const Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: SkeletonHorizontalProduct(),
          ),
        ),
      );
    }

    final cart = cartProvider.cart;
    final cartItems = cart?.items ?? [];

    if (cart == null || cartItems.isEmpty) {
      return Scaffold(
        appBar: CustomAppBarMobile(title: 'My Cart', isBack: true),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/NoItem.png', width: 250),
              const SizedBox(height: 16),
              const Text('Your cart is empty!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: <Widget>[
        Scaffold(
          backgroundColor: isMobile ? Colors.grey.shade100 : Colors.white,
          appBar: CustomAppBarMobile(
            title: 'My Cart (${cartItems.length})',
            isBack: true,
          ),
          body: ListView(
            padding: isMobile
                ? const EdgeInsets.only(bottom: 100)
                : const EdgeInsets.symmetric(horizontal: 64, vertical: 30),
            children: [
              if (!isMobile) _buildHeaderRow(),
              SlidableAutoCloseBehavior(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) =>
                  const SizedBox(height: 15),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final itemCart = cartItems[index];
                    return Slidable(
                      key: ValueKey(itemCart.productId),
                      closeOnScroll: true,
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          CustomSlidableAction(
                            borderRadius: BorderRadius.circular(16),
                            onPressed: (_) {
                              _handleRemoveItem(itemCart.productId ?? '');
                            },
                            backgroundColor: Colors.transparent,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(FeatherIcons.trash2,
                                    color: AppColors.red, size: 28),
                                Text('Remove',
                                    style: TextStyle(
                                        color: AppColors.red, fontSize: 14)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: CartItemWidget(
                          itemCart: itemCart,
                          onQuantityChanged: (quantity) {
                            setState(() {});
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              PromocodeSectionWidget(cartItems: cartItems),
              const SizedBox(height: 30),
              _buildSummary(cartItems),
              if (!isMobile) const SizedBox(height: 40),
              if (!isMobile) const FooterWidget(),
            ],
          ),
          bottomNavigationBar: Responsive.isMobile(context) &&
              cartItems.isNotEmpty
              ? Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: _buildSummary(cartItems),
          )
              : null,
        ),
        if (_itemToRemove != null) ...[
          Positioned.fill(child: Container(color: Colors.black54)),
          RemoveCartWidget(
            cartItems: cartItems,
            itemToRemove: _itemToRemove,
            cancelRemoveItem: _cancelRemoveItem,
            quantityToRemove: _quantityToRemove,
            removeItem: () {
              print('Confirmed removal of item $_itemToRemove');
            },
          ),
        ],
      ],
    );
  }
}
