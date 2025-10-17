import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recomart/widgets/Footer/mobile_navigation_bar.dart';

final List<Map<String, String>> recentlyViewedProducts = List.generate(
  8,
  (i) => {
    'id': 'prod${i + 20}',
    'imageUrl': 'https://picsum.photos/seed/recent${i + 1}/400/600',
    'description': 'Lorem ipsum dolor sit amet consectetur',
    'price': (17.00 + i * 2).toStringAsFixed(2),
  },
);

class RecentlyViewedScreen extends StatefulWidget {
  const RecentlyViewedScreen({super.key});

  @override
  State<RecentlyViewedScreen> createState() => _RecentlyViewedScreenState();
}

class _RecentlyViewedScreenState extends State<RecentlyViewedScreen> {
  int _bottomNavIndex = 2;
  int _selectedTabIndex = 0; 

  void _onBottomNavTapped(int index) {
    setState(() {
      _bottomNavIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            _buildFilterTabs(),
            _buildProductGrid(),
          ],
        ),
      ),
      bottomNavigationBar: MobileNavigationBar(
        selectedIndex: _bottomNavIndex,
        onItemTapped: _onBottomNavTapped,
      ),
    );
  }

  // --- CÁC WIDGET CON ĐƯỢC TÁCH RA ---

  SliverAppBar _buildHeader() {
    return const SliverAppBar(
      backgroundColor: Colors.transparent, // Trong suốt để hòa vào nền
      elevation: 0,
      title: Text(
        'Recently viewed',
        style: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildFilterTabs() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            _buildTabButton('Today', 0),
            const SizedBox(width: 12),
            _buildTabButton('Yesterday', 1),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_downward, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100.withOpacity(0.7) : Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.blue.shade700 : Colors.black54,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              const CircleAvatar(
                radius: 10,
                backgroundColor: Colors.blue,
                child: Icon(Icons.check, size: 12, color: Colors.white),
              )
            ]
          ],
        ),
      ),
    );
  }

  SliverPadding _buildProductGrid() {
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 24.0,
          childAspectRatio: 0.7, // Điều chỉnh tỉ lệ để card cao hơn
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = recentlyViewedProducts[index];
            return _ProductCard(
              productId: item['id']!,
              imageUrl: item['imageUrl']!,
              description: item['description']!,
              price: item['price']!,
            );
          },
          childCount: recentlyViewedProducts.length,
        ),
      ),
    );
  }
}

// --- WIDGET TÁI SỬ DỤNG CHO THẺ SẢN PHẨM ---

class _ProductCard extends StatelessWidget {
  final String productId;
  final String imageUrl;
  final String description;
  final String price;

  const _ProductCard({
    required this.productId,
    required this.imageUrl,
    required this.description,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push('/product/$productId');
      },
      borderRadius: BorderRadius.circular(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(color: Colors.black54),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '\$$price',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}