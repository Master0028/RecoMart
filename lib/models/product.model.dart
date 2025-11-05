import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;               // ID của document trong Firestore
  final String name;             // Tên sản phẩm
  final String description;      // Mô tả sản phẩm
  final String categoryId;       // ID danh mục
  final String brandId;
  final double price;            // Giá
  final double discount;         // Giảm giá (nếu có)
  final bool isActive;           // Còn bán không
  final String imageUrl;         // Ảnh duy nhất (Cloudinary hoặc URL)
  final double averageRating;    // Đánh giá trung bình
  final int reviewCount;         // Số lượt đánh giá
  final int stock;               // Tồn kho

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.brandId,
    required this.price,
    required this.discount,
    required this.isActive,
    required this.imageUrl,
    required this.averageRating,
    required this.reviewCount,
    required this.stock,
  });

  /// Chuyển từ Firestore DocumentSnapshot → Model
  factory ProductModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      categoryId: data['categoryId'] ?? '',
      brandId: data['brandId'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      discount: (data['discount'] ?? 0).toDouble(),
      isActive: data['isActive'] ?? true,
      imageUrl: data['imageUrl'] ?? '',
      averageRating: (data['averageRating'] ?? 0).toDouble(),
      reviewCount: (data['reviewCount'] ?? 0).toInt(),
      stock: (data['stock'] ?? 0).toInt(),
    );
  }

  /// Dùng khi đọc JSON (VD: từ Firestore hoặc REST API)
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      categoryId: json['categoryId'] ?? '',
      brandId: json['brandId'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
      imageUrl: json['imageUrl'] ?? '',
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      reviewCount: (json['reviewCount'] ?? 0).toInt(),
      stock: (json['stock'] ?? 0).toInt(),
    );
  }

  /// Dùng khi muốn convert sang Map để lưu Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'categoryId': categoryId,
      'brandId': brandId,
      'price': price,
      'discount': discount,
      'isActive': isActive,
      'imageUrl': imageUrl,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'stock': stock,
    };
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'categoryId': categoryId,
    'brandId': brandId,
    'price': price,
    'discount': discount,
    'isActive': isActive,
    'imageUrl': imageUrl,
    'averageRating': averageRating,
    'reviewCount': reviewCount,
    'stock': stock,
  };

}