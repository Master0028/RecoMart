import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  final _orderRef = FirebaseFirestore.instance.collection("orders");
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String baseUrl = 'https://lordlier-nonmaritally-margrett.ngrok-free.dev';

  Future<void> createOrder(OrderModel order) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(order.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Create order failed');
    }
  }

  Future<List<OrderModel>> fetchOrdersByUser(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/history?userId=$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Fetch order history failed');
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => OrderModel.fromJson(e)).toList();
  }

  Future<OrderModel> fetchOrderById(String orderId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$orderId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Fetch order detail failed');
    }

    return OrderModel.fromJson(jsonDecode(response.body));
  }

  Future<void> cancelOrder(String orderId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$orderId/cancel'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Cancel order failed');
    }
  }

  Future<void> returnOrder(String orderId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$orderId/return'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Return order failed');
    }
  }

  Stream<List<Map<String, dynamic>>> streamAllOrders() {
    return _orderRef
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

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _orderRef.doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<OrderModel>> streamUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList();
        });
  }
}