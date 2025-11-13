import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/models/order.model.dart';
import 'package:recomart/services/order.service.dart';
import 'package:recomart/services/coupon.service.dart';
import 'package:recomart/services/user.service.dart';

import '../../../../components/custom/snackbar.dart';
import '../../../../helpers/formatMoney.dart';
import '../../../../provider/cart_provider.dart';

enum ShippingMethod { pickupAtStore, expressDelivery }

class OrderCheckoutPage extends StatefulWidget {
  final String? productId;
  final String? productName;
  final String? imageUrl;
  final double? unitPrice;
  final int? quantity;
  final double? discount;

  const OrderCheckoutPage({
    super.key,
    this.productId,
    this.productName,
    this.imageUrl,
    this.unitPrice,
    this.quantity,
    this.discount,
  });

  @override
  State<OrderCheckoutPage> createState() => _OrderCheckoutPageState();
}

class _OrderCheckoutPageState extends State<OrderCheckoutPage> {
  final _auth = FirebaseAuth.instance;
  final _orderService = OrderService();
  final _userService = UserService();
  final _couponService = CouponService();

  final _addressCtrl = TextEditingController();
  final _couponCtrl = TextEditingController();
  final _pointsCtrl = TextEditingController();

  ShippingMethod _shippingMethod = ShippingMethod.expressDelivery;
  bool _isLoading = false;
  bool _isApplyingCoupon = false;

  double _couponDiscountMoney = 0;
  int _usedPoints = 0;
  double _loyaltyPoints = 0;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final data = await _userService.getUserInfo(user.uid);
    if (mounted) {
      setState(() {
        _addressCtrl.text = data?['address'] ?? '';
        _loyaltyPoints = (data?['loyaltyPoints'] ?? 0).toDouble();
      });
    }
  }

  double get subtotal {
    final price = widget.unitPrice ?? 0;
    final qty = widget.quantity ?? 1;
    final discount = (widget.discount ?? 0) / 100;
    return (price - price * discount) * qty;
  }

  double get shippingFee =>
      _shippingMethod == ShippingMethod.pickupAtStore ? 0 : 20000;

  double get totalDiscount => _couponDiscountMoney + _usedPoints * 1000;

  double get total =>
      (subtotal + shippingFee - totalDiscount).clamp(0, double.infinity);

  /// ✅ Áp dụng mã giảm giá
  Future<void> _applyCoupon() async {
    final code = _couponCtrl.text.trim();

    if (code.isEmpty) {
      showCustomSnackBar(
        context,
        'Vui lòng nhập mã giảm giá trước khi áp dụng',
        type: SnackBarType.error,
      );
      return;
    }

    setState(() => _isApplyingCoupon = true);

    try {
      // 🔹 Lấy toàn bộ coupon từ Firestore
      final coupons = await _couponService.fetchCoupons();

      // 🔹 Tìm coupon khớp mã
      final coupon = coupons.firstWhere(
            (c) => c.code.toLowerCase() == code.toLowerCase(),
        orElse: () => throw Exception('❌ Mã giảm giá không hợp lệ'),
      );

      // 🔹 Kiểm tra lượt dùng
      if (coupon.usedCount >= coupon.maxUsage) {
        throw Exception('⚠️ Mã "$code" đã hết lượt sử dụng');
      }

      // 🔹 Áp dụng giảm giá
      setState(() {
        _couponDiscountMoney = coupon.discountValue;
      });

      showCustomSnackBar(
        context,
        '🎟️ Áp dụng mã $code thành công (-${formatMoney(coupon.discountValue)})',
        type: SnackBarType.success,
      );
    } catch (e) {
      showCustomSnackBar(context, e.toString(), type: SnackBarType.error);
    } finally {
      setState(() => _isApplyingCoupon = false);
    }
  }

  /// ✅ Áp dụng điểm thưởng
  void _applyPoints() {
    final entered = int.tryParse(_pointsCtrl.text.trim()) ?? 0;
    if (entered <= 0) return;
    if (entered > _loyaltyPoints) {
      showCustomSnackBar(
        context,
        '❌ Bạn không đủ điểm để dùng!',
        type: SnackBarType.error,
      );
      return;
    }
    setState(() => _usedPoints = entered);
  }

  /// ✅ Gửi đơn hàng
  Future<void> _placeOrder() async {
    if (_isLoading) return;
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      final order = OrderModel(
        userId: user.uid,
        userName: user.displayName ?? 'Khách hàng',
        email: user.email ?? '',
        address: _addressCtrl.text,
        totalAmount: total,
        discountAmount: totalDiscount,
        loyaltyPointsUsed: _usedPoints,
        loyaltyPointsEarned: (total / 10000).floorToDouble(),
        status: 'PENDING',
        paymentMethod: 'COD',
        paymentStatus: 'UNPAID',
        items: [
          OrderItemModel(
            productId: widget.productId,
            productName: widget.productName,
            quantity: widget.quantity,
            unit_price: widget.unitPrice,
            discount: widget.discount,
            images: ImageModel(url: widget.imageUrl),
          ),
        ],
        orderTracking: [
          OrderTrackingModel(status: 'PENDING', date: now),
        ],
        createdAt: now,
        updatedAt: now,
      );

      await _orderService.createOrder(order);

      showCustomSnackBar(
        context,
        '🎉 Đặt hàng thành công!',
        type: SnackBarType.success,
      );
      Navigator.pop(context);
    } catch (e) {
      showCustomSnackBar(context, 'Lỗi khi tạo đơn hàng: $e',
          type: SnackBarType.error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String format(double value) =>
      NumberFormat.decimalPattern('vi_VN').format(value);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận mua hàng'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- THÔNG TIN SẢN PHẨM ---
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(widget.imageUrl ?? '',
                      width: 70, fit: BoxFit.cover),
                ),
                title: Text(widget.productName ?? ''),
                subtitle: Text(
                    '${widget.quantity} x ${format(widget.unitPrice ?? 0)} đ'),
                trailing: Text(
                  '${format(subtotal)} đ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text('Choose Delivery Mode',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            _buildShippingOption(
              ShippingMethod.pickupAtStore,
              'Store pickup (Ready in 20 min)',
              'FREE',
            ),
            const SizedBox(height: 8),
            _buildShippingOption(
              ShippingMethod.expressDelivery,
              'Express Delivery (2 - 4 business days)',
              null,
            ),

            const SizedBox(height: 20),
            _buildDiscountSection(),

            const SizedBox(height: 20),
            _buildSummary(),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child:
                Text(_isLoading ? 'Đang xử lý...' : 'Xác nhận đặt hàng'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingOption(
      ShippingMethod method, String label, String? badge) {
    final selected = _shippingMethod == method;
    return InkWell(
      onTap: () => setState(() => _shippingMethod = method),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
              color:
              selected ? AppColors.primary : Colors.grey.shade300,
              width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Radio(
              value: method,
              groupValue: _shippingMethod,
              activeColor: AppColors.primary,
              onChanged: (_) => setState(() => _shippingMethod = method),
            ),
            Expanded(child: Text(label)),
            if (badge != null)
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(
                  badge,
                  style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F3FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coupon
          Row(children: [
            const Icon(Icons.discount, color: Colors.purple),
            const SizedBox(width: 6),
            const Text('Voucher / Coupon',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _couponCtrl,
                decoration: const InputDecoration(
                  hintText: 'Nhập mã giảm giá',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isApplyingCoupon ? null : _applyCoupon,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: Text(_isApplyingCoupon ? '...' : 'Áp dụng'),
            )
          ]),
          const Divider(height: 20),

          // Loyalty
          Row(children: [
            const Icon(Icons.card_giftcard, color: Colors.indigo),
            const SizedBox(width: 6),
            const Text('Loyalty Points',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ]),
          Text('Bạn có ${_loyaltyPoints.toInt()} điểm (1 điểm = 1.000đ)'),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _pointsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Nhập số điểm muốn dùng',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _applyPoints,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text('Dùng điểm'),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryRow('Subtotal', format(subtotal)),
            _buildSummaryRow('Shipping Fee', format(shippingFee)),
            _buildSummaryRow('Discount (Voucher & Points)',
                '- ${format(totalDiscount)}', color: Colors.pink),
            const Divider(height: 24),
            _buildSummaryRow('Total Payment', format(total),
                bold: true, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  color: color ?? Colors.black87)),
        ],
      ),
    );
  }
}
