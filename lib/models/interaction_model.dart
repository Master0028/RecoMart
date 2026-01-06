import 'package:cloud_firestore/cloud_firestore.dart';

enum InteractionType {
  click,
  longView,
  addToCart,
  buyNow,
  purchase,
}

class InteractionModel {
  final String userId;
  final String productId;
  final InteractionType type;
  final int duration;
  final DateTime createdAt;

  InteractionModel({
    required this.userId,
    required this.productId,
    required this.type,
    this.duration = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'productId': productId,
      'type': type.name,
      'duration': duration,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory InteractionModel.fromJson(Map<String, dynamic> json) {
    return InteractionModel(
      userId: json['userId'] ?? '',
      productId: json['productId'] ?? '',
      type: InteractionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => InteractionType.click,
      ),
      duration: json['duration'] ?? 0,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }
}