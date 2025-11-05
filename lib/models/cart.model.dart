// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CartModel {
  String? id;
  String? userId;
  List<ProductForCartModel> items;

  CartModel({
    this.id,
    this.userId,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
    };
  }

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      id: map['id']?.toString(),
      userId: map['userId']?.toString(),
      items: (map['items'] as List<dynamic>? ?? [])
          .map((item) => ProductForCartModel.fromMap(item))
          .toList(),
    );
  }

  String toJson() => json.encode(toMap());

  factory CartModel.fromJson(String source) =>
      CartModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class ProductForCartModel {
  String? productId;
  String? productName;
  int quantity;
  double unitPrice;
  double discount;
  String? image;

  ProductForCartModel({
    this.productId,
    this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
    this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'discount': discount,
      'image': image,
    };
  }

  factory ProductForCartModel.fromMap(Map<String, dynamic> map) {
    return ProductForCartModel(
      productId: map['product_id']?.toString() ?? '',
      productName: map['product_name']?.toString() ?? '',
      quantity: (map['quantity'] ?? 0) as int,
      unitPrice: (map['unit_price'] as num?)?.toDouble() ?? 0.0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      image: map['image']?.toString() ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductForCartModel.fromJson(String source) =>
      ProductForCartModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
