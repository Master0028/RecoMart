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
          type: SnackBarType.success);
  }

  Widget _buildHeaderRow() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05), 
            borderRadius: BorderRadius.circular(12),

          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 900),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text('PRODUCT', style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary, 
                      fontWeight: FontWeight.bold,
                    )),
                ),
                Expanded(
                  flex: 1,
                  child: Text('QUANTITY', style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary, 
                      fontWeight: FontWeight.bold,
                    ))
                ),
                Expanded(
                  flex: 1,
                  child: Text('TOTAL',
                      textAlign: TextAlign.end, style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary, 
                      fontWeight: FontWeight.bold,
                    )),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
  
  Widget _buildShippingOptions() {
    // Logic của widget này giữ nguyên
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Delivery Mode',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          _buildRadioTile(
            value: ShippingMethod.pickupAtStore,
            title: Row(
              children: [
                const Text('Store pickup (Ready in 20 min)',
                    style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500)),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'FREE',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          _buildRadioTile(
            value: ShippingMethod.expressDelivery,
            title: const Text('Express Delivery (2 - 4 business days)',
                style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioTile(
      {required ShippingMethod value, required Widget title}) {
    // Logic của widget này giữ nguyên
    return InkWell(
      onTap: () {
        setState(() {
          _selectedMethod = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
              onChanged: (ShippingMethod? newValue) {
                setState(() {
                  _selectedMethod = newValue!;
                });
              },
            ),
            Expanded(child: title),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(List<CartItemModelFE> cartItems) {
    const double finalTotal = 5000000;
    const double subTotal = 4500000; 
    const double shippingFee = 49000; 
    const double discountAmount = 100000; 
    
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
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Divider(height: 30),
            _buildRowWithLabel(
                label: 'Subtotal', value: formatMoney(subTotal)),
            _buildRowWithLabel(label: 'Shipping Fee', value: formatMoney(shippingFee)),
            _buildRowWithLabel(
              label: 'Discount (Voucher)',
              value: '- ${formatMoney(discountAmount)}',
              valueColor: AppColors.pink,
            ),
            _buildRowWithLabel(
              label: 'Voucher Applied',
              labelStyle: const TextStyle(fontSize: 14, color: Colors.black),
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
                        style: TextStyle(
                          fontSize: 11,
                          color: Color.fromARGB(255, 0, 69, 23),
                          fontWeight: FontWeight.w600,
                        ),
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
            const Divider(height: 30),
            // Total Row
            _buildRowWithLabel(
              label: 'Total Payment',
              value: formatMoney(finalTotal),
              labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              valueStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            // Checkout Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  print('Checkout triggered with method: ${_selectedMethod.name}');
                },
                icon: const Icon(FeatherIcons.checkCircle, color: Colors.white, size: 20),
                label: const Text(
                  'Proceed to Checkout',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
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

  Widget _buildRowWithLabel(
      {required String label,
      Widget? child,
      String? value,
      TextStyle? labelStyle,
      TextStyle? valueStyle,
      Color valueColor = Colors.black}) {
    // Logic của widget này giữ nguyên
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: labelStyle ?? const TextStyle(fontSize: 14, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
          child ??
              Text(
                value ?? '',
                style: valueStyle ??
                    TextStyle(
                        fontSize: 14,
                        color: valueColor,
                        fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final List<CartItemModelFE> cartItems = FE_CART_ITEMS;
    const bool isCartLoading = false;
    return Stack(
          children: <Widget>[
            Scaffold(
              backgroundColor: isMobile ? Colors.grey.shade100 : Colors.white, 
              appBar: CustomAppBarMobile(
                title: 'My Cart (${FE_CART_ITEM_COUNT})',
                isBack: true,
              ),
              body: Builder(
                builder: (context) {
                  // ignore: dead_code
                  if (isCartLoading) {
                    return ListView.builder( 
                      itemCount: 5,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 15),
                          child: SkeletonHorizontalProduct(),
                        );
                      });
                  }
                  
                  if (cartItems.isEmpty) {
                    // Logic Empty State UI
                    return Center( 
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/NoItem.png',
                                width: 300,
                                height: 300,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 20),
                                child: Text(
                                  "Your cart is empty. Let's find something great!",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(
                                width: 200,
                                height: 45,
                                child: MyButton(
                                  text: 'Start Shopping',
                                  onTap: (_) {
                                    print('Start Shopping clicked');
                                  },
                                ),
                              )
                            ],
                          ),
                        );
                  }
                return ListView( 
                  padding: isMobile
                      ? const EdgeInsets.only(bottom: 100)
                      : const EdgeInsets.symmetric(horizontal: 64, vertical: 30), 
                  children: [
                    if (!isMobile) 
                      _buildHeaderRow(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: isMobile ? 1 : 3,
                          child: SlidableAutoCloseBehavior(
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              separatorBuilder: (context, index) => const SizedBox(height: 15),
                              itemCount: cartItems.length,
                              itemBuilder: (context, index) {
                                final itemCart = cartItems[index];
                                return Slidable(
                                  key: ValueKey(itemCart.productVariantId),
                                  closeOnScroll: true,
                                  endActionPane: ActionPane(
                                    motion: const ScrollMotion(),
                                    children: [
                                      CustomSlidableAction(
                                        borderRadius: BorderRadius.circular(16),
                                        onPressed: (_) {
                                          _handleRemoveItem(itemCart.productVariantId);
                                        },
                                        backgroundColor: Colors.transparent,
                                        child: const Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(FeatherIcons.trash2, color: AppColors.red, size: 28),
                                            Text('Remove', style: TextStyle(color: AppColors.red, fontSize: 14)),
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
                        ),
                        if (!isMobile)
                          const SizedBox(width: 40),
                        if (!isMobile)
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                _buildShippingOptions(),
                                const SizedBox(height: 30),
                                PromocodeSectionWidget(cartItems: cartItems),
                                const SizedBox(height: 30),
                                _buildSummary(cartItems),
                              ],
                            ),
                          ),
                      ],
                    ),
                    if (!isMobile)
                      ...[
                        const SizedBox(height: 40),
                        FooterWidget(),
                      ],
                    if (isMobile)
                      ...[
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: [
                              _buildShippingOptions(),
                              const SizedBox(height: 20),
                              PromocodeSectionWidget(cartItems: cartItems),
                              const SizedBox(height: 20),
                              _buildSummary(cartItems),
                            ],
                          ),
                        ),
                      ],
                  ],
                );
              },
            ),
            bottomNavigationBar: Responsive.isMobile(context) && cartItems.isNotEmpty
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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