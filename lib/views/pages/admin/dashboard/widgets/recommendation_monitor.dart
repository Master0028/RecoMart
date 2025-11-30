import 'package:flutter/material.dart';
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

  final String apiUrl = "https://YOUR-NGROK-URL.ngrok-free.app/api/recommend";

  Future<void> _getRecommendations() async {
    String userId = _userIdController.text;
    if (userId.isEmpty) return;

    setState(() {
      _isLoading = true;
      _status = "Đang gọi AI...";
      _recommendations = [];
    });

    try {
      final response = await http.get(Uri.parse('$apiUrl/$userId'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _recommendations = data['recommendations'];
          _status = "Tìm thấy ${_recommendations.length} sản phẩm (Nguồn: ${data['source']})";
        });
      } else {
        setState(() {
          _status = "Lỗi API: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _status = "Lỗi kết nối: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Test AI Recommendation", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _userIdController,
                    decoration: InputDecoration(
                      labelText: "Nhập User ID (ví dụ: 1)",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _getRecommendations,
                  icon: _isLoading ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Icon(Icons.search),
                  label: Text("Gợi ý"),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(_status, style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 10),
            if (_recommendations.isNotEmpty)
              Container(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _recommendations.length,
                  itemBuilder: (context, index) {
                    final item = _recommendations[index];
                    return Container(
                      width: 120,
                      margin: EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_bag, size: 40, color: Colors.blue),
                          SizedBox(height: 5),
                          Text(
                            "ID: ${item['id']}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              item['name'] ?? "Unknown",
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}