import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart.model.dart';

class CartService {
  final CollectionReference _cartCollection =
      FirebaseFirestore.instance.collection('cart');

  Future<CartModel?> getCartByUserId(String userId) async {
    if (userId.isEmpty) return null;

    final doc = await _cartCollection.doc(userId).get();
    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>;
    return CartModel.fromMap({
      ...data,
      '_id': doc.id,
    });
  }

  Future<void> addToCart({
    required String userId,
    required ProductForCartModel item,
  }) async {
    if (userId.isEmpty) {
      throw Exception('User not logged in');
    }

    final docRef = _cartCollection.doc(userId);
    final doc = await docRef.get();

    List<ProductForCartModel> items = [];

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      items = (data['items'] as List<dynamic>? ?? [])
          .map((e) => ProductForCartModel.fromMap(e))
          .toList();
    }

    final index =
        items.indexWhere((e) => e.productId == item.productId);

    if (index >= 0) {
      items[index].quantity += item.quantity;
    } else {
      items.add(item);
    }

    await docRef.set({
      'userId': userId,
      'items': items.map((e) => e.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateItemQuantity({
    required String userId,
    required String productId,
    required int newQuantity,
  }) async {
    final docRef = _cartCollection.doc(userId);
    final doc = await docRef.get();
    if (!doc.exists) return;

    final data = doc.data() as Map<String, dynamic>;
    final items = List<Map<String, dynamic>>.from(data['items'] ?? []);

    for (final item in items) {
      if (item['productId'] == productId) {
        item['quantity'] = newQuantity;
        break;
      }
    }

    await docRef.update({
      'items': items,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeItemFromCart({
    required String userId,
    required String productId,
  }) async {
    final docRef = _cartCollection.doc(userId);
    final doc = await docRef.get();
    if (!doc.exists) return;

    final data = doc.data() as Map<String, dynamic>;
    final items = List<Map<String, dynamic>>.from(data['items'] ?? []);

    items.removeWhere((e) => e['productId'] == productId);

    await docRef.update({
      'items': items,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> clearCart(String userId) async {
    if (userId.isEmpty) return;
    await _cartCollection.doc(userId).delete();
  }
}