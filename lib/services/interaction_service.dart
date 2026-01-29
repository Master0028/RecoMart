import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/interaction_model.dart';

class InteractionService{
  static const String baseUrl = 'https://lordlier-nonmaritally-margrett.ngrok-free.dev';
  //static String get baseUrl => dotenv.env['API_URL'] ?? "https://my-fastapi-app-0pub.onrender.com";
  Future<void> logInteraction(InteractionModel model) async {
    final url = Uri.parse('$baseUrl/interaction');
    
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": model.userId,
        "product_id": model.productId,
        "interaction_type": model.type.toString().split('.').last,
        "duration": model.duration,
        "source": "mobile"
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to log interaction: ${response.body}");
    }
  }
}