import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recommendation_model.dart'; 

class RecommendationService {
  static const String baseUrl = "https://lordlier-nonmaritally-margrett.ngrok-free.dev"; 

  Future<List<ProductRecommendation>> getRecommendations(int userId) async {
    final String url = '$baseUrl/api/recommend/$userId';
    
    try {
      print("Đang gọi API: $url");
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "ngrok-skip-browser-warning": "true",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        print("Response Body: ${response.body}"); 
        
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        List<dynamic> list = data['recommendations'];
        
        return list.map((item) => ProductRecommendation.fromJson(item)).toList();
      } else {
        print("Lỗi Server: ${response.statusCode}");
        print("Nội dung lỗi: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Lỗi Kết nối: $e");
      return [];
    }
  }

  Future<List<ProductRecommendation>> getSimilarProducts(String productId) async {
    final String url = '$baseUrl/chatbot/similar/$productId';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "ngrok-skip-browser-warning": "true",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> list = data['results']; 
        return list.map((item) => ProductRecommendation.fromJson(item)).toList();
      } else {
        print("Lỗi Server Similar: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Lỗi Kết nối Similar: $e");
      return [];
    }
  }
}
