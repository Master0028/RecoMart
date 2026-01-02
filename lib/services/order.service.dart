import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String baseUrl = 'https://lordlier-nonmaritally-margrett.ngrok-free.dev';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'accept': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  Future<void> createOrder(OrderModel order) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: _headers,
      body: jsonEncode({
        'userId': order.userId,
        'totalAmount': order.totalAmount,
        'status': order.status,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create order: ${response.body}');
    }
  }

  Future<List<OrderModel>> fetchOrdersByUser(String userId) async {
    final url = Uri.parse('$baseUrl/orders/history?userId=$userId');
    print('--- [SERVICE] Requesting: $url');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      print('--- [SERVICE] Raw Response: ${response.body}');
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => OrderModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch order history');
    }
  }

  Future<OrderModel> fetchOrderById(String orderId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/$orderId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return OrderModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch order details');
    }
  }

  Future<void> cancelOrder(String orderId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/orders/$orderId/cancel'),
      headers: _headers,
    );
    if (response.statusCode != 200) throw Exception('Failed to cancel order');
  }

  Future<void> returnOrder(String orderId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/orders/$orderId/return'),
      headers: _headers,
    );
    if (response.statusCode != 200) throw Exception('Failed to return order');
  }

  Stream<List<OrderModel>> streamUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => OrderModel.fromJson({...doc.data(), 'id': doc.id}))
              .toList();
        });
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection("orders").doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> streamAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              ...data,
            };
          }).toList();
        });
  }
}