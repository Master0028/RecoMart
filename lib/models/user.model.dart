class UserModel {
  final String id;
  final String email;
  String? phone;
  String? address;
  String? role;
  final String fullName;
  final String? avatar;
  final double loyaltyPoints;
  bool isActive; // Changed to non-final for toggling

  UserModel({
    required this.id,
    required this.email,
    this.phone,
    this.address,
    required this.fullName,
    this.avatar,
    required this.role,
    required this.loyaltyPoints,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      fullName: json['fullName'] as String? ?? '',
      address: json['address'] as String?,
      avatar: json['avatar'] as String? ?? '',
      role: json['role'] as String?,
      loyaltyPoints: (json['loyalty_points'] ?? 0).toDouble(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}