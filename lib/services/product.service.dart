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

  /// 🔹 Lấy sản phẩm theo trang (page, limit)
  Future<List<ProductModel>> getProductsPaginated({
    required int page,
    required int limit,
  }) async {
    final snapshot = await FirebaseFirestore.instance.collection('products')
        .orderBy('name') // hoặc 'createdAt' nếu bạn có trường này
        .limit(limit)
        .get();

    if (page > 1) {
      final lastDocIndex = (page - 1) * limit;
      final allDocs = await FirebaseFirestore.instance.collection('products')
          .orderBy('name')
          .limit(lastDocIndex + limit)
          .get();
      final slice = allDocs.docs.skip(lastDocIndex).take(limit).toList();
      return slice.map((doc) => ProductModel.fromSnapshot(doc)).toList();
    }

    return snapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
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


  /// 🔹 Tạo mới sản phẩm
  Future<void> createProduct(ProductModel product) async {
    await FirebaseFirestore.instance
        .collection('products').add(product.toMap());
  }

  /// 🔹 Cập nhật sản phẩm
  Future<void> updateProduct(String id, ProductModel data) async {
    await FirebaseFirestore.instance
        .collection('products').doc(id).update(data.toMap());
  }

  /// 🔹 Xóa sản phẩm
  Future<void> deleteProduct(String id) async {
    await FirebaseFirestore.instance
        .collection('products').doc(id).delete();
  }

  /// 🔹 Lấy danh sách danh mục (categories)
  Future<Map<String, String>> getCategories() async {
    try {
      final snapshot = await  FirebaseFirestore.instance.collection('categories').get();
      return {
        for (var doc in snapshot.docs) doc.id: doc['name'] ?? 'Unknown',
      };
    } catch (e) {
      throw Exception('Lỗi tải categories: $e');
    }
  }

  /// 🔹 Lấy danh sách thương hiệu (brands)
  Future<Map<String, String>> getBrands() async {
    try {
      final snapshot = await  FirebaseFirestore.instance.collection('brands').get();
      return {
        for (var doc in snapshot.docs) doc.id: doc['name'] ?? 'Unknown',
      };
    } catch (e) {
      throw Exception('Lỗi tải brands: $e');
    }
  }

  Future<List<ProductModel>> getProductsWithPagination({
    int limit = 10,
    DocumentSnapshot? lastDoc,
    String? categoryId,
    String? brandId,
    double? minPrice,
    double? maxPrice,
    double? minRating,
  }) async {
    Query query = FirebaseFirestore.instance
        .collection('products')
        .where('isActive', isEqualTo: true)
        .orderBy('price', descending: false)
        .limit(limit);

    // --- Apply filters ---
    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }
    if (brandId != null && brandId.isNotEmpty) {
      query = query.where('brandId', isEqualTo: brandId);
    }
    if (minPrice != null && maxPrice != null) {
      query = query
          .where('price', isGreaterThanOrEqualTo: minPrice)
          .where('price', isLessThanOrEqualTo: maxPrice);
    }
    if (minRating != null) {
      query = query.where('averageRating', isGreaterThanOrEqualTo: minRating);
    }

    // --- Pagination ---
    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    final snapshot = await query.get();

    return snapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
  }
}