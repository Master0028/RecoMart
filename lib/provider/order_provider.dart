import 'package:flutter/material.dart';
import '../models/order.model.dart';
import '../pattern/singleton.dart';
import '../services/order.service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<OrderModel> _orders = [];
  OrderModel? _selectedOrder;

  bool _isLoading = false;
  bool _hasFetched = false;
  String? _errorMessage;

  List<OrderModel> get orders => _orders;
  OrderModel? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  bool get hasFetched => _hasFetched;
  String? get errorMessage => _errorMessage;

  String _requireUserId() {
    final uid = UserSession.instance.userId;
    if (uid == null || uid.isEmpty) {
      throw Exception("User not logged in");
    }
    return uid;
  }

  Future<bool> placeOrder(OrderModel order) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uid = _requireUserId();

      await _orderService.createOrder(
        order.copyWith(userId: uid),
      );

      await fetchOrderHistory(uid, force: true);
      return true;
    } catch (e) {
      _errorMessage = "Order failed: $e";
      debugPrint('[OrderProvider] placeOrder error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> fetchOrderHistory(
      String? userId, {
        bool force = false,
      }) async {
    final uid = userId;

    if (uid == null || uid.isEmpty) {
      debugPrint("--- [PROVIDER] Skipped: userId is not ready");
      return;
    }

    if (_hasFetched && !force) {
      debugPrint("--- [PROVIDER] Skipped: already fetched");
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _orderService.fetchOrdersByUser(uid);
      _hasFetched = true;
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
      _errorMessage = "Could not load order details: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelOrder(String orderId) async {
    await _updateOrderWithStatus(orderId, 'CANCELLED', () {
      return _orderService.cancelOrder(orderId);
    });
  }

  Future<void> returnOrder(String orderId) async {
    await _updateOrderWithStatus(orderId, 'RETURNED', () {
      return _orderService.returnOrder(orderId);
    });
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

  Future<void> _updateOrderWithStatus(
    String orderId,
    String status,
    Future<void> Function() action,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      _updateLocalStatus(orderId, status);
    } catch (e) {
      _errorMessage = e.toString();
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
  }

  void clearSelectedOrder() {
    _selectedOrder = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearAll() {
    _orders = [];
    _selectedOrder = null;
    _hasFetched = false;
    _errorMessage = null;
    notifyListeners();
  }

  Stream<List<OrderModel>> streamUserOrders() {
    final uid = UserSession.instance.userId;
    if (uid == null) return const Stream.empty();
    return _orderService.streamUserOrders(uid);
  }
}
