import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:recomart/models/order.model.dart';

class OrderService {
  final _firestore = FirebaseFirestore.instance;
  final String collection = 'orders';

  Future<void> createOrder(OrderModel order) async {
    final docRef = _firestore.collection(collection).doc();
    final orderWithId = order..id = docRef.id;

    await docRef.set(orderWithId.toJson());
  }

  Future<List<OrderModel>> fetchOrdersByUser(String userId) async {
    final snapshot = await _firestore
        .collection(collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => OrderModel.fromJson(doc.data()))
        .toList();
  }

  Future<OrderModel?> fetchOrderById(String orderId) async {
    try {
      final doc =
      await _firestore.collection(collection).doc(orderId).get();

      if (!doc.exists) {
        debugPrint('⚠️ Không tìm thấy đơn hàng có id = $orderId');
        return null;
      }

      final data = doc.data()!;
      return OrderModel.fromJson({
        ...data,
        'id': doc.id, // 🔹 Gán id từ Firestore document ID
      });
    } catch (e) {
      debugPrint('❌ [OrderService] Lỗi khi lấy đơn hàng: $e');
      return null;
    }
  }

  Future<List<OrderModel>> fetchAllOrders() async {
    try {
      final snapshot = await _firestore
          .collection(collection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return OrderModel.fromJson({
          ...data,
          'id': doc.id,
        });
      }).toList();
    } catch (e) {
      debugPrint('❌ [OrderService] Lỗi khi tải tất cả đơn hàng: $e');
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> streamAllOrders() {
    return _firestore
        .collection(collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'customerName': data['userName'] ?? 'Khách lẻ',
          'orderDate': (() {
            final raw = data['createdAt'];
            if (raw == null) return '';
            if (raw is Timestamp) return raw.toDate().toIso8601String();
            if (raw is String) return raw; // giữ nguyên nếu đã là string
            return '';
          })(),
          'totalAmount': (data['totalAmount'] as num?)?.toDouble() ?? 0,
          'discountApplied': (data['discountAmount'] as num?)?.toDouble() ?? 0,
          'status': (data['status'] ?? 'pending').toString().toUpperCase(),
          'products': (data['items'] as List<dynamic>?)
              ?.map((item) => {
            'name': item['product_name'] ?? item['productName'] ?? '',
            'quantity': item['quantity'] ?? 0,
            'unit_price': (item['unit_price'] ?? item['unitPrice']) is num
                ? (item['unit_price'] ?? item['unitPrice']).toDouble()
                : 0.0,
            'imageUrl': (item['images']?['url']) ?? '',
            'discount': (item['discount'] as num?)?.toDouble() ?? 0,
          })
              .toList() ??
              [],
        };
      }).toList();
    });
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore.collection(collection).doc(orderId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ [OrderService] Đã cập nhật trạng thái thành công: $newStatus');
    } catch (e) {
      debugPrint('❌ [OrderService] Lỗi khi cập nhật trạng thái: $e');
      rethrow;
    }
  }
}
