import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ProductModel>> getProducts() async {
    try {
      final snapshot = await _firestore.collection('products').get();

      return snapshot.docs.map((doc) {
        // Lấy id từ doc.id
        final data = doc.data();
        return ProductModel.fromSnapshot(doc);
      }).toList();
    } catch (e) {
      print('❌ Lỗi khi lấy sản phẩm: $e');
      return [];
    }
  }

  Future<ProductModel> getProductById(String id) async {
    final doc = await FirebaseFirestore.instance.collection('products').doc(id).get();
    if (!doc.exists) throw Exception('Không tìm thấy sản phẩm!');
    return ProductModel.fromSnapshot(doc);
  }

  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    final query = await FirebaseFirestore.instance
        .collection('products')
        .where('categoryId', isEqualTo: categoryId)
        .get();

    return query.docs.map((d) => ProductModel.fromSnapshot(d)).toList();
  }
}