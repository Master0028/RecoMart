import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/views/pages/client/profile/widgets/my_account.dart';
import 'package:recomart/views/pages/client/profile/widgets/order_management.dart';
import 'package:recomart/views/pages/client/profile/widgets/payment_management.dart';
import 'package:recomart/views/pages/client/profile/widgets/support.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:feather_icons/feather_icons.dart';

class ProfileBody extends StatefulWidget {
  const ProfileBody({super.key});
  
  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  int _selectedIndex = 0;
  
  String userName = 'Guest';
  String userAvatar = '';
  int loyaltyPoints = 0;
  String currentUserId = '';
  bool isLoading = true;

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Account', 'icon': FeatherIcons.user},
    {'title': 'Orders', 'icon': FeatherIcons.package},
    {'title': 'Payment', 'icon': FeatherIcons.creditCard},
    {'title': 'Support', 'icon': FeatherIcons.messageSquare},
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      try {
        final query = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          final data = query.docs.first.data();
          if (mounted) {
            setState(() {
              userName = data['fullName'] ?? data['name'] ?? user.displayName ?? 'User';
              if (data['avatar'] is Map) {
                 userAvatar = data['avatar']['url'] ?? '';
              } else {
                 userAvatar = data['avatar'] ?? user.photoURL ?? '';
              }
              loyaltyPoints = data['loyaltyPoints'] ?? 0;
              currentUserId = user.uid;
              isLoading = false;
            });
          }
        } else {
          if (mounted) {
             setState(() {
               userName = user.displayName ?? 'User';
               userAvatar = user.photoURL ?? '';
               currentUserId = user.uid;
               isLoading = false;
             });
          }
        }
      } catch (e) {
        print("Error loading profile: $e");
        if (mounted) setState(() => isLoading = false);
      }
    } else {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget _buildContent(String userId) {
    switch (_selectedIndex) {
      case 0: return const MyAccountView();
      case 1: return OrderManagement(userId: userId); 
      case 2: return const PaymentManagement();
      case 3: return const SupportChatScreen();
      default: return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color headerColor = Color(0xFF003D80);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          // --- HEADER PROFILE ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 40, bottom: 60, left: 16, right: 16),
            decoration: const BoxDecoration(
              color: headerColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
              ],
            ),
            child: Column(
              children: [
                // User Name
                Text(
                  'Welcome, $userName!',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                
                // Avatar & Points
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Avatar Container
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.secondary, width: 3),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade200,
                        child: ClipOval(
                          child: userAvatar.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: userAvatar,
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                  placeholder: (_, __) => const CircularProgressIndicator(color: AppColors.primary),
                                  errorWidget: (_, __, ___) => const Icon(FeatherIcons.user, size: 50, color: Colors.grey),
                                )
                              : const Icon(FeatherIcons.user, size: 50, color: Colors.grey),
                        ),
                      ),
                    ),
                    
                    // Loyalty Points Badge
                    Positioned(
                      bottom: -20, 
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(FeatherIcons.award, color: Colors.white, size: 14),
                            const SizedBox(width: 6),
                            Flexible( 
                              child: Text(
                                '$loyaltyPoints Points',
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 40), 

          // --- MENU TAB BAR ---
          SizedBox(
            height: 50,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _menuItems.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final isSelected = _selectedIndex == index;
                
                return InkWell(
                  onTap: () => setState(() => _selectedIndex = index),
                  borderRadius: BorderRadius.circular(25),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))]
                          : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item['icon'], 
                          size: 18, 
                          color: isSelected ? Colors.white : AppColors.primary
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item['title'],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildContent(currentUserId), 
              ),
            ),
          ),
          
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}