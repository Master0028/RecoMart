import 'package:flutter/material.dart';
import '../models/cart.model.dart';
import '../models/coupon.model.dart';
import '../services/cart.service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();

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
  
  double get finalTotal {
    double total = totalPrice - _couponDiscount - (_usedPoints / 100);
    return total < 0 ? 0 : total;
  }

  double get totalPrice {
    if (_cart == null || _cart!.items.isEmpty) return 0;
    return _cart!.items.fold(
      0,
      (sum, item) =>
          sum + (item.unitPrice * (1 - item.discount / 100)) * item.quantity,
    );
  }

  int get totalItems {
    if (_cart == null) return 0;
    return _cart!.items.fold(0, (sum, item) => sum + item.quantity);
  }

  void applyCoupon(CouponModel coupon) {
    _selectedCoupon = coupon;
    _couponDiscount = coupon.discountValue;
    notifyListeners();
  }

  void setUsedPoints(int points) {
    _usedPoints = points;
    notifyListeners();
  }

  void clearDiscounts() {
    _couponDiscount = 0;
    _usedPoints = 0;
    _selectedCoupon = null;
    notifyListeners();
  }

  Future<void> fetchCart(String? userId) async {
    if (userId == null || userId.isEmpty) {
      _cart = null;
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final fetchedCart = await _cartService.getCartByUserId(userId);
      _cart = fetchedCart;
    } catch (e) {
      debugPrint('Error fetching cart: $e');
      _cart = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(ProductForCartModel item, String? userId) async {
    if (userId == null) throw Exception("User not logged in");
    
    try {
      _isLoading = true;
      notifyListeners();
      
      await _cartService.addToCart(item);
      await fetchCart(userId);
    } catch (e) {
      debugPrint('Error adding to cart: $e');
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
    try {
      await _cartService.updateItemQuantity(
        userId: userId,
        productId: productId,
        newQuantity: newQuantity,
      );
      await fetchCart(userId);
    } catch (e) {
      debugPrint('Error updating quantity: $e');
    }
  }

  Future<void> removeItem(String userId, String productId) async {
    try {
      await _cartService.removeItemFromCart(
        userId: userId,
        productId: productId,
      );
      await fetchCart(userId);
    } catch (e) {
      debugPrint('Error removing item: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      await _cartService.clearCart();
      _cart = null;
      clearDiscounts();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing cart: $e');
    }
  }

  void applyLoyaltyPoints(int points) {
    _usedPoints = points;
    notifyListeners();
  }

  Future<void> loadCart(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}