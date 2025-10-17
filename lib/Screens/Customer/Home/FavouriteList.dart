import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recomart/widgets/Footer/mobile_navigation_bar.dart';

final List<String> recentlyViewed = List.generate(6, (i) => 'https://i.pravatar.cc/150?img=${i + 10}');

final List<Map<String, dynamic>> wishlistItems = [
  {
    'imageUrl': 'https://images.pexels.com/photos/1485637/pexels-photo-1485637.jpeg?auto=compress&cs=tinysrgb&w=600',
    'description': 'Lorem ipsum dolor sit amet consectetur.',
    'price': '17,00',
    'variations': ['Pink', 'M'],
  },
  {
    'imageUrl': 'https://images.pexels.com/photos/1036627/pexels-photo-1036627.jpeg?auto=compress&cs=tinysrgb&w=600',
    'description': 'Lorem ipsum dolor sit amet consectetur.',
    'price': '12,00',
     'variations': ['White', 'S'],
  },
  {
    'imageUrl': 'https://images.pexels.com/photos/1154861/pexels-photo-1154861.jpeg?auto=compress&cs=tinysrgb&w=600',
    'description': 'Lorem ipsum dolor sit amet consectetur.',
    'price': '27,00',
     'variations': ['Pink', 'M'],
  },
  {
    'imageUrl': 'https://images.pexels.com/photos/3771649/pexels-photo-3771649.jpeg?auto=compress&cs=tinysrgb&w=600',
    'description': 'Lorem ipsum dolor sit amet consectetur.',
    'price': '19,00',
     'variations': ['Cream', 'L'],
  },
];


class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  int _bottomNavIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _bottomNavIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          itemBuilder: (context, index) {
            if (index == 0) return _buildHeader();
            if (index == 1) return _buildRecentlyViewed();
            final item = wishlistItems[index - 2];
            return _buildWishlistItem(item);
          },
          separatorBuilder: (context, index) {
            if (index == 1) return const SizedBox(height: 32);
            return const SizedBox(height: 24);
          },
          itemCount: wishlistItems.length + 2,
        ),
      ),
      bottomNavigationBar: MobileNavigationBar(
        selectedIndex: _bottomNavIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        'Wishlist',
        style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRecentlyViewed() {
  // Dữ liệu giả, bạn có thể đã có sẵn
  final List<String> recentlyViewed = List.generate(6, (i) => 'https://i.pravatar.cc/150?img=${i + 10}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recently viewed',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              InkWell(
                onTap: () {
                  context.push('/recently-viewed');
                  debugPrint("Chuyển đến trang Recently Viewed!");
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: recentlyViewed.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: CircleAvatar(
                  radius: 35,
                  backgroundImage: NetworkImage(recentlyViewed[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWishlistItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ảnh sản phẩm và nút xóa
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.network(
                  item['imageUrl'],
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Thông tin sản phẩm
          Expanded(
            child: SizedBox(
              height: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['description'],
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '\$${item['price']}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      ...(item['variations'] as List<String>).map((v) => _buildVariationChip(v)).toList(),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade600,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add_shopping_cart_outlined, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariationChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}