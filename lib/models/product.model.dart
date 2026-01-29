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
  final List<Map<String, dynamic>> reviews; // Danh sách đánh giá người dùng
  final Timestamp? createdAt;
  String? brandName;
  String? categoryName;

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
    this.reviews = const [],
    this.createdAt,
    this.brandName,
    this.categoryName
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
      brandName: data['brandName'] ?? 'Unknown', 
      categoryName: data['categoryName'] ?? 'Unknown',
      price: (data['price'] ?? 0).toDouble(),
      discount: (data['discount'] ?? 0).toDouble(),
      isActive: data['isActive'] ?? true,
      imageUrl: data['imageUrl'] ?? '',
      averageRating: (data['averageRating'] ?? 0).toDouble(),
      reviewCount: (data['reviewCount'] ?? 0).toInt(),
      stock: (data['stock'] ?? 0).toInt(),
      reviews: (data['reviews'] is List)
          ? List<Map<String, dynamic>>.from(
          (data['reviews'] as List).map((r) => Map<String, dynamic>.from(r)))
          : [],
      createdAt: data['createdAt'] is Timestamp ? data['createdAt'] : null,
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
      brandName: json['brandName'] ?? 'Unknown',
      categoryName: json['categoryName'] ?? 'Unknown',
      price: (json['price'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
      imageUrl: json['imageUrl'] ?? '',
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      reviewCount: (json['reviewCount'] ?? 0).toInt(),
      stock: (json['stock'] ?? 0).toInt(),
      reviews: (json['reviews'] is List)
          ? List<Map<String, dynamic>>.from(
          (json['reviews'] as List).map((r) => Map<String, dynamic>.from(r)))
          : [],
      createdAt: json['createdAt'] is Timestamp ? json['createdAt'] : null,
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
      'reviews': reviews,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
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
    'reviews': reviews,
    'createdAt': createdAt ?? FieldValue.serverTimestamp(),
  };

  Map<String, dynamic> toApiMap() {
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

      'createdAt': createdAt?.toDate().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    T _numAs<T extends num>(dynamic v, T fallback) {
      if (v is num) return (T == int ? v.toInt() : v.toDouble()) as T;
      if (v is String) {
        final p = (T == int) ? int.tryParse(v) : double.tryParse(v);
        return (p ?? fallback) as T;
      }
      return fallback;
    }

    return ProductModel(
      id: docId ?? (map['id'] as String? ?? ''),
      name: map['name'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      categoryId: map['categoryId'] as String? ?? '',
      brandId: map['brandId'] as String? ?? '',
      brandName: map['brandName'] ?? 'Unknown',
      categoryName: map['categoryName'] ?? 'Unknown',
      description: map['description'] as String? ?? '',
      stock: _numAs<int>(map['stock'], 0),
      price: _numAs<double>(map['price'], 0),
      discount: _numAs<double>(map['discount'], 0),
      isActive: map['isActive'] ?? true,
      averageRating: _numAs<double>(map['averageRating'], 0),
      reviewCount: _numAs<int>(map['reviewCount'], 0),
      // brandName/categoryName sẽ gán sau khi fetch
    );
  }

  // 🔁 copyWith để gán brandName/categoryName sau khi fetch
  ProductModel copyWith({
    String? brandName,
    String? categoryName,
  }) {
    return ProductModel(
      id: id,
      name: name,
      imageUrl: imageUrl,
      categoryId: categoryId,
      brandId: brandId,
      description: description,
      stock: stock,
      price: price,
      discount: discount,
      averageRating: averageRating,
      reviewCount: reviewCount,
      isActive: isActive,
      brandName: brandName ?? this.brandName,
      categoryName: categoryName ?? this.categoryName,
    );
  }

}