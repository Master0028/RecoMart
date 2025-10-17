import 'package:flutter/material.dart';
import 'package:recomart/widgets/Footer/mobile_navigation_bar.dart';

final List<String> recentlyViewed = [
  'https://images.pexels.com/photos/1055691/pexels-photo-1055691.jpeg?auto=compress&cs=tinysrgb&w=100',
  'https://images.pexels.com/photos/1036627/pexels-photo-1036627.jpeg?auto=compress&cs=tinysrgb&w=100',
  'https://images.pexels.com/photos/2043590/pexels-photo-2043590.jpeg?auto=compress&cs=tinysrgb&w=100',
  'https://images.pexels.com/photos/1852382/pexels-photo-1852382.jpeg?auto=compress&cs=tinysrgb&w=100',
  'https://images.pexels.com/photos/1304647/pexels-photo-1304647.jpeg?auto=compress&cs=tinysrgb&w=100',
];

final List<Map<String, String>> mostPopular = [
    {'image': 'https://images.pexels.com/photos/1154861/pexels-photo-1154861.jpeg?auto=compress&cs=tinysrgb&w=400', 'tag': 'New'},
    {'image': 'https://images.pexels.com/photos/3771649/pexels-photo-3771649.jpeg?auto=compress&cs=tinysrgb&w=400', 'tag': 'Sale'},
    {'image': 'https://images.pexels.com/photos/1036627/pexels-photo-1036627.jpeg?auto=compress&cs=tinysrgb&w=400', 'tag': 'Hot'},
    {'image': 'https://images.pexels.com/photos/1485637/pexels-photo-1485637.jpeg?auto=compress&cs=tinysrgb&w=400', 'tag': ''},
];

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  int _bottomNavIndex = 2;

  void _onBottomNavTapped(int index) {
    setState(() {
      _bottomNavIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SafeArea(
            child: CustomScrollView(
              slivers: [
                // Header
                _buildHeader(),
                _buildSectionHeader('Recently viewed'),
                _buildRecentlyViewedList(),
                _buildEmptyStateIcon(),
                _buildSectionHeader('Most Popular', showSeeAll: true),
                _buildMostPopularList(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: MobileNavigationBar(
        selectedIndex: _bottomNavIndex,
        onItemTapped: _onBottomNavTapped,
      ),
    );
  }

  SliverToBoxAdapter _buildHeader() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Text(
          'Wishlist',
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSectionHeader(String title, {bool showSeeAll = false}) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                if (showSeeAll)
                  const Text('See All', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
                  child: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildRecentlyViewedList() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 60,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: recentlyViewed.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(recentlyViewed[index]),
              ),
            );
          },
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildEmptyStateIcon() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 5,
                    blurRadius: 15,
                  )
                ],
              ),
              child: const Icon(Icons.favorite, color: Colors.blue, size: 40),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildMostPopularList() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 220,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: mostPopular.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            final item = mostPopular[index];
            return Container(
              width: 150,
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(item['image']!, fit: BoxFit.cover, width: 150),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Text('1780', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(width: 4),
                          Icon(Icons.favorite, color: Colors.blue, size: 16),
                        ],
                      ),
                      Text(item['tag']!, style: const TextStyle(color: Colors.grey)),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}