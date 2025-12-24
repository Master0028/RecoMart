import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.model.dart';
import 'api_service.dart';

class ProductService {
  
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  Future<List<ProductModel>> getProducts({
    int page = 1, 
    int limit = 10,
    String? sort,
  }) async {
    try {
      String query = 'page=$page&limit=$limit';
      if (sort != null) {
        query += '&sort=$sort';
      }

      print("Calling Product API: ${ApiService.baseUrl}/api/products?$query");

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/products?$query'),
        headers: _headers, // Dùng header có bypass ngrok
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['data'] ?? [];
        
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        print("Get Products Failed: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Get Products Error: $e");
      return [];
    }
  }

  Future<List<ProductModel>> filterProducts({
    String? categoryId,
    String? brandId,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      List<String> queryParams = [];
      if (categoryId != null) queryParams.add('category=$categoryId');
      if (brandId != null) queryParams.add('brand=$brandId');
      if (minPrice != null) queryParams.add('min_price=$minPrice');
      if (maxPrice != null) queryParams.add('max_price=$maxPrice');

      String queryString = queryParams.join('&');
      final url = '${ApiService.baseUrl}/api/products/filter?$queryString';
      
      print("Calling Filter API: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['results'] ?? body['data'] ?? [];
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Filter Error: $e");
      return [];
    }
  }

  Future<ProductModel> getProductById(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/products/$productId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final data = body['data'];
        if (data['id'] == null) data['id'] = productId;
        return ProductModel.fromJson(data);
      } else {
        throw Exception('Product not found');
      }
    } catch (e) {
      throw Exception('Error fetching product detail: $e');
    }
  }

  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    return filterProducts(categoryId: categoryId);
  }

  Future<void> createProduct(ProductModel product) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/api/products'),
      headers: _headers,
      body: jsonEncode(product.toMap()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create product');
    }
  }

  Future<void> updateProduct(String id, ProductModel data) async {
    final response = await http.put(
      Uri.parse('${ApiService.baseUrl}/api/products/$id'),
      headers: _headers,
      body: jsonEncode(data.toMap()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update product');
    }
  }

  Future<void> deleteProduct(String id) async {
    final response = await http.delete(
      Uri.parse('${ApiService.baseUrl}/api/products/$id'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete product');
    }
  }
  
  Future<Map<String, String>> getCategories() async {
     return {}; 
  }
  
  Future<Map<String, String>> getBrands() async {
     return {};
  }
}