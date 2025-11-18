import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.model.dart';

class CategoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collection = 'categories';

  Future<List<CategoryModel>> getCategories() async {
    final snapshot = await _db.collection(collection).orderBy('name').get();
    return snapshot.docs
        .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
        .toList();
  }

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

  Future<void> addCategory(CategoryModel category) async {
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

    final newCategory = CategoryModel(
      id: newId,
      name: category.name,
      description: category.description,
      isActive: category.isActive,
      imageUrl: category.imageUrl,
    );

    await _db.collection(collection).add(newCategory.toMap());
  }

  Future<void> updateCategory(CategoryModel category, String docId) async {
    await _db.collection(collection).doc(docId).update(category.toMap());
  }

  Future<void> deleteCategoryByDocId(String docId) async {
    await _db.collection(collection).doc(docId).delete();
  }

  Future<void> deleteCategoryByNumericId(int numericId) async {
    final docId = await getDocIdByNumericId(numericId);
    if (docId != null) {
      await deleteCategoryByDocId(docId);
    } else {
      throw Exception('Không tìm thấy danh mục có id = $numericId');
    }
  }
}
