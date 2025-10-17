import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import go_router
import 'package:recomart/widgets/Footer/mobile_navigation_bar.dart'; // Sửa lại đường dẫn nếu cần

// --- Dữ liệu giả (Mock Data) ---
final List<Map<String, String>> categories = [
  {'image': 'https://picsum.photos/seed/cat1/200', 'name': 'Dresses'},
  {'image': 'https://picsum.photos/seed/cat2/200', 'name': 'Pants'},
  {'image': 'https://picsum.photos/seed/cat3/200', 'name': 'Skirts'},
  {'image': 'https://picsum.photos/seed/cat4/200', 'name': 'Shorts'},
  {'image': 'https://picsum.photos/seed/cat5/200', 'name': 'Jackets'},
  {'image': 'https://picsum.photos/seed/cat6/200', 'name': 'Hoodies'},
  {'image': 'https://picsum.photos/seed/cat7/200', 'name': 'Shirts'},
  {'image': 'https://picsum.photos/seed/cat8/200', 'name': 'Polo'},
  {'image': 'https://picsum.photos/seed/cat9/200', 'name': 'T-shirts'},
  {'image': 'https://picsum.photos/seed/cat10/200', 'name': 'Tunics'},
];

final List<Map<String, String>> products = List.generate(12, (i) => {
  'imageUrl': 'https://picsum.photos/seed/prod${i+1}/400/600',
  'name': 'Lorem ipsum dolor sit amet consectetur',
  'price': (17.00 + i).toStringAsFixed(2)
});

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int _bottomNavIndex = 2; // Giả sử tab "Shop" là vị trí thứ 2

  void _onItemTapped(int index) {
    setState(() {
      _bottomNavIndex = index;
    });
    // Thêm logic điều hướng cho bottom nav bar ở đây nếu bạn đã cấu hình
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context), // Truyền context vào
            _buildCategoryList(),
            _buildSectionHeader(context), // Truyền context vào
            _buildProductGrid(),
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
        'Shop',
        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: GestureDetector(
            onTap: () {
              context.push('/search');
              debugPrint("Chuyển đến trang Search!");
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Chip(
                    label: Text('Clothing', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w500)),
                    deleteIcon: Icon(Icons.close, size: 18, color: Colors.blue.shade700),
                    onDeleted: () {},
                    backgroundColor: Colors.blue.shade100.withOpacity(0.7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide.none,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.camera_alt_outlined, color: Colors.blue.shade700),
                      onPressed: () {
                        context.push('/search-image');
                        debugPrint("Chuyển đến trang Image Search!");
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  SliverToBoxAdapter _buildCategoryList() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 110,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(categories[index]['image']!),
                  ),
                  const SizedBox(height: 8),
                  Text(categories[index]['name']!, style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSectionHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'All Items',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () {
                context.push('/categories-filter');
                debugPrint("Chuyển đến trang Categories Filter!");
              },
              // Xoay icon 90 độ để giống với thiết kế
              icon: RotatedBox(
                quarterTurns: 1,
                child: Icon(Icons.tune, color: Colors.grey.shade700)
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverPadding _buildProductGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 24.0,
          crossAxisSpacing: 16.0,
          childAspectRatio: 0.7,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final product = products[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.network(
                      product['imageUrl']!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product['name']!,
                  style: const TextStyle(color: Colors.black54),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product['price']}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            );
          },
          childCount: products.length,
        ),
      ),
    );
  }
}