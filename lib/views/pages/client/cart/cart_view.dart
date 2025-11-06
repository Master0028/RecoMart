import 'package:flutter/material.dart';
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

class ProductImageFE {
  final String url;
  ProductImageFE({required this.url});
}

class CartItemModelFE {
  final String productVariantId;
  final String productVariantName;
  final double unitPrice;
  final double discount;
  final int quantity;
  final ProductImageFE images;
  CartItemModelFE({
    required this.productVariantId,
    required this.productVariantName,
    required this.unitPrice,
    required this.discount,
    required this.quantity,
    required this.images,
  });

  factory CartItemModelFE.fromMap(Map<String, dynamic> map) {
    return CartItemModelFE(
      productVariantId: map['productVariantId'] as String,
      productVariantName: map['productVariantName'] as String,
      unitPrice: map['unitPrice'] as double,
      discount: map['discount'] as double,
      quantity: map['quantity'] as int,
      images: ProductImageFE(url: map['images']['url'] as String),
    );
  }
}

final List<dynamic> FE_CART_DATA_RAW = [
  {
    'productVariantId': '1',
    'productVariantName': 'Laptop X1 Carbon (Tên sản phẩm rất dài để test tràn)',
    'unitPrice': 25000000.0,
    'discount': 0.1,
    'quantity': 1,
    'images': {'url': 'https://placehold.co/400x400.png'}
  },
  {
    'productVariantId': '2',
    'productVariantName': 'Mouse Logitech',
    'unitPrice': 800000.0,
    'discount': 0.0,
    'quantity': 2,
    'images': {'url': 'https://placehold.co/400x400.png'}
  },
];

final List<CartItemModelFE> FE_CART_ITEMS =
    FE_CART_DATA_RAW.map((data) => CartItemModelFE.fromMap(data)).toList();
const int FE_CART_ITEM_COUNT = 2;

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
      'Delete product $productVariantId from cart successfully',
      type: SnackBarType.success,
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'PRODUCT',
              style: TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              'QUANTITY',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              'TOTAL',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingOptions() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Delivery Mode',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          _buildRadioTile(
            value: ShippingMethod.pickupAtStore,
            title: Row(
              children: [
                const Text(
                  'Store pickup (Ready in 20 min)',
                  style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'FREE',
                    style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildRadioTile(
            value: ShippingMethod.expressDelivery,
            title: const Text(
              'Express Delivery (2 - 4 business days)',
              style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioTile({required ShippingMethod value, required Widget title}) {
    return InkWell(
      onTap: () => setState(() => _selectedMethod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: _selectedMethod == value ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _selectedMethod == value ? AppColors.primary : Colors.grey.shade300,
            width: _selectedMethod == value ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<ShippingMethod>(
              activeColor: AppColors.primary,
              value: value,
              groupValue: _selectedMethod,
              onChanged: (val) => setState(() => _selectedMethod = val!),
            ),
            Expanded(child: title),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(List<CartItemModelFE> cartItems) {
    const double finalTotal = 10000000;
    const double subTotal = 4500000;
    const double shippingFee = 49000;
    const double discountAmount = 100000;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const Divider(height: 24),
          _buildRowWithLabel(label: 'Subtotal', value: formatMoney(subTotal)),
          _buildRowWithLabel(label: 'Shipping Fee', value: formatMoney(shippingFee)),
          _buildRowWithLabel(
            label: 'Discount (Voucher)',
            value: '- ${formatMoney(discountAmount)}',
            valueColor: AppColors.pink,
          ),
          _buildRowWithLabel(
            label: 'Voucher Applied',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Shipping Free',
                      style: TextStyle(fontSize: 11, color: Color.fromARGB(255, 0, 69, 23), fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(FeatherIcons.x, color: Colors.grey, size: 14),
              ],
            ),
          ),
          const Divider(height: 24),
          _buildRowWithLabel(
            label: 'Total Payment',
            value: formatMoney(finalTotal),
            labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            valueStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                print('Checkout triggered with method: ${_selectedMethod.name}');
              },
              icon: const Icon(FeatherIcons.checkCircle, color: Colors.white, size: 20),
              label: const Text(
                'Checkout',
                style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 5,
                shadowColor: AppColors.primary.withOpacity(0.4),
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
    Color valueColor = Colors.black87,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 2,
            child: Text(
              label,
              style: labelStyle ?? const TextStyle(fontSize: 14, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            child: child ??
                Text(
                  value ?? '',
                  textAlign: TextAlign.right,
                  style: valueStyle ?? TextStyle(fontSize: 14, color: valueColor, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final List<CartItemModelFE> cartItems = FE_CART_ITEMS;
    const bool isCartLoading = false;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: isMobile ? Colors.grey.shade50 : Colors.white,
          appBar: CustomAppBarMobile(
            title: 'My Cart (${FE_CART_ITEM_COUNT})',
            isBack: true,
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final bool useVerticalLayout = isMobile || constraints.maxWidth < 900;

              return SingleChildScrollView(
                // DỌC: cho toàn bộ nội dung
                padding: EdgeInsets.only(
                  top: 16,
                  bottom: isMobile ? 250 : 60, // Đảm bảo không bị che bởi bottom bar
                  left: useVerticalLayout ? 0 : 32,
                  right: useVerticalLayout ? 0 : 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!useVerticalLayout) ...[
                        _buildHeaderRow(),
                        const SizedBox(height: 16),
                      ],
                      if (isCartLoading)
                        ...List.generate(
                          5,
                          (_) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: const SkeletonHorizontalProduct(),
                          ),
                        )
                      else if (cartItems.isEmpty)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/images/NoItem.png', width: 250, height: 250, fit: BoxFit.contain),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                child: Text(
                                  "Your cart is empty. Let's find something great!",
                                  style: TextStyle(fontSize: 20, color: Colors.black87, fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Container(
                                width: 180,
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 8)],
                                ),
                                child: MyButton(
                                  text: 'Start Shopping',
                                  onTap: (_) => print('Start Shopping clicked'),
                                ),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        if (useVerticalLayout)
                          // MOBILE / NARROW: Mỗi item có thể cuộn ngang nếu tên dài
                          Column(
                            children: [
                              SlidableAutoCloseBehavior(
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(), // Không scroll dọc ở đây
                                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                                  itemCount: cartItems.length,
                                  itemBuilder: (context, index) {
                                    final item = cartItems[index];
                                    return LayoutBuilder(
                                      builder: (context, constraints) {
                                        // Nếu màn hình quá hẹp → cho phép scroll ngang từng item
                                        final bool needsHorizontalScroll = constraints.maxWidth < 380;

                                        return needsHorizontalScroll
                                            ? SingleChildScrollView(
                                                scrollDirection: Axis.horizontal,
                                                child: _buildMobileCartItem(item),
                                              )
                                            : _buildMobileCartItem(item);
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildShippingOptions(),
                              const SizedBox(height: 16),
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                                child: PromocodeSectionWidget(cartItems: cartItems),
                              ),
                              if (!isMobile) ...[
                                const SizedBox(height: 16),
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 16),
                                  child: _buildSummary(cartItems),
                                ),
                              ],
                            ],
                          )
                        else
                          // DESKTOP: Layout ngang
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: SlidableAutoCloseBehavior(
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                                    itemCount: cartItems.length,
                                    itemBuilder: (context, index) {
                                      final item = cartItems[index];
                                      return Slidable(
                                        key: ValueKey(item.productVariantId),
                                        endActionPane: ActionPane(
                                          motion: const ScrollMotion(),
                                          children: [
                                            CustomSlidableAction(
                                              borderRadius: BorderRadius.circular(16),
                                              onPressed: (_) => _handleRemoveItem(item.productVariantId),
                                              backgroundColor: Colors.transparent,
                                              child: const Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(FeatherIcons.trash2, color: AppColors.red, size: 24),
                                                  Text('Remove', style: TextStyle(color: AppColors.red, fontSize: 12)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
                                          ),
                                          child: CartItemWidget(
                                            itemCart: item,
                                            onQuantityChanged: (_) => setState(() {}),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 32),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildShippingOptions(),
                                    const SizedBox(height: 16),
                                    PromocodeSectionWidget(cartItems: cartItems),
                                    const SizedBox(height: 16),
                                    _buildSummary(cartItems),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                      if (!useVerticalLayout) ...[
                        const SizedBox(height: 40),
                        FooterWidget(),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          // BOTTOM BAR CHỈ HIỆN TRÊN MOBILE
          bottomNavigationBar: isMobile && cartItems.isNotEmpty
              ? Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -4))],
                  ),
                  child: _buildSummary(cartItems),
                )
              : null,
        ),
        // MODAL XÓA
        if (_itemToRemove != null) ...[
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.5))),
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

  // Tách riêng để tái sử dụng
  Widget _buildMobileCartItem(CartItemModelFE item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Slidable(
        key: ValueKey(item.productVariantId),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            CustomSlidableAction(
              borderRadius: BorderRadius.circular(16),
              onPressed: (_) => _handleRemoveItem(item.productVariantId),
              backgroundColor: Colors.transparent,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FeatherIcons.trash2, color: AppColors.red, size: 24),
                  Text('Remove', style: TextStyle(color: AppColors.red, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: CartItemWidget(
            itemCart: item,
            onQuantityChanged: (_) => setState(() {}),
          ),
        ),
      ),
    );
  }
}