import 'package:cloud_firestore/cloud_firestore.dart';

class BrandModel {
  final String id;
  final String name;
  final bool isActive;
  final String imageUrl;

  BrandModel({
    required this.id,
    required this.name,
    required this.isActive,
    required this.imageUrl,
  });

  /// Chuyển từ Firestore hoặc JSON thành CategoryModel
  factory BrandModel.fromMap(Map<String, dynamic> data, String documentId) {
    return BrandModel(
      id: documentId,
      name: data['name'] ?? '',
      isActive: data['isActive'] ?? true,
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  /// Chuyển ngược lại sang Map để lưu lên Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isActive': isActive,
      'imageUrl': imageUrl,
    };
  }

  Map<String, dynamic> toJson() => toMap();
}
