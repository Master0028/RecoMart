import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<CategoryModel>> getCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return CategoryModel(
          id: doc.id,
          name: data['name'] ?? '',
          image: CategoryImage(
            publicId: data['publicId'] ?? '',
            url: data['imageUrl'] ?? '',
          ),
          isActive: data['isActive'] ?? true,
        );
      }).toList();
    } catch (e) {
      print('❌ Lỗi khi tải category: $e');
      return [];
    }
  }
}
