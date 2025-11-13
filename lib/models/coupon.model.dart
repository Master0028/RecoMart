import 'package:cloud_firestore/cloud_firestore.dart';

class CouponModel {
  final String id;
  final String code;
  final double discountValue;
  final int maxUsage;
  final int usedCount;
  final Timestamp createdAt;
  final List<String> appliedOrders;

  CouponModel({
    required this.id,
    required this.code,
    required this.discountValue,
    required this.maxUsage,
    required this.usedCount,
    required this.createdAt,
    required this.appliedOrders,
  });

  factory CouponModel.fromMap(Map<String, dynamic> data, String docId) {
    return CouponModel(
      id: docId,
      code: data['code'] ?? '',
      discountValue: (data['discountValue'] ?? 0).toDouble(),
      maxUsage: data['maxUsage'] ?? 0,
      usedCount: data['usedCount'] ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      appliedOrders: List<String>.from(data['appliedOrders'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'discountValue': discountValue,
      'maxUsage': maxUsage,
      'usedCount': usedCount,
      'createdAt': createdAt,
      'appliedOrders': appliedOrders,
    };
  }

  CouponModel copyWith({
    int? usedCount,
    List<String>? appliedOrders,
  }) {
    return CouponModel(
      id: id,
      code: code,
      discountValue: discountValue,
      maxUsage: maxUsage,
      usedCount: usedCount ?? this.usedCount,
      createdAt: createdAt,
      appliedOrders: appliedOrders ?? this.appliedOrders,
    );
  }
}