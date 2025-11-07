import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.model.dart';

class CategoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collection = 'categories';

  /// 🟢 Lấy danh sách danh mục
  Future<List<CategoryModel>> getCategories() async {
    final snapshot = await _db.collection(collection).orderBy('name').get();
    return snapshot.docs
        .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// 🔍 Tìm kiếm danh mục theo tên
  Future<List<CategoryModel>> searchCategories(String keyword) async {
    if (keyword.trim().isEmpty) return getCategories();

    final snapshot = await _db
        .collection(collection)
        .where('name', isGreaterThanOrEqualTo: keyword)
        .where('name', isLessThanOrEqualTo: '$keyword\uf8ff')
        .get();

    return snapshot.docs
        .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// 🔍 Lấy Firestore docId (string) theo id số
  Future<String?> getDocIdByNumericId(int numericId) async {
    final snapshot = await _db
        .collection(collection)
        .where('id', isEqualTo: numericId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.id;
    }
    return null;
  }

  /// ➕ Thêm danh mục (id tự tăng)
  Future<void> addCategory(CategoryModel category) async {
    // Lấy id lớn nhất hiện có
    final snapshot = await _db
        .collection(collection)
        .orderBy('id', descending: true)
        .limit(1)
        .get();

    int newId = 1;
    if (snapshot.docs.isNotEmpty) {
      final lastId = snapshot.docs.first.data()['id'] ?? 0;
      newId = (lastId as int) + 1;
    }

    // Tạo category mới với id kế tiếp
    final newCategory = CategoryModel(
      id: newId,
      name: category.name,
      description: category.description,
      isActive: category.isActive,
      imageUrl: category.imageUrl,
    );

    await _db.collection(collection).add(newCategory.toMap());
  }

  /// ✏️ Cập nhật danh mục
  Future<void> updateCategory(CategoryModel category, String docId) async {
    await _db.collection(collection).doc(docId).update(category.toMap());
  }

  /// 🔹 Xoá danh mục theo docId thực tế trong Firestore
  Future<void> deleteCategoryByDocId(String docId) async {
    await _db.collection(collection).doc(docId).delete();
  }

  /// 🔹 Xoá theo id số
  Future<void> deleteCategoryByNumericId(int numericId) async {
    final docId = await getDocIdByNumericId(numericId);
    if (docId != null) {
      await deleteCategoryByDocId(docId);
    } else {
      throw Exception('Không tìm thấy danh mục có id = $numericId');
    }
  }
}
