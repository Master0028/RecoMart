import 'package:flutter/material.dart';
import '../models/cart.model.dart';
import '../services/cart.service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();

  CartModel? _cart;
  bool _loading = false;

  CartModel? get cart => _cart;
  bool get isLoading => _loading;

  Future<void> loadCart() async {
    _cart = await _cartService.getUserCart();
    notifyListeners();
  }

  Future<void> addToCart(ProductForCartModel item) async {
    await _cartService.addToCart(item);
    await loadCart();
  }

// 🧩 Cập nhật số lượng
  Future<void> updateItemQuantity(
      String userId, String productId, int newQuantity) async {
    await _cartService.updateItemQuantity(
      userId: userId,
      productId: productId,
      newQuantity: newQuantity,
    );
    await fetchCartByUserId(userId); // refresh lại local
  }

  // 🧩 Xóa sản phẩm
  Future<void> removeItemFromCart(String userId, String productId) async {
    await _cartService.removeItemFromCart(
      userId: userId,
      productId: productId,
    );
    await fetchCartByUserId(userId); // refresh lại local
  }

  Future<void> clearCart() async {
    await _cartService.clearCart();
    _cart = null;
    notifyListeners();
  }

  Future<void> fetchCartByUserId(String userId) async {
    try {
      _loading = true;
      notifyListeners();

      final fetchedCart = await _cartService.getCartByUserId(userId);
      _cart = fetchedCart;

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      notifyListeners();
      print('⚠️ Lỗi khi tải giỏ hàng: $e');
    }
  }

  double get totalPrice {
    if (_cart == null) return 0;
    return _cart!.items.fold(
        0,
            (sum, item) =>
        sum + (item.unitPrice - (item.unitPrice * item.discount / 100)) * item.quantity);
  }

  int get totalItems => _cart?.items.length ?? 0;
}