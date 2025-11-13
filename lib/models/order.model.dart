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
    this.id,
    this.userId,
    this.userName,
    this.email,
    this.address,
    this.totalAmount,
    this.items,
    this.discountAmount,
    this.loyaltyPointsUsed,
    this.loyaltyPointsEarned,
    this.status,
    this.paymentMethod,
    this.paymentStatus,
    this.orderTracking,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String?,
      userId: json['userId'] as String?,  // ✅ đúng key
      userName: json['userName'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),  // ✅
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      discountAmount: (json['discountAmount'] as num?)?.toDouble(),  // ✅
      loyaltyPointsUsed: (json['loyaltyPointsUsed'] as num?)?.toInt(), // ✅
      loyaltyPointsEarned: (json['loyaltyPointsEarned'] as num?)?.toDouble(),
      status: json['status'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      paymentStatus: json['paymentStatus'] as String?,
      orderTracking: (json['orderTracking'] as List<dynamic>?)
          ?.map((e) => OrderTrackingModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'email': email,
      'address': address,
      'totalAmount': totalAmount,
      'items': items?.map((e) => e.toJson()).toList(),
      'discountAmount': discountAmount,
      'loyaltyPointsUsed': loyaltyPointsUsed,
      'loyaltyPointsEarned': loyaltyPointsEarned,
      'status': status,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'orderTracking': orderTracking?.map((e) => e.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class OrderItemModel {
  String? productId;
  String? productName;
  int? quantity;
  double? unit_price;
  double? discount;
  ImageModel? images;

  OrderItemModel({
    this.productId,
    this.productName,
    this.quantity,
    this.unit_price,
    this.discount,
    this.images,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['productId'] ?? json['product_id'], // đọc cả 2 loại key
      productName: json['productName'] ?? json['product_name'],
      quantity: (json['quantity'] as num?)?.toInt(),
      unit_price: (json['unit_price'] ?? json['unitPrice'])?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      images: json['images'] != null
          ? ImageModel.fromJson(json['images'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unit_price,
      'discount': discount,
      'images': images?.toJson(),
    };
  }
}

class ImageModel {
  String? url;

  ImageModel({this.url});

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      url: json['url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
    };
  }
}

class OrderTrackingModel {
  String? status;
  DateTime? date;

  OrderTrackingModel({this.status, this.date});

  factory OrderTrackingModel.fromJson(Map<String, dynamic> json) {
    return OrderTrackingModel(
      status: json['status'] as String?,
      date: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'date': date?.toIso8601String(),
    };
  }
}
