import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recomart/widgets/Footer/mobile_navigation_bar.dart';

final List<String> searchHistory = ['Socks', 'Red Dress', 'Sunglasses', 'Mustard Pants', '80-s Skirt'];
final List<String> recommendations = ['Skirt', 'Accessories', 'Black T-Shirt', 'Jeans', 'White Shoes'];
final List<Map<String, String>> discoverItems = [
  {
    'imageUrl': 'https://images.pexels.com/photos/1152994/pexels-photo-1152994.jpeg?auto=compress&cs=tinysrgb&w=600',
    'description': 'Lorem ipsum dolor sit amet consectetur.',
    'price': '125,00'
  },
  {
    'imageUrl': 'https://images.pexels.com/photos/1036627/pexels-photo-1036627.jpeg?auto=compress&cs=tinysrgb&w=600',
    'description': 'Lorem ipsum dolor sit amet consectetur.',
    'price': '32,00'
  },
  {
    'imageUrl': 'https://images.pexels.com/photos/1126993/pexels-photo-1126993.jpeg?auto=compress&cs=tinysrgb&w=600',
    'description': 'Lorem ipsum dolor sit amet consectetur.',
    'price': '21,00'
  }
];

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _bottomNavIndex = 0;

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
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context),
            _buildSectionHeader('Search history', showClearButton: true),
            _buildChipList(searchHistory, isHistory: true),
            _buildSectionHeader('Recommendations'),
            _buildChipList(recommendations, isHistory: false),
            _buildSectionHeader('Discover'),
            _buildDiscoverSection(),
          ],
        ),
      ),
      bottomNavigationBar: MobileNavigationBar(
        selectedIndex: _bottomNavIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      automaticallyImplyLeading: false,
      title: const Text(
        'Search',
        style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search...',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: Icon(Icons.camera_alt_outlined, color: Colors.blue.shade600),
                  onPressed: () {
                    context.push('/image-search');
                    debugPrint('Chuyển đến trang Image Search!');
                  },
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSectionHeader(String title, {bool showClearButton = false}) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (showClearButton)
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 24, color: Colors.red),
                onPressed: () {
                  // Thêm logic xóa lịch sử ở đây
                },
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildChipList(List<String> items, {required bool isHistory}) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: items.map((item) => Chip(
            label: Text(item),
            backgroundColor: Colors.grey.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isHistory ? Colors.grey.shade300 : Colors.transparent,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            labelStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
          )).toList(),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildDiscoverSection() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 250,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: discoverItems.length,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemBuilder: (context, index) {
            final item = discoverItems[index];
            return Container(
              width: 160,
              margin: const EdgeInsets.only(right: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        item['imageUrl']!,
                        width: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['description']!,
                    style: const TextStyle(color: Colors.black54),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${item['price']}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}