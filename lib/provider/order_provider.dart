import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:recomart/models/order.model.dart';
import 'package:recomart/services/order.service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchOrders() async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('Không có user đăng nhập!');
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      debugPrint('[OrderProvider] Đang tải đơn hàng cho user.uid = ${user.uid}');

      _orders = await _orderService.fetchOrdersByUser(user.uid);

      debugPrint('[OrderProvider] Tải thành công ${_orders.length} đơn hàng.');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      debugPrint('[OrderProvider] Lỗi khi tải đơn hàng: $e');
      notifyListeners();
    }
  }
}
