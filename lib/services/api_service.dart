import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:recomart/models/user.model.dart';

class ApiService {
  static const String baseUrl = "https://lordlier-nonmaritally-margrett.ngrok-free.dev"; 

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['detail'] ?? 'Login failed');
    }
  }

  static Future<Map<String, dynamic>> register(String email, String password, String name) async {
    final url = Uri.parse('$baseUrl/register');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },
        body: jsonEncode({
          "email": email,
          "password": password,
          "name": name,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(responseData['detail'] ?? "Registration failed");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<List<dynamic>> getProducts() async {
    final url = Uri.parse('$baseUrl/api/products/?page=1&limit=12');
      print("Requesting: GET $url");

      try {
          final response = await http.get(
              url,
              headers: {
                  'Content-Type': 'application/json',
                  'ngrok-skip-browser-warning': 'true',
              },
          );
          print("Response Status: ${response.statusCode}");
          print("Response Body: ${response.body}");

          if (response.statusCode == 200) {
              return jsonDecode(response.body)['data'];
          } else {
              throw Exception('API Error ${response.statusCode}: ${response.body}');
          }
      } catch (e) {
          print("Network Error: $e");
          rethrow;
      }
  }

  static Future<List<dynamic>> getAllUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users'),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception('Failed to load users');
    }
  }

  static Future<void> toggleUserStatus(String userId, bool isActive) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/users/$userId/status?is_active=$isActive'),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user status');
    }
  }

  static Future<void> updateUser(UserModel user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/users/${user.id}'),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode({
        "fullName": user.fullName,
        "phone": user.phone,
        "address": user.address,
        "avatar": user.avatar,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user: ${response.body}');
    }
  }

  static Future<List<dynamic>> searchProducts(String keyword) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/products/search?keyword=$keyword'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['results'] ?? [];
      } else {
        print("Search failed: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Search error: $e");
      return [];
    }
  }

  static Future<Map<String, dynamic>> chatWithAI(String query) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/products/chat'),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode({'query': query}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Chat failed: ${response.statusCode}');
    }
  }

  static Future<List<dynamic>> getSystemLogs() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/products/logs'),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data['logs'] ?? [];
    } else {
      throw Exception('Failed to load logs');
    }
  }

  static Future<void> retrainModel(String password) async {
    final url = Uri.parse('$baseUrl/api/admin/retrain?admin_secret=$password');

    print("Requesting Retrain: POST $url");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        print("Retrain triggered successfully");
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Retrain failed');
      }
    } catch (e) {
      print("Retrain Error: $e");
      rethrow;
    }
  }

  static Future<void> logInteraction(String userId, String productId, String type) async {
    final url = Uri.parse('$baseUrl/api/interaction');
    
    try {
      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          "user_id": userId,
          "product_id": productId,
          "interaction_type": type,
          "timestamp": DateTime.now().millisecondsSinceEpoch ~/ 1000,
        }),
      );
      print("Logged interaction: $type for product $productId");
    } catch (e) {
      print("Failed to log interaction: $e");
    }
  }

  static Future<Map<String, dynamic>> getUserPersona(String userId) async {
    final url = Uri.parse('$baseUrl/api/users/$userId/persona');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to load persona');
      }
    } catch (e) {
      print("Error fetching persona: $e");
      rethrow;
    }
  }
}