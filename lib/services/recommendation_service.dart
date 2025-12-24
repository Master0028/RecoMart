import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/recommendation_model.dart';

class RecommendationService {
  static const String baseUrl = "https://lordlier-nonmaritally-margrett.ngrok-free.dev";

  Future<List<ProductRecommendation>> getRecommendations(int userId) async {
    final String url = '$baseUrl/api/recommend/$userId';

    try {
      debugPrint("Calling Recommend API: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "ngrok-skip-browser-warning": "true",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> list = data['recommendations'] ?? [];
        return list.map((item) => ProductRecommendation.fromJson(item)).toList();
      } else {
        debugPrint("Recommend Server Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("Recommend Connection Error: $e");
      return [];
    }
  }

  Future<List<ProductRecommendation>> getSimilarProducts(String productId) async {
    final String url = '$baseUrl/api/products/similar/$productId';

    try {
      debugPrint("Calling Similar API: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "ngrok-skip-browser-warning": "true",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> list = data['results'] ?? [];
        return list.map((item) => ProductRecommendation.fromJson(item)).toList();
      } else {
        debugPrint("Similar Server Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("Similar Connection Error: $e");
      return [];
    }
  }
}