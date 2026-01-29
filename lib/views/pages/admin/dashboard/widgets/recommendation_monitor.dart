import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AiRecommendationTestWidget extends StatefulWidget {
  @override
  _AiRecommendationTestWidgetState createState() => _AiRecommendationTestWidgetState();
}

class _AiRecommendationTestWidgetState extends State<AiRecommendationTestWidget> {
  final TextEditingController _userIdController = TextEditingController();
  List<dynamic> _recommendations = [];
  bool _isLoading = false;
  String _status = "";

  final String apiUrl = "https://lordlier-nonmaritally-margrett.ngrok-free.dev/api/recommend";
  //static String get apiUrl => dotenv.env['API_URL'] ?? "https://my-fastapi-app-0pub.onrender.com";

  Future<void> _getRecommendations() async {
    String userId = _userIdController.text.trim();
    if (userId.isEmpty) {
      setState(() => _status = "Please enter a User ID.");
      return;
    }

    setState(() {
      _isLoading = true;
      _status = "Calling AI...";
      _recommendations = [];
    });

    try {
      final response = await http.get(
        Uri.parse('$apiUrl/$userId'),
        headers: {
          "ngrok-skip-browser-warning": "true",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        setState(() {
          if (data['recommendations'] is List) {
            _recommendations = data['recommendations'];
            _status = "Found ${_recommendations.length} products (Source: ${data['source']})"; // Translated
          } else {
             _status = "API Error: Invalid response format.";
          }
        });
      } else {
        setState(() {
          _status = "API Error: ${response.statusCode}"; // Translated
        });
      }
    } catch (e) {
      debugPrint("Connection Error: $e"); // Fix: Using debugPrint
      setState(() {
        _status = "Connection Error: $e"; // Translated
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Widget to display animated status text
  Widget _buildStatusText() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        // Simple Fade Transition
        return FadeTransition(opacity: animation, child: child);
      },
      child: Text(
        _status,
        key: ValueKey(_status), // Key forces AnimatedSwitcher to rebuild when _status changes
        style: TextStyle(color: Colors.grey[700]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Test AI Recommendation", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _userIdController,
                    decoration: const InputDecoration(
                      labelText: "Enter User ID (e.g., 1)", // Translated
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _getRecommendations,
                  icon: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                      : const Icon(Icons.search),
                  label: const Text("Get Recommendations"), // Translated
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            // Animated Status
            _buildStatusText(), 

            const SizedBox(height: 10),
            
            // Animated Results List
            if (_recommendations.isNotEmpty)
              AnimatedOpacity(
                opacity: _recommendations.isNotEmpty ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Container(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _recommendations.length,
                    itemBuilder: (context, index) {
                      final item = _recommendations[index];
                      return Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shopping_bag, size: 40, color: Colors.blue),
                            const SizedBox(height: 5),
                            Text(
                              "ID: ${item['id']}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                item['name'] ?? "Unknown Product", // Translated
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}