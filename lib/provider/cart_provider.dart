import 'package:flutter/material.dart';
import '../models/cart.model.dart';
import '../models/coupon.model.dart';
import '../services/cart.service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();
  final List<ProductForCartModel> _items = [];
  List<ProductForCartModel> get items => _items;

  CartModel? _cart;
  bool _isLoading = false;

  double _couponDiscount = 0;
  int _usedPoints = 0;
  CouponModel? _selectedCoupon;

  CartModel? get cart => _cart;
  bool get isLoading => _isLoading;
  double get couponDiscount => _couponDiscount;
  int get usedPoints => _usedPoints;
  CouponModel? get selectedCoupon => _selectedCoupon;

  int get totalItems {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalPrice {
    if (_cart == null || _cart!.items.isEmpty) return 0;
    return _cart!.items.fold(
      0,
      (sum, item) =>
          sum +
          (item.unitPrice * (1 - item.discount / 100)) * item.quantity,
    );
  }

  double get finalTotal {
    final total = totalPrice - _couponDiscount - (_usedPoints * 1000);
    return total < 0 ? 0 : total;
  }

  void applyCoupon(CouponModel coupon) {
    _selectedCoupon = coupon;
    _couponDiscount = coupon.discountValue;
    notifyListeners();
  }

  void applyLoyaltyPoints(int points) {
    _usedPoints = points;
    notifyListeners();
  }

  void clearDiscounts() {
    _couponDiscount = 0;
    _usedPoints = 0;
    _selectedCoupon = null;
    notifyListeners();
  }

  Future<void> fetchCart(String userId) async {
    if (userId.isEmpty) {
      _cart = null;
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      _cart = await _cartService.getCartByUserId(userId);
    } catch (e) {
      debugPrint('fetchCart error: $e');
      _cart = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart({
    required String userId,
    required ProductForCartModel item,
  }) async {
    if (userId.isEmpty) {
      throw Exception("User not logged in");
    }

    try {
      _isLoading = true;
      notifyListeners();

      await _cartService.addToCart(
        userId: userId,
        item: item,
      );

      await fetchCart(userId);
    } catch (e) {
      debugPrint('addToCart error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateItemQuantity({
    required String userId,
    required String productId,
    required int newQuantity,
  }) async {
    if (userId.isEmpty) return;

    try {
      await _cartService.updateItemQuantity(
        userId: userId,
        productId: productId,
        newQuantity: newQuantity,
      );

      await fetchCart(userId);
    } catch (e) {
      debugPrint('updateItemQuantity error: $e');
    }
  }

  Future<void> removeItem({
    required String userId,
    required String productId,
  }) async {
    if (userId.isEmpty) return;

    try {
      await _cartService.removeItemFromCart(
        userId: userId,
        productId: productId,
      );

      await fetchCart(userId);
    } catch (e) {
      debugPrint('removeItem error: $e');
    }
  }

  Future<void> clearCart(String userId) async {
    if (userId.isEmpty) return;

    try {
      await _cartService.clearCart(userId);
      _cart = null;
      clearDiscounts();
      notifyListeners();
    } catch (e) {
      debugPrint('clearCart error: $e');
    }
  }

  void resetCart() {
    _cart = null;
    _isLoading = false;
    clearDiscounts();
    notifyListeners();
  }

}