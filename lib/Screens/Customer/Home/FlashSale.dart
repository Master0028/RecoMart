import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recomart/widgets/Footer/mobile_navigation_bar.dart'; // Sửa lại đường dẫn nếu cần

class FlashSaleScreen extends StatefulWidget {
  const FlashSaleScreen({super.key});

  @override
  State<FlashSaleScreen> createState() => _FlashSaleScreenState();
}

class _FlashSaleScreenState extends State<FlashSaleScreen> {
  int _bottomNavIndex = 0;
  final List<String> _discounts = ['All', '10%', '20%', '30%', '40%', '50%'];
  int _selectedDiscountIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _bottomNavIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              height: 220,
              color: Colors.blue.shade200.withOpacity(0.6),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                _buildAppBar(),
                _buildBanner(),
                _buildSectionHeader(),
                _buildProductsGrid(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: MobileNavigationBar(
        selectedIndex: _bottomNavIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      automaticallyImplyLeading: false,
      toolbarHeight: 60,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Flash Sale',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 28),
          ),
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: Colors.black, size: 20),
              const SizedBox(width: 8),
              _buildTimerBox('00'),
              const Text(' : ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              _buildTimerBox('36'),
              const Text(' : ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              _buildTimerBox('58'),
            ],
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("Choose Your Discount", style: TextStyle(fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 8),
            _buildDiscountTabs(),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountTabs() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        itemCount: _discounts.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedDiscountIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDiscountIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                  color: isSelected ? Colors.blue.shade600 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected ? null : Border.all(color: Colors.grey.shade300)),
              child: Center(
                child: Text(
                  _discounts[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBanner() {
    final List<String> bannerImages = List.generate(4, (i) => 'https://picsum.photos/seed/b${i + 1}/200/300');
    return SliverToBoxAdapter(
      child: InkWell(
        onTap: () {
          context.push('/live-stream');
          debugPrint("Chuyển đến trang Live Stream!");
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text("ARTICALE REIMAGINED", style: TextStyle(fontWeight: FontWeight.w500, letterSpacing: 1.5)),
              const SizedBox(height: 12),
              AbsorbPointer(
                child: SizedBox(
                  height: 180,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              bannerImages[index],
                              fit: BoxFit.cover,
                            ),
                            if (index == 3)
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade400,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Text("Live", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '20% Discount',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Icon(Icons.tune, color: Colors.grey.shade800),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsGrid() {
    // THAY ĐỔI CHÍNH: Thêm 'id' vào dữ liệu sản phẩm
    final products = List.generate(8, (i) => {
          'id': 'prod${i + 1}',
          'image': 'https://picsum.photos/seed/prod${i + 1}/400/600',
          'price': (20.00 + i * 2).toStringAsFixed(2)
        });

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.65,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // THAY ĐỔI CHÍNH: Truyền thêm 'productId' vào _ProductCard
            return _ProductCard(
              productId: products[index]['id']!,
              imageUrl: products[index]['image']!,
              originalPrice: products[index]['price']!,
            );
          },
          childCount: products.length,
        ),
      ),
    );
  }

  Widget _buildTimerBox(String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3)
          ]),
      child: Text(time, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String productId; // Thêm ID của sản phẩm
  final String imageUrl;
  final String originalPrice;

  const _ProductCard({
    required this.productId,
    required this.imageUrl,
    required this.originalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push('/product-sales/$productId');
        debugPrint('Navigating to product: $productId');
      },
      borderRadius: BorderRadius.circular(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(imageUrl, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('-20%', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Lorem ipsum dolor sit amet consectetur',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text('\$16.00', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(width: 8),
              Text(
                '\$$originalPrice',
                style: const TextStyle(fontSize: 14, color: Colors.grey, decoration: TextDecoration.lineThrough),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// CustomClipper để tạo nền cong
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width / 4, size.height, size.width / 2, size.height * 0.9);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.8, size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}