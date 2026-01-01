import 'package:flutter/material.dart';
import '../models/order.model.dart';
import '../services/order.service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<OrderModel> _orders = [];
  OrderModel? _selectedOrder;

  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get orders => _orders;
  OrderModel? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchOrderHistory() async {
    final user = _auth.currentUser;
    if (user == null) {
      _orders = [];
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      _orders = await _orderService.fetchOrdersByUser(user.uid);

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrderDetail(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedOrder = await _orderService.fetchOrderById(orderId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelOrder(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _orderService.cancelOrder(orderId);

      updateOrderStatus(orderId, 'CANCELLED');
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> returnOrder(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _orderService.returnOrder(orderId);

      updateOrderStatus(orderId, 'RETURNED');
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedOrder() {
    _selectedOrder = null;
    notifyListeners();
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _orderService.updateOrderStatus(orderId, newStatus);
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
      }

      if (_selectedOrder?.id == orderId) {
        _selectedOrder = _selectedOrder!.copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint('[OrderProvider] updateOrderStatus error: $e');
      rethrow;
    }
  }

  Stream<List<OrderModel>> streamUserOrders(String userId) {
    return _orderService.streamUserOrders(userId);
  }
}