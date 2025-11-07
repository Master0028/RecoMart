import 'package:cloud_firestore/cloud_firestore.dart';
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
  Future<void> updateCoupon(CouponModel coupon) async {
    await _collection.doc(coupon.id).update(coupon.toMap());
  }
}
