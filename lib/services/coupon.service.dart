import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../models/coupon.model.dart';

class CouponService {
  final CollectionReference _collection =
  FirebaseFirestore.instance.collection('coupons');

  /// 🔹 Lấy toàn bộ danh sách phiếu giảm giá
  Future<List<CouponModel>> fetchCoupons() async {
    final snapshot = await _collection.orderBy('createdAt', descending: true).get();
    return snapshot.docs
        .map((doc) => CouponModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  /// 🔹 Thêm phiếu giảm giá mới
  Future<void> createCoupon(CouponModel coupon) async {
    await _collection.add(coupon.toMap());
  }

  /// 🔹 Xóa phiếu giảm giá
  Future<void> deleteCoupon(String id) async {
    await _collection.doc(id).delete();
  }

  /// 🔹 Cập nhật thông tin phiếu giảm giá
  Future<bool> updateCoupon(CouponModel coupon) async {
    try {
      await _collection.doc(coupon.id).update(coupon.toMap());
      debugPrint('✅ Coupon "${coupon.code}" updated successfully!');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to update coupon: $e');
      return false;
    }
  }

  /// Cập nhật usage + thêm orderId đã dùng coupon
  Future<bool> updateCouponUsage({
    required CouponModel coupon,
    required String orderId,
  }) async {
    try {
      final docRef = _collection.doc(coupon.id);

      final updatedOrders = List<String>.from(coupon.appliedOrders);
      if (!updatedOrders.contains(orderId)) {
        updatedOrders.add(orderId);
      }

      await docRef.update({
        'usedCount': FieldValue.increment(1),
        'appliedOrders': updatedOrders,
      });

      return true;
    } catch (e) {
      print('❌ [CouponService] updateCouponUsage error: $e');
      return false;
    }
  }
}
