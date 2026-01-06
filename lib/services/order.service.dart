import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/order.model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String baseUrl =
      'https://lordlier-nonmaritally-margrett.ngrok-free.dev';

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      };

  Future<OrderModel> createOrder(OrderModel order) async {
    final body = order.toJson();

    print('--- [ORDER CREATE] PAYLOAD ---');
    print(jsonEncode(body));

    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return OrderModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Create order failed: ${response.body}');
    }
  }

  Future<List<OrderModel>> fetchOrdersByUser(String userId) async {
    final url = Uri.parse('$baseUrl/orders/history?userId=$userId');
    print('--- [ORDER HISTORY] Requesting: $url');

    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => OrderModel.fromJson(e)).toList();
    } else {
      throw Exception(
        'Failed to fetch order history [${response.statusCode}]: ${response.body}',
      );
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
      throw Exception(
        'Failed to fetch order detail [${response.statusCode}]: ${response.body}',
      );
    }
  }

  Future<void> cancelOrder(String orderId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/orders/$orderId/cancel'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to cancel order [${response.statusCode}]: ${response.body}',
      );
    }
  }

  Future<void> returnOrder(String orderId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/orders/$orderId/return'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to return order [${response.statusCode}]: ${response.body}',
      );
    }
  }

  Stream<List<OrderModel>> streamUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return OrderModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    });
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({
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
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    });
  }
}
