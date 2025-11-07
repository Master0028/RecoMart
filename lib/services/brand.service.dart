import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/brand.model.dart';

class BrandService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collection = 'brands';

  /// 🔹 Lấy tất cả thương hiệu
  Future<List<BrandModel>> fetchBrands() async {
    final snapshot = await _db.collection(collection).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return BrandModel.fromMap(data, doc.id);
    }).toList();
  }

  /// 🔹 Thêm thương hiệu (Firestore tự sinh docId)
  Future<void> addBrand(BrandModel brand) async {
    await _db.collection(collection).add(brand.toMap());
  }

  /// 🔹 Cập nhật thương hiệu theo docId
  Future<void> updateBrand(BrandModel brand) async {
    await _db.collection(collection).doc(brand.id).update(brand.toMap());
  }

  /// 🔹 Xoá thương hiệu theo docId
  Future<void> deleteBrand(String id) async {
    await _db.collection(collection).doc(id).delete();
  }

  /// 🔹 Tìm kiếm thương hiệu theo tên
  Future<List<BrandModel>> searchBrands(String keyword) async {
    final snapshot = await _db
        .collection(collection)
        .where('name', isGreaterThanOrEqualTo: keyword)
        .where('name', isLessThanOrEqualTo: '$keyword\uf8ff')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return BrandModel.fromMap(data, doc.id);
    }).toList();
  }
}
