import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart.model.dart';

class CartService {
  final _cartCollection = FirebaseFirestore.instance.collection('cart');

  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  /// 🧠 Lấy giỏ hàng của user hiện tại
  Future<CartModel?> getUserCart() async {
    if (_userId.isEmpty) return null;

    final doc = await _cartCollection.doc(_userId).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    return CartModel.fromMap({
      '_id': doc.id,
      'user_id': data['userId'],
      'items': data['items'] ?? [],
    });
  }

  /// 🛒 Thêm sản phẩm vào giỏ hàng (tăng quantity nếu đã tồn tại)
  Future<void> addToCart(ProductForCartModel newItem) async {
    if (_userId.isEmpty) throw Exception("Người dùng chưa đăng nhập");

    final docRef = _cartCollection.doc(_userId);
    final doc = await docRef.get();

    List<ProductForCartModel> items = [];

    if (doc.exists) {
      final data = doc.data()!;
      final rawItems = (data['items'] as List<dynamic>? ?? []);
      items = rawItems
          .map((e) => ProductForCartModel.fromMap(e as Map<String, dynamic>))
          .toList();
    }

    // Kiểm tra sản phẩm đã có chưa
    final existingIndex = items.indexWhere((i) => i.productId == newItem.productId);

    if (existingIndex >= 0) {
      items[existingIndex].quantity += newItem.quantity;
    } else {
      items.add(newItem);
    }

    // Cập nhật Firestore
    await docRef.set({
      'userId': _userId,
      'items': items.map((e) => e.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateItemQuantity({
    required String userId,
    required String productId,
    required int newQuantity,
  }) async {
    final query = await _cartCollection
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return;

    final docRef = query.docs.first.reference;
    final data = query.docs.first.data();
    final items = List<Map<String, dynamic>>.from(data['items'] ?? []);

    for (var item in items) {
      if (item['product_id'] == productId) {
        item['quantity'] = newQuantity;
        break;
      }
    }

    await docRef.update({
      'items': items,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // 🧩 Xóa sản phẩm khỏi giỏ hàng
  Future<void> removeItemFromCart({
    required String userId,
    required String productId,
  }) async {
    final query = await _cartCollection
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return;

    final docRef = query.docs.first.reference;
    final data = query.docs.first.data();
    final items = List<Map<String, dynamic>>.from(data['items'] ?? []);

    items.removeWhere((item) => item['product_id'] == productId);

    await docRef.update({
      'items': items,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// 🧺 Xóa toàn bộ giỏ
  Future<void> clearCart() async {
    await _cartCollection.doc(_userId).delete();
  }

  Future<CartModel?> getCartByUserId(String userId) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('cart')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      final data = query.docs.first.data();
      return CartModel.fromMap(data);
    } catch (e) {
      print('❌ Lỗi lấy giỏ hàng: $e');
      rethrow;
    }
  }
}