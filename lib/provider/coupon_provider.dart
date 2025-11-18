import 'package:flutter/material.dart';
import '../models/coupon.model.dart';
import '../services/coupon.service.dart';

class CouponProvider with ChangeNotifier {
  final CouponService _service = CouponService();
  List<CouponModel> _coupons = [];
  bool _loading = false;
  String? _error;

  List<CouponModel> get coupons => _coupons;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchCoupons() async {
    _loading = true;
    notifyListeners();
    try {
      _coupons = await _service.fetchCoupons();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addCoupon(CouponModel coupon) async {
    try {
      await _service.createCoupon(coupon);
      await fetchCoupons();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 🔹 Xóa phiếu giảm giá
  Future<void> deleteCoupon(String id) async {
    try {
      await _service.deleteCoupon(id);
      await fetchCoupons();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateCoupon(CouponModel coupon) async {
    try {
      await _service.updateCoupon(coupon);
      await fetchCoupons();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
