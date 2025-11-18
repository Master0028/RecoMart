import 'package:flutter/material.dart';
import '../models/cart.model.dart';
import '../models/coupon.model.dart';
import '../services/cart.service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();

  CartModel? _cart;
  bool _loading = false;

  double _couponDiscount = 0;
  int _usedPoints = 0;
  CouponModel? _selectedCoupon;

  CartModel? get cart => _cart;
  bool get isLoading => _loading;
  double get couponDiscount => _couponDiscount;
  int get usedPoints => _usedPoints;
  CouponModel? get selectedCoupon => _selectedCoupon;

  double get totalPrice {
    if (_cart == null) return 0;
    return _cart!.items.fold(
      0,
          (sum, item) =>
      sum + (item.unitPrice - (item.unitPrice * item.discount / 100)) * item.quantity,
    );
  }

  int get totalItems {
    if (_cart == null) return 0;
    return _cart!.items.fold(0, (sum, item) => sum + item.quantity);
  }

  void applyCoupon(CouponModel coupon) {
    _selectedCoupon = coupon;
    _couponDiscount = coupon.discountValue ?? 0;
    notifyListeners();
  }

  void setUsedPoints(int points) {
    _usedPoints = points;
    notifyListeners();
  }

  void setDiscounts({double? coupon, int? points}) {
    if (coupon != null) _couponDiscount = coupon;
    if (points != null) _usedPoints = points;
    notifyListeners();
  }

  void clearDiscounts() {
    _couponDiscount = 0;
    _usedPoints = 0;
    _selectedCoupon = null;
    notifyListeners();
  }

  Future<void> loadCart() async {
    _cart = await _cartService.getUserCart();
    notifyListeners();
  }

  Future<void> addToCart(ProductForCartModel item) async {
    await _cartService.addToCart(item);
    await loadCart();
  }

  Future<void> updateItemQuantity(
      String userId, String productId, int newQuantity) async {
    await _cartService.updateItemQuantity(
      userId: userId,
      productId: productId,
      newQuantity: newQuantity,
    );
    await fetchCartByUserId(userId);
  }

  Future<void> removeItemFromCart(String userId, String productId) async {
    await _cartService.removeItemFromCart(
      userId: userId,
      productId: productId,
    );
    await fetchCartByUserId(userId);
  }

  Future<void> clearCart() async {
    await _cartService.clearCart();
    _cart = null;
    clearDiscounts();
    notifyListeners();
  }

  Future<void> fetchCartByUserId(String userId) async {
    try {
      _loading = true;
      notifyListeners();

      final fetchedCart = await _cartService.getCartByUserId(userId);
      _cart = fetchedCart;
    } catch (e) {
      debugPrint('Lỗi khi tải giỏ hàng: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
