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

  Future<bool> placeOrder(OrderModel order) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _orderService.createOrder(order);
      if (order.userId != null) {
        await fetchOrderHistory(order.userId!);
      }
      return true;
    } catch (e) {
      _errorMessage = "Order failed: ${e.toString()}";
      debugPrint('[OrderProvider] placeOrder error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrderHistory(String? userId) async {
    if (userId == null || userId.isEmpty || userId == "null") {
      debugPrint("--- [PROVIDER] Skipped: userId is not ready");
      return; 
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint("--- [PROVIDER] Fetching API for ID: $userId");
      _orders = await _orderService.fetchOrdersByUser(userId);
      debugPrint("--- [PROVIDER] Success: ${_orders.length} orders found");
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("--- [PROVIDER] Parse Error: $e");
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
      _errorMessage = "Could not load order details: ${e.toString()}";
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
      _updateLocalStatus(orderId, 'CANCELLED');
    } catch (e) {
      _errorMessage = "Could not cancel order: ${e.toString()}";
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
      _updateLocalStatus(orderId, 'RETURNED');
    } catch (e) {
      _errorMessage = "Could not request return: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateLocalStatus(String orderId, String newStatus) {
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
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _orderService.updateOrderStatus(orderId, newStatus);
      _updateLocalStatus(orderId, newStatus);
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('[OrderProvider] updateOrderStatus error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedOrder() {
    _selectedOrder = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Stream<List<OrderModel>> streamUserOrders(String userId) {
    return _orderService.streamUserOrders(userId);
  }
}