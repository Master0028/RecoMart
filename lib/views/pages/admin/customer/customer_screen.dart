import 'package:flutter/material.dart';
import 'package:recomart/views/pages/admin/customer/widgets/customer_table.dart';

class AvatarModel {
  final String url;
  final String public_id;
  AvatarModel({required this.url, required this.public_id});
}

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? address;
  final double loyaltyPoints;
  final bool isActive;
  final AvatarModel? avatar;
  final String role;
  final String status;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.address,
    this.loyaltyPoints = 0,
    this.isActive = true,
    this.avatar,
    this.role = 'CUSTOMER',
  }) : status = isActive ? 'Active' : 'Disabled';

  UserModel copyWith({
    bool? isActive,
  }) {
    return UserModel(
      id: id,
      fullName: fullName,
      email: email,
      phone: phone,
      address: address,
      loyaltyPoints: loyaltyPoints,
      isActive: isActive ?? this.isActive,
      avatar: avatar,
      role: role,
    );
  }
}

final List<UserModel> FE_CUSTOMERS_STUB = [
  UserModel(
    id: 'c1',
    fullName: 'Alice Johnson',
    email: 'alice@example.com',
    phone: '0901234567',
    address: '123 Đường FE',
    loyaltyPoints: 150.5,
    isActive: true,
    avatar: AvatarModel(url: 'https://i.pravatar.cc/150?img=1', public_id: 'p1'),
  ),
  UserModel(
    id: 'c2',
    fullName: 'Bob Smith (Disabled)',
    email: 'bob@example.com',
    phone: '0907654321',
    address: '456 Đường FE',
    loyaltyPoints: 50.0,
    isActive: false,
    avatar: AvatarModel(url: 'https://i.pravatar.cc/150?img=2', public_id: 'p2'),
  ),
];

class CustomerManagementScreen extends StatelessWidget {
  CustomerManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final customers = FE_CUSTOMERS_STUB;

    return Container(
      color: Colors.grey[100],
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            if (customers.isEmpty)
              const Center(child: Text('No customers found'))
            else
              CustomerTable(customers: customers),
          ],
        ),
      ),
    );
  }
}