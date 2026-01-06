import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  String? id;
  String? userId;
  String? userName;
  String? email;
  String? address;
  double? totalAmount;
  List<OrderItemModel>? items;
  double? discountAmount;
  int? loyaltyPointsUsed;
  double? loyaltyPointsEarned;
  String? status;
  String? paymentMethod;
  String? paymentStatus;
  List<OrderTrackingModel>? orderTracking;
  DateTime? createdAt;
  DateTime? updatedAt;

  OrderModel({
    this.id, this.userId, this.userName, this.email, this.address,
    this.totalAmount, this.items, this.discountAmount, this.loyaltyPointsUsed,
    this.loyaltyPointsEarned, this.status, this.paymentMethod,
    this.paymentStatus, this.orderTracking, this.createdAt, this.updatedAt,
  });

  OrderModel copyWith({
    String? id, String? userId, String? userName, String? email, String? address,
    double? totalAmount, List<OrderItemModel>? items, double? discountAmount,
    int? loyaltyPointsUsed, double? loyaltyPointsEarned, String? status,
    String? paymentMethod, String? paymentStatus, List<OrderTrackingModel>? orderTracking,
    DateTime? createdAt, DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      address: address ?? this.address,
      totalAmount: totalAmount ?? this.totalAmount,
      items: items ?? this.items,
      discountAmount: discountAmount ?? this.discountAmount,
      loyaltyPointsUsed: loyaltyPointsUsed ?? this.loyaltyPointsUsed,
      loyaltyPointsEarned: loyaltyPointsEarned ?? this.loyaltyPointsEarned,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderTracking: orderTracking ?? this.orderTracking,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userName: json['userName'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      loyaltyPointsUsed: (json['loyaltyPointsUsed'] as num?)?.toInt() ?? 0,
      loyaltyPointsEarned: (json['loyaltyPointsEarned'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'PENDING',
      paymentMethod: json['paymentMethod'] ?? 'COD',
      paymentStatus: json['paymentStatus'] ?? 'UNPAID',
      items: (json['items'] as List?)?.map((e) => OrderItemModel.fromJson(e)).toList() ?? [],
      orderTracking: (json['orderTracking'] as List?)?.map((e) => OrderTrackingModel.fromJson(e)).toList() ?? [],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'email': email,
      'address': address,
      'paymentMethod': paymentMethod,
      'loyaltyPointsUsed': loyaltyPointsUsed ?? 0,
      'items': items!.map((e) => e.toJson()).toList(),
    };
  }

  factory OrderModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return OrderModel(
      id: doc.id,
      userId: data['userId'],
      userName: data['userName'],
      email: data['email'],
      address: data['address'],
      totalAmount: (data['totalAmount'] as num?)?.toDouble(),
      items: (data['items'] as List?)?.map((e) => OrderItemModel.fromJson(e)).toList(),
      discountAmount: (data['discountAmount'] as num?)?.toDouble(),
      loyaltyPointsUsed: (data['loyaltyPointsUsed'] as num?)?.toInt(),
      loyaltyPointsEarned: (data['loyaltyPointsEarned'] as num?)?.toDouble(),
      status: data['status'],
      paymentMethod: data['paymentMethod'],
      paymentStatus: data['paymentStatus'],
      orderTracking: (data['orderTracking'] as List?)?.map((e) => OrderTrackingModel.fromFirestore(e)).toList(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}

class OrderItemModel {
  String? productId;
  String? productName;
  int? quantity;
  double? unitPrice;
  double? discount;
  ImageModel? images;

  OrderItemModel({this.productId, this.productName, this.quantity, this.unitPrice, this.discount, this.images});

  // Getter to prevent 'imageUrl isn't defined' error in UI
  String get imageUrl => images?.url ?? '';

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
    productId: json['productId'] ?? json['product_id'],
    productName: json['productName'] ?? json['product_name'],
    quantity: (json['quantity'] as num?)?.toInt(),
    unitPrice: (json['unitPrice'] ?? json['unit_price'] ?? 0.0).toDouble(),
    discount: (json['discount'] as num?)?.toDouble(),
    images: json['images'] != null ? ImageModel.fromJson(json['images']) : null,
  );

  Map<String, dynamic> toJson() => {
    'productId': productId, 
    'productName': productName, 
    'quantity': quantity,
    'unitPrice': unitPrice, 
    'discount': discount, 
    'images': images?.toJson(),
  };
}

class ImageModel {
  String? url;
  ImageModel({this.url});
  factory ImageModel.fromJson(Map<String, dynamic> json) => ImageModel(url: json['url']);
  Map<String, dynamic> toJson() => {'url': url};
}

class OrderTrackingModel {
  String? status;
  DateTime? date;

  OrderTrackingModel({this.status, this.date});

  factory OrderTrackingModel.fromJson(Map<String, dynamic> json) => OrderTrackingModel(
    status: json['status'],
    date: json['date'] != null ? DateTime.parse(json['date']) : null,
  );

  Map<String, dynamic> toJson() => {
    'status': status, 
    'date': date?.toIso8601String(),
  };

  factory OrderTrackingModel.fromFirestore(Map<String, dynamic> data) => OrderTrackingModel(
    status: data['status'],
    date: (data['date'] as Timestamp?)?.toDate(),
  );
}