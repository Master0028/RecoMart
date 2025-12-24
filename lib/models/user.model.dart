class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? address;
  final String? avatar;
  final String? role;
  final double loyaltyPoints;
  bool isActive;

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

  factory UserModel.fromMap(Map<String, dynamic> data, String docId) {
    return UserModel(
      id: docId,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      phone: data['phone'],
      address: data['address'],
      avatar: data['avatar'],
      role: data['role'] ?? 'user',
      loyaltyPoints: (data['loyaltyPoints'] ?? 0).toDouble(),
      isActive: data['isActive'] ?? true,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      phone: json['phone'],
      address: json['address'],
      avatar: json['avatar'],
      role: json['role'] ?? 'user',
      loyaltyPoints: (json['loyaltyPoints'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
    'email': email,
    'fullName': fullName,
    'phone': phone,
    'address': address,
    'avatar': avatar,
    'role': role,
    'loyaltyPoints': loyaltyPoints,
    'isActive': isActive,
  };

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
