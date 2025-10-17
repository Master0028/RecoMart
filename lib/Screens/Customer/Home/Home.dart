import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recomart/widgets/Footer/mobile_navigation_bar.dart';

//==============================================================================
// MAIN HOME SCREEN WIDGET
//==============================================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _selectedOrderStatus = 'To Ship'; 

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 60,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/images/profile.jpg'),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, Romina!',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              'Announcement',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8.0),
        children: [
          _buildAnnouncement(),
          _buildSectionTitle(title: 'Recently viewed'),
          _buildRecentlyViewed(),
          _buildSectionTitle(title: 'My Orders'),
          _buildMyOrders(), // Widget này giờ đã có tương tác
          _buildSectionTitle(title: 'Stories'),
          _buildStories(),
          _buildSectionTitle(title: 'New Items', actionText: 'See All'),
          _buildHorizontalProductList(isNew: true),
          _buildSectionTitle(title: 'Most Popular', actionText: 'See All'),
          _buildHorizontalProductList(isPopular: true),
          _buildSectionTitle(title: 'Categories', actionText: 'See All'),
          _buildCategoryGrid(),
          _buildFlashSale(),
          _buildSectionTitle(title: 'Top Products'),
          _buildTopProducts(),
          _buildSectionTitle(title: 'Just For You', useDot: true),
          _buildJustForYouGrid(),
          const SizedBox(height: 20),
        ],
      ),
      bottomNavigationBar: MobileNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildMyOrders() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildOrderStatusButton(
            'To Pay',
            isSelected: _selectedOrderStatus == 'To Pay',
            onTap: () {
              setState(() {
                _selectedOrderStatus = 'To Pay';
              });
              debugPrint("Đã chuyển sang tab To Pay");
            },
          ),
          _buildOrderStatusButton(
            'To Ship',
            isSelected: _selectedOrderStatus == 'To Ship',
            onTap: () {
              setState(() {
                _selectedOrderStatus = 'To Ship';
              });
               debugPrint("Đã chuyển sang tab To Ship");
            },
          ),
          _buildOrderStatusButton(
            'To Review',
            isSelected: _selectedOrderStatus == 'To Review',
            onTap: () {
              setState(() {
                _selectedOrderStatus = 'To Review';
              });
               debugPrint("Đã chuyển sang tab To Review");
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusButton(String title, {required bool isSelected, required VoidCallback onTap}) {
    // BƯỚC 2: Bọc Container trong InkWell để có thể nhấn được và có hiệu ứng
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.blue.shade700 : Colors.black54,
                  ),
                ),
                if (isSelected)
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ... (Tất cả các hàm build khác nằm ở đây)
  Widget _buildAnnouncement() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Announcement', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                  const SizedBox(height: 4),
                  const Text('Lorem ipsum dolor sit amet, consectetur adipiscing elit', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle({required String title, String? actionText, bool useDot = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (useDot)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: Colors.blue.shade700, shape: BoxShape.circle),
                )
            ],
          ),
          if (actionText != null)
            Text(actionText, style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
  
  Widget _buildRecentlyViewed() {
    final List<String> avatars = List.generate(6, (i) => 'https://i.pravatar.cc/150?img=${i + 1}');
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16.0),
        itemCount: avatars.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(avatars[index]),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildStories() {
    final List<String> stories = List.generate(5, (i) => 'https://picsum.photos/seed/${i + 10}/200/300');
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16.0),
        itemCount: stories.length,
        itemBuilder: (context, index) {
          return Container(
            width: 110,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                image: NetworkImage(stories[index]),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildHorizontalProductList({bool isNew = false, bool isPopular = false}) {
    final List<Map<String, String>> products = [
      {'image': 'https://picsum.photos/seed/p1/200/200', 'name': 'Lorem Ipsum Dolor', 'price': '\$37.07'},
      {'image': 'https://picsum.photos/seed/p2/200/200', 'name': 'Sit Amet Consectetur', 'price': '\$38.99'},
      {'image': 'https://picsum.photos/seed/p3/200/200', 'name': 'Adipiscing Elit', 'price': '\$41.05'},
    ];
    return SizedBox(
      height: isPopular ? 230 : 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16.0),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _ProductCard(
            product: products[index],
            isNew: isNew,
            isPopular: isPopular,
          );
        },
      ),
    );
  }
  
  Widget _buildCategoryGrid() {
    final List<Map<String, String>> categories = [
      {'name': 'Clothes', 'image': 'https://plus.unsplash.com/premium_photo-1664202526559-e21e9c0fb46a?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8ZmFzaGlvbnxlbnwwfHwwfHx8MA%3D%3D&fm=jpg&q=60&w=3000'},
      {'name': 'Laptops', 'image': 'https://picsum.photos/seed/c2/200/200'},
      {'name': 'Shoes', 'image': 'https://picsum.photos/seed/c3/200/200'},
      {'name': 'Bags', 'image': 'https://picsum.photos/seed/c4/200/200'},
      {'name': 'Pants', 'image': 'https://picsum.photos/seed/c5/200/200'},
      {'name': 'Lingerie', 'image': 'https://picsum.photos/seed/c6/200/200'},
      {'name': 'Hats', 'image': 'https://picsum.photos/seed/c7/200/200'},
      {'name': 'Watches', 'image': 'https://picsum.photos/seed/c8/200/200'},
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(categories[index]['image']!, fit: BoxFit.cover, width: double.infinity),
              ),
            ),
            const SizedBox(height: 8),
            Text(categories[index]['name']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        );
      },
    );
  }
  
Widget _buildFlashSale() {
  final List<String> flashSaleImages = List.generate(3, (i) => 'https://picsum.photos/seed/fs${i + 1}/200/200');

  return InkWell(
    onTap: () {
      context.push('/flash-sale');
      debugPrint("Chuyển đến trang Flash Sale!");
    },
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Flash Sale', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
              Row(
                children: [
                  _buildTimerBox('00'),
                  const Text(' : ', style: TextStyle(fontWeight: FontWeight.bold)),
                  _buildTimerBox('36'),
                  const Text(' : ', style: TextStyle(fontWeight: FontWeight.bold)),
                  _buildTimerBox('58'),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          AbsorbPointer(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: flashSaleImages.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(flashSaleImages[index], fit: BoxFit.cover),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
  
  Widget _buildTimerBox(String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(time, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
  
  Widget _buildTopProducts() {
    final List<String> avatars = List.generate(6, (i) => 'https://i.pravatar.cc/150?img=${i + 20}');
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16.0),
        itemCount: avatars.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              radius: 35,
              backgroundImage: NetworkImage(avatars[index]),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildJustForYouGrid() {
    final List<Map<String, String>> products = [
      {'image': 'https://picsum.photos/seed/jfy1/300/400', 'name': 'Elegant Red Dress', 'price': '\$55.00'},
      {'image': 'https://picsum.photos/seed/jfy2/300/400', 'name': 'Casual T-Shirt', 'price': '\$17.99'},
      {'image': 'https://picsum.photos/seed/jfy3/300/400', 'name': 'Summer Floral Top', 'price': '\$24.50'},
      {'image': 'https://picsum.photos/seed/jfy4/300/400', 'name': 'Denim Jeans', 'price': '\$42.00'},
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => _ProductCard(product: products[index]),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, String> product;
  final bool isNew;
  final bool isPopular;

  const _ProductCard({
    required this.product,
    this.isNew = false,
    this.isPopular = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.network(product['image']!, width: double.infinity, fit: BoxFit.cover),
                ),
                if (isNew)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 18),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(product['name']!, style: const TextStyle(fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(product['price']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          if (isPopular)
            Row(
              children: [
                const Icon(Icons.favorite, color: Colors.pink, size: 16),
                const SizedBox(width: 4),
                const Text('1,956', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade700,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text('New', style: TextStyle(fontSize: 10, color: Colors.white)),
                ),
              ],
            )
        ],
      ),
    );
  }
}