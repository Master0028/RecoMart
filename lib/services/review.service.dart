import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recomart/models/review.model.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🟢 Thêm review mới vào subcollection "reviews" của sản phẩm
  Future<void> addReviewForProduct(String productId, ReviewModel review) async {
    final reviewRef = _firestore
        .collection('products')
        .doc(productId)
        .collection('reviews');

    await reviewRef.add({
      'productId': productId,
      'userId': review.userId,
      'content': review.content,
      'rating': review.rating,
      'user': review.user?.toMap(),
      'createdAt': Timestamp.fromDate(review.createdAt), // ✅ Firestore format
      'updatedAt': Timestamp.fromDate(review.updatedAt),
    });
    await updateProductRating(productId);
  }

  /// 🟢 Lấy review realtime theo sản phẩm (hiển thị ngay sau khi thêm)
  Stream<List<ReviewModel>> streamReviewsByProduct(String productId) {
    print('📡 Streaming reviews for productId: $productId');

    return _firestore
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      print('📦 Found ${snapshot.docs.length} reviews');
      for (var doc in snapshot.docs) {
        print('📝 ${doc.id} => ${doc.data()}');
      }

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ReviewModel(
          id: doc.id,
          productId: data['productId'] ?? '',
          userId: data['userId'],
          content: data['content'] ?? '',
          rating: _parseRating(data['rating']),
          user: data['user'] != null
              ? UserModelForReview.fromMap(Map<String, dynamic>.from(data['user']))
              : null,
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          updatedAt: (data['updatedAt'] as Timestamp).toDate(),
        );
      }).toList();
    });
  }

  /// 🟢 Cập nhật averageRating và reviewCount của sản phẩm sau khi thêm review
  Future<void> updateProductRating(String productId) async {
    final productRef = _firestore.collection('products').doc(productId);
    final reviewsSnapshot = await productRef.collection('reviews').get();

    if (reviewsSnapshot.docs.isEmpty) {
      // Nếu chưa có đánh giá nào, reset về 0
      await productRef.update({
        'averageRating': 0.0,
        'reviewCount': 0,
      });
      return;
    }

    // Tính tổng điểm và số lượng
    double totalRating = 0;
    for (final doc in reviewsSnapshot.docs) {
      final data = doc.data();
      final rating = _parseRating(data['rating']);
      totalRating += rating.toDouble();
    }

    final reviewCount = reviewsSnapshot.docs.length;
    final averageRating = totalRating / reviewCount;

    // ✅ Cập nhật vào document sản phẩm
    await productRef.update({
      'averageRating': double.parse(averageRating.toStringAsFixed(1)),
      'reviewCount': reviewCount,
    });

    print('✅ Updated product $productId → avg: $averageRating | count: $reviewCount');
  }

  /// Helper: đảm bảo rating luôn là số
  int _parseRating(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

}
