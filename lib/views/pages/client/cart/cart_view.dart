import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:recomart/components/custom/snackbar.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/helpers/formatMoney.dart';
import 'package:recomart/utils/responsive.dart';
import 'package:recomart/utils/widget/CustomAppBarMobile.dart';
import 'package:recomart/utils/widget/footer.dart';

import '../../../../models/cart.model.dart';
import '../../../../models/order.model.dart';
import '../../../../provider/cart_provider.dart';
import '../../../../services/coupon.service.dart';
import '../../../../services/order.service.dart';
import '../../../../services/user.service.dart';
import 'widgets/cart_item_widget.dart';
import 'widgets/promocode_section_widget.dart';
import 'widgets/remove_cart_widget.dart';

enum ShippingMethod { pickupAtStore, expressDelivery }

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  ShippingMethod _selectedMethod = ShippingMethod.expressDelivery;
  int? _itemToRemove;
  final int _quantityToRemove = 1;

  final TextEditingController _shippingAddressController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();

  final _userService = UserService();
  final _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      await cartProvider.loadCart();
      await _loadUserInfo();
    });
  }

  @override
  void dispose() {
    _shippingAddressController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  void _cancelRemoveItem() => setState(() => _itemToRemove = null);

  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userData = await _userService.getUserInfo(user.uid);

      if (mounted && userData != null) {
        _shippingAddressController.text =
            userData['address'] ?? 'Chưa có địa chỉ';
        _contactPhoneController.text =
            userData['phone'] ?? 'Chưa có số điện thoại';
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy thông tin user: $e');
    }
  }

  Future<void> _createOrder(CartProvider provider) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      showCustomSnackBar(context, 'Vui lòng đăng nhập để thanh toán',
          type: SnackBarType.error);
      return;
    }

    final address = _shippingAddressController.text.trim();
    final phone = _contactPhoneController.text.trim();

    if (address.isEmpty || phone.isEmpty) {
      showCustomSnackBar(context, 'Vui lòng nhập địa chỉ và số điện thoại',
          type: SnackBarType.error);
      return;
    }

    final cartItems = provider.cart?.items ?? [];
    if (cartItems.isEmpty) {
      showCustomSnackBar(context, 'Giỏ hàng trống', type: SnackBarType.error);
      return;
    }

    try {
      // 🔹 Lấy thông tin user từ Firestore
      final userData = await _userService.getUserInfo(user.uid);
      final userName = userData?['name'] ?? 'Unknown User';
      final email = userData?['email'] ?? user.email ?? '';
      final currentPoints = (userData?['loyaltyPoints'] ?? 0).toDouble();

      // 🔹 Tính tổng giá
      final subtotal = provider.totalPrice;
      final shippingFee =
      _selectedMethod == ShippingMethod.pickupAtStore ? 0 : 20000;
      final discount = provider.couponDiscount + (provider.usedPoints * 1000);
      final total = (subtotal + shippingFee - discount).clamp(0, double.infinity);

      // 🔹 Tạo danh sách sản phẩm
      final orderItems = cartItems.map((p) {
        return OrderItemModel(
          productId: p.productId,
          productName: p.productName,
          quantity: p.quantity,
          unit_price: p.unitPrice,
          discount: p.discount,
          images: p.image != null ? ImageModel(url: p.image) : null,
        );
      }).toList();

      // 🔹 Tạo OrderModel
      final order = OrderModel(
        userId: user.uid,
        userName: userName,
        email: email,
        address: address,
        totalAmount: total.toDouble(),
        discountAmount: discount,
        loyaltyPointsUsed: provider.usedPoints,
        loyaltyPointsEarned: (total / 10000).floorToDouble(),
        status: 'pending',
        paymentMethod: 'COD',
        paymentStatus: 'unpaid',
        items: orderItems,
        orderTracking: [
          OrderTrackingModel(status: 'pending', date: DateTime.now()),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Lưu đơn hàng vào Firestore
      await _orderService.createOrder(order);

      if (provider.selectedCoupon != null) {
        final coupon = provider.selectedCoupon!;
        final orderId = order.id;

        if (orderId != null) {
          final isUpdated = await CouponService()
              .updateCouponUsage(coupon: coupon, orderId: orderId);

          if (isUpdated) {
            showCustomSnackBar(
              context,
              'Coupon ${coupon.code} đã được áp dụng cho đơn $orderId',
              type: SnackBarType.success,
            );
          }
        }
      }

      // Cập nhật điểm khách hàng
      final newPoints = (currentPoints - provider.usedPoints +
          (total / 10000).floorToDouble())
          .clamp(0, double.infinity);
      await _userService.updateUserPoints(user.uid, newPoints);

      // Dọn giỏ hàng
      await provider.clearCart();

      showCustomSnackBar(context, 'Đặt hàng thành công!',
          type: SnackBarType.success);

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      debugPrint('Lỗi khi tạo đơn hàng: $e');
      showCustomSnackBar(context, 'Lỗi khi tạo đơn hàng: $e',
          type: SnackBarType.error);
    }
  }


  Future<void> _handleRemoveItem(BuildContext context, String productId) async {
    final provider = Provider.of<CartProvider>(context, listen: false);
    final userId = provider.cart?.userId ?? '';

    await provider.removeItemFromCart(userId, productId);
    showCustomSnackBar(context, '🗑️ Đã xóa sản phẩm khỏi giỏ hàng',
        type: SnackBarType.success);
  }

  Widget _buildHeaderRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 3,
            child: Text('PRODUCT',
                style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 2,
            child: Text('QUANTITY',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 1,
            child: Text('TOTAL',
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold)),
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
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            Text(label,
            style:
            labelStyle ?? const TextStyle(fontSize: 14, color: Colors.black54)),
        child ??
            Text(value ?? '',
                textAlign: TextAlign.right,
                style: valueStyle ??
                    TextStyle(
                        fontSize: 14,
                        color: valueColor,
                        fontWeight: FontWeight.w600)),
    ],
    ),
    );
  }

  Widget _buildAddressSection() {
    return _ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shipping Information',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _shippingAddressController,
            decoration: InputDecoration(
              labelText: 'Delivery Address',
              hintText: 'e.g., 123 Nguyen Trai, District 5, HCM',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contactPhoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Contact Phone Number',
              hintText: 'e.g., 0901234567',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingOptions() {
    return _ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Choose Delivery Mode',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),
          _buildRadioTile(
              value: ShippingMethod.pickupAtStore,
              title: Row(children: [
                const Expanded(
                    child: Text('Store pickup (Ready in 20 min)',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500))),
                const SizedBox(width: 8),
                Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6)),
                    child: Text('FREE',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold)))
              ])),
          const SizedBox(height: 8),
          _buildRadioTile(
              value: ShippingMethod.expressDelivery,
              title: const Text('Express Delivery (2 - 4 business days)',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildRadioTile({required ShippingMethod value, required Widget title}) {
    return InkWell(
      onTap: () => setState(() => _selectedMethod = value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: _selectedMethod == value
              ? AppColors.primary.withOpacity(0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: _selectedMethod == value
                  ? AppColors.primary
                  : Colors.grey.shade300,
              width: _selectedMethod == value ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Radio<ShippingMethod>(
                activeColor: AppColors.primary,
                value: value,
                groupValue: _selectedMethod,
                onChanged: (val) => setState(() => _selectedMethod = val!)),
            Expanded(child: title),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryDetails(
      CartProvider provider,
      ShippingMethod selectedMethod,
      double couponDiscount,
      int usedPoints,
      ) {
    // 🔹 Tính tổng tiền sản phẩm (subtotal)
    final subtotal = provider.cart?.items.fold<double>(
      0,
          (sum, item) =>
      sum +
          (item.unitPrice - (item.unitPrice * item.discount / 100)) *
              item.quantity,
    ) ??
        0;

    // 🔹 Phí vận chuyển
    final shippingFee =
    selectedMethod == ShippingMethod.pickupAtStore ? 0.0 : 20000.0;

    // 🔹 Giảm giá (voucher + điểm KHTT)
    final totalDiscount = couponDiscount + (usedPoints * 1000);

    // 🔹 Tổng thanh toán cuối cùng
    final totalPayment = (subtotal + shippingFee - totalDiscount).clamp(0, double.infinity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRowWithLabel(
          label: 'Subtotal',
          value: formatMoney(subtotal),
        ),
        _buildRowWithLabel(
          label: 'Shipping Fee',
          value: formatMoney(shippingFee),
        ),
        _buildRowWithLabel(
          label: 'Discount (Voucher & Points)',
          value: '- ${formatMoney(totalDiscount)}',
          valueColor: AppColors.pink,
        ),
        const Divider(height: 24),
        _buildRowWithLabel(
          label: 'Total Payment',
          value: formatMoney(totalPayment.toDouble()),
          labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          valueStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => _createOrder(provider),
            icon: const Icon(FeatherIcons.checkCircle,
                color: Colors.white, size: 20),
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
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 5,
              shadowColor: AppColors.primary.withOpacity(0.4),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Consumer<CartProvider>(
      builder: (context, provider, _) {
        final cart = provider.cart;
        final cartItems = cart?.items ?? [];

        if (provider.isLoading) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        if (cartItems.isEmpty) {
          return Scaffold(
            appBar: CustomAppBarMobile(title: 'My Cart (0)', isBack: true),
            body: const Center(
                child: Text('🛒 Giỏ hàng của bạn đang trống',
                    style: TextStyle(fontSize: 16))),
          );
        }

        return Stack(children: [
          Scaffold(
            backgroundColor: isMobile ? Colors.grey.shade50 : Colors.white,
            appBar: CustomAppBarMobile(
              title: 'My Cart (${provider.totalItems})',
              isBack: true,
            ),
            body: LayoutBuilder(builder: (context, constraints) {
              final bool isVerticalLayout = constraints.maxWidth < 900;
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                        vertical: 24, horizontal: isVerticalLayout ? 0 : 32),
                    child: Column(
                      children: [
                        isVerticalLayout
                            ? _buildVerticalLayout(cartItems, provider, isMobile)
                            : _buildHorizontalLayout(cartItems, provider),
                        if (!isMobile) ...[
                          const SizedBox(height: 40),
                          const FooterWidget(),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ]);
      },
    );
  }

  Widget _buildVerticalLayout(List<ProductForCartModel> items,
      CartProvider provider, bool isMobile) {
    return Column(
      children: [
        _buildCartList(items, true),
        const SizedBox(height: 20),
        _buildSidebar(items, provider, isMobile: true),
      ],
    );
  }

  Widget _buildHorizontalLayout(
      List<ProductForCartModel> items, CartProvider provider) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        flex: 3,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildHeaderRow()),
            const SizedBox(height: 16),
            _buildCartList(items, false),
          ],
        ),
      ),
      Expanded(
        flex: 2,
        child: Padding(
          padding: const EdgeInsets.only(left: 32),
          child: _buildSidebar(items, provider, isMobile: false),
        ),
      ),
    ]);
  }

  Widget _buildSidebar(List<ProductForCartModel> items, CartProvider provider,
      {required bool isMobile}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 0),
      child: Column(
        children: [
          if (isMobile) const SizedBox(height: 24),
          _buildAddressSection(),
          const SizedBox(height: 16),
          _buildShippingOptions(),
          const SizedBox(height: 16),
          PromocodeSectionWidget(cartItems: items),
          const SizedBox(height: 16),
          _ModernCard(
            child: _buildSummaryDetails(
              provider,
              _selectedMethod,
              provider.couponDiscount,
              provider.usedPoints,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(List<ProductForCartModel> cartItems, bool isVertical) {
    final provider = Provider.of<CartProvider>(context, listen: false);
    final userId = provider.cart?.userId ?? '';

    return SlidableAutoCloseBehavior(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final item = cartItems[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: isVertical ? 16 : 0),
            child: Slidable(
              key: ValueKey(item.productId),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  CustomSlidableAction(
                    borderRadius: BorderRadius.circular(16),
                    onPressed: (_) => _handleRemoveItem(context, item.productId ?? ''),
                    backgroundColor: Colors.transparent,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FeatherIcons.trash2,
                            color: AppColors.red, size: 24),
                        Text('Remove',
                            style:
                            TextStyle(color: AppColors.red, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              child: _ModernCard(
                padding: EdgeInsets.zero,
                child: CartItemWidget(
                  itemCart: item,
                  onQuantityChanged: (newQty) async {
                    await provider.updateItemQuantity(
                        userId, item.productId ?? '', newQty);
                    showCustomSnackBar(context, 'Cập nhật số lượng thành công',
                        type: SnackBarType.success);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const _ModernCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5)),
        ],
      ),
      child: child,
    );
  }
}
