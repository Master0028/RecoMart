import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recomart/models/review.model.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      'createdAt': Timestamp.fromDate(review.createdAt),
      'updatedAt': Timestamp.fromDate(review.updatedAt),
    });
    await updateProductRating(productId);
  }

  Stream<List<ReviewModel>> streamReviewsByProduct(String productId) {
    print('📡 Streaming reviews for productId: $productId');

    return _firestore
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      print('Found ${snapshot.docs.length} reviews');
      for (var doc in snapshot.docs) {
        print('${doc.id} => ${doc.data()}');
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

  Future<void> updateProductRating(String productId) async {
    final productRef = _firestore.collection('products').doc(productId);
    final reviewsSnapshot = await productRef.collection('reviews').get();

    if (reviewsSnapshot.docs.isEmpty) {
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

    await productRef.update({
      'averageRating': double.parse(averageRating.toStringAsFixed(1)),
      'reviewCount': reviewCount,
    });

    print('Updated product $productId → avg: $averageRating | count: $reviewCount');
  }

  int _parseRating(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

}
