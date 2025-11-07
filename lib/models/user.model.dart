class UserModel {
  final String id;                // Firestore docId
  final String email;
  final String fullName;
  final String? phone;
  final String? address;
  final String? avatar;
  final String? role;             // e.g., "admin", "user"
  final double loyaltyPoints;
  bool isActive;                  // có thể toggle cấm / mở khóa

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.address,
    this.avatar,
    this.role,
    this.loyaltyPoints = 0.0,
    this.isActive = true,
  });

  /// ✅ Tạo UserModel từ Firestore document
  factory UserModel.fromMap(Map<String, dynamic> data, String docId) {
    return UserModel(
      id: docId,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      phone: data['phone'],
      address: data['address'],
      avatar: data['avatar'],
      role: data['role'] ?? 'user',
      loyaltyPoints: (data['loyalty_points'] ?? 0).toDouble(),
      isActive: data['isActive'] ?? true,
    );
  }

  /// ✅ Tạo từ JSON API (nếu cần tương thích REST)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      phone: json['phone'],
      address: json['address'],
      avatar: json['avatar'],
      role: json['role'] ?? 'user',
      loyaltyPoints: (json['loyalty_points'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
    );
  }

  /// ✅ Chuyển về Map để ghi lên Firestore
  Map<String, dynamic> toMap() => {
    'email': email,
    'fullName': fullName,
    'phone': phone,
    'address': address,
    'avatar': avatar,
    'role': role,
    'loyalty_points': loyaltyPoints,
    'isActive': isActive,
  };

  /// ✅ Tạo bản sao có cập nhật (dùng khi chỉnh sửa người dùng)
  UserModel copyWith({
    String? email,
    String? fullName,
    String? phone,
    String? address,
    String? avatar,
    String? role,
    double? loyaltyPoints,
    bool? isActive,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      isActive: isActive ?? this.isActive,
    );
  }
}
