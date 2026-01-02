import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/models/order.model.dart';
import 'package:recomart/services/order.service.dart';
import 'package:recomart/services/coupon.service.dart';
import 'package:recomart/services/vnpay_service.dart';
import 'package:recomart/views/pages/client/payment/vnpay_payment_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../components/custom/snackbar.dart';
import '../../../../provider/user_provider.dart';

enum ShippingMethod { pickupAtStore, expressDelivery }
enum PaymentMethod { cod, vnpay }

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
  final _orderService = OrderService();
  final _couponService = CouponService();
  final _vnpayService = VnpayService();

  final _addressCtrl = TextEditingController();
  final _couponCtrl = TextEditingController();
  final _pointsCtrl = TextEditingController();

  ShippingMethod _shippingMethod = ShippingMethod.expressDelivery;
  PaymentMethod _paymentMethod = PaymentMethod.cod;

  bool _isLoading = false;
  bool _isApplyingCoupon = false;
  bool _isAddressInitialized = false;

  double _couponDiscountMoney = 0;
  int _usedPoints = 0;

  @override
  void dispose() {
    _addressCtrl.dispose();
    _couponCtrl.dispose();
    _pointsCtrl.dispose();
    super.dispose();
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

  Future<void> _applyCoupon() async {
    final code = _couponCtrl.text.trim();
    if (code.isEmpty) {
      showCustomSnackBar(context, 'Please enter a coupon code first', type: SnackBarType.error);
      return;
    }
    setState(() => _isApplyingCoupon = true);
    try {
      final coupons = await _couponService.fetchCoupons();
      final coupon = coupons.firstWhere(
        (c) => c.code.toLowerCase() == code.toLowerCase(),
        orElse: () => throw Exception('Invalid coupon code'),
      );
      if (coupon.usedCount >= coupon.maxUsage) {
        throw Exception('Coupon code usage limit exceeded');
      }
      setState(() => _couponDiscountMoney = coupon.discountValue);
      showCustomSnackBar(context, 'Applied code $code successfully', type: SnackBarType.success);
    } catch (e) {
      showCustomSnackBar(context, e.toString(), type: SnackBarType.error);
    } finally {
      setState(() => _isApplyingCoupon = false);
    }
  }

  void _applyPoints(double currentLoyaltyPoints) {
    final entered = int.tryParse(_pointsCtrl.text.trim()) ?? 0;
    if (entered <= 0) return;
    if (entered > currentLoyaltyPoints) {
      showCustomSnackBar(context, 'You do not have enough points', type: SnackBarType.error);
      return;
    }
    setState(() => _usedPoints = entered);
  }

  void _handleCheckout(dynamic user) async {
    if (_isLoading) return;
    if (user == null || _addressCtrl.text.trim().isEmpty) {
      showCustomSnackBar(context, 'Please check your login status and shipping address', type: SnackBarType.error);
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_paymentMethod == PaymentMethod.vnpay) {
        final orderId = 'ORD${DateTime.now().millisecondsSinceEpoch}';
        final paymentUrl = _vnpayService.generatePaymentUrl(
          orderId: orderId,
          amount: total,
        );

        if (kIsWeb) {
          final Uri uri = Uri.parse(paymentUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            if (mounted) {
              setState(() => _isLoading = false);
              _showWebPaymentConfirmation(user);
            }
          } else {
            throw 'Could not launch payment gateway';
          }
        } else {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VnpayPaymentPage(paymentUrl: paymentUrl),
            ),
          );

          if (result == true) {
            await _placeOrder(user, paymentMethod: 'VNPAY', paymentStatus: 'PAID');
          } else {
            setState(() => _isLoading = false);
            showCustomSnackBar(context, 'Payment failed or cancelled', type: SnackBarType.warning);
          }
        }
      } else {
        await _placeOrder(user, paymentMethod: 'COD', paymentStatus: 'UNPAID');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      showCustomSnackBar(context, 'Error: $e', type: SnackBarType.error);
    }
  }

  void _showWebPaymentConfirmation(dynamic user) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Payment"),
        content: const Text("Did you complete the payment in the new tab?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(context);
              _placeOrder(user, paymentMethod: 'VNPAY', paymentStatus: 'PAID');
            },
            child: const Text("Yes, Completed", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder(dynamic user, {required String paymentMethod, required String paymentStatus}) async {
    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      final order = OrderModel(
        userId: user.id ?? '',
        userName: user.fullName ?? 'Customer',
        email: user.email ?? '',
        address: _addressCtrl.text.trim(),
        totalAmount: total,
        discountAmount: totalDiscount,
        loyaltyPointsUsed: _usedPoints,
        loyaltyPointsEarned: (total / 10000).floorToDouble(),
        status: 'PENDING',
        paymentMethod: paymentMethod,
        paymentStatus: paymentStatus,
        items: [
          OrderItemModel(
            productId: widget.productId,
            productName: widget.productName,
            quantity: widget.quantity,
            unitPrice: widget.unitPrice,
            discount: widget.discount,
            images: ImageModel(url: widget.imageUrl),
          ),
        ],
        orderTracking: [OrderTrackingModel(status: 'PENDING', date: now)],
        createdAt: now,
        updatedAt: now,
      );

      await _orderService.createOrder(order);
      if (mounted) {
        showCustomSnackBar(context, 'Order placed successfully', type: SnackBarType.success);
        Navigator.pop(context);
      }
    } catch (e) {
      showCustomSnackBar(context, 'Order creation failed: $e', type: SnackBarType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String format(double value) => NumberFormat.decimalPattern('en_US').format(value);

  Widget _buildAddressSection(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              const Text('Shipping Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              TextButton(onPressed: () {}, child: const Text('Edit')),
            ],
          ),
          const Divider(height: 20),
          Text(user?.fullName ?? 'Guest User', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _addressCtrl,
            maxLines: null,
            decoration: const InputDecoration(
              hintText: 'Enter detailed address',
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    if (user != null && user.address != null && !_isAddressInitialized) {
      _addressCtrl.text = user.address!;
      _isAddressInitialized = true;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Purchase'), backgroundColor: AppColors.primary),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(widget.imageUrl ?? '', width: 60, height: 60, fit: BoxFit.cover),
                ),
                title: Text(widget.productName ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${widget.quantity} x ${format(widget.unitPrice ?? 0)} USD'),
                trailing: Text('${format(subtotal)} USD', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            _buildAddressSection(user),
            const SizedBox(height: 24),
            const Text('Delivery Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            _buildShippingOption(ShippingMethod.pickupAtStore, 'Store pickup', 'FREE'),
            _buildShippingOption(ShippingMethod.expressDelivery, 'Express Delivery', null),
            const SizedBox(height: 24),
            const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            _buildPaymentOption(PaymentMethod.cod, 'Cash on Delivery', const Icon(Icons.money, color: Colors.green)),
            _buildPaymentOption(PaymentMethod.vnpay, 'VNPay Wallet', const Icon(Icons.account_balance_wallet, color: Colors.blue)),
            const SizedBox(height: 24),
            _buildDiscountSection((user?.loyaltyPoints ?? 0).toDouble()),
            const SizedBox(height: 24),
            _buildSummary(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _handleCheckout(user),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Confirm Order', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingOption(ShippingMethod method, String label, String? badge) {
    final selected = _shippingMethod == method;
    return Container(
      decoration: BoxDecoration(
        color: selected ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: RadioListTile<ShippingMethod>(
        value: method,
        groupValue: _shippingMethod,
        activeColor: AppColors.primary,
        title: Text(label, style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
        secondary: badge != null ? Text(badge, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)) : null,
        onChanged: (val) => setState(() => _shippingMethod = val!),
      ),
    );
  }

  Widget _buildPaymentOption(PaymentMethod method, String label, Widget icon) {
    final selected = _paymentMethod == method;
    return Container(
      decoration: BoxDecoration(
        color: selected ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: RadioListTile<PaymentMethod>(
        value: method,
        groupValue: _paymentMethod,
        activeColor: AppColors.primary,
        title: Text(label, style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
        secondary: icon,
        onChanged: (val) => setState(() => _paymentMethod = val!),
      ),
    );
  }

  Widget _buildDiscountSection(double points) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.purple.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(children: [
            Expanded(child: TextField(controller: _couponCtrl, decoration: const InputDecoration(hintText: 'Coupon code', isDense: true))),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isApplyingCoupon ? null : _applyCoupon, 
              child: _isApplyingCoupon 
                  ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)) 
                  : const Text('Apply')
            ),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: TextField(controller: _pointsCtrl, decoration: InputDecoration(hintText: 'Use points (Max: ${points.toInt()})', isDense: true))),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: () => _applyPoints(points), child: const Text('Use')),
          ]),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Column(
      children: [
        _buildSummaryRow('Subtotal', '${format(subtotal)} USD'),
        _buildSummaryRow('Shipping', '${format(shippingFee)} USD'),
        _buildSummaryRow('Discount', '- ${format(totalDiscount)} USD', color: Colors.red),
        const Divider(),
        _buildSummaryRow('Total', '${format(total)} USD', bold: true, fontSize: 18, color: AppColors.primary),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool bold = false, Color? color, double fontSize = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontSize: fontSize)),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontSize: fontSize, color: color)),
        ],
      ),
    );
  }
}