import 'package:flutter/material.dart';

final List<Map<String, String>> mostPopular = [
  {'image': 'https://images.pexels.com/photos/1055691/pexels-photo-1055691.jpeg?auto=compress&cs=tinysrgb&w=600', 'tag': 'New'},
  {'image': 'https://images.pexels.com/photos/1154861/pexels-photo-1154861.jpeg?auto=compress&cs=tinysrgb&w=600', 'tag': 'Sale'},
  {'image': 'https://images.pexels.com/photos/1304647/pexels-photo-1304647.jpeg?auto=compress&cs=tinysrgb&w=600', 'tag': 'Hot'},
  {'image': 'https://images.pexels.com/photos/2043590/pexels-photo-2043590.jpeg?auto=compress&cs=tinysrgb&w=600', 'tag': 'New'},
];
final List<Map<String, String>> youMightLike = [
    {'image': 'https://images.pexels.com/photos/1036627/pexels-photo-1036627.jpeg?auto=compress&cs=tinysrgb&w=600', 'price': '17,00'},
    {'image': 'https://images.pexels.com/photos/3771649/pexels-photo-3771649.jpeg?auto=compress&cs=tinysrgb&w=600', 'price': '17,00'},
    {'image': 'https://images.pexels.com/photos/1485637/pexels-photo-1485637.jpeg?auto=compress&cs=tinysrgb&w=600', 'price': '17,00'},
    {'image': 'https://images.pexels.com/photos/1852382/pexels-photo-1852382.jpeg?auto=compress&cs=tinysrgb&w=600', 'price': '17,00'},
];

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedVariationIndex = 0;
  int _selectedDeliveryIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildProductImageAppBar(),
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      _buildProductInfo(),
                      _buildDivider(),
                      _buildVariations(),
                      _buildDivider(),
                      _buildSpecifications(),
                      _buildDivider(),
                      _buildDeliveryOptions(),
                      _buildDivider(),
                      _buildRatingAndReviews(),
                      _buildSectionHeader(context, title: 'Most Popular'),
                      _buildMostPopularList(),
                      _buildSectionHeader(context, title: 'You Might Like'),
                    ],
                  ),
                ),
              ),
              _buildYouMightLikeGrid(),
              // Thêm khoảng trống ở dưới cùng để không bị thanh action che mất
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomActionBar(),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildProductImageAppBar() {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.5,
      stretch: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Image.network(
          'https://images.pexels.com/photos/1485637/pexels-photo-1485637.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
          fit: BoxFit.cover,
        ),
        stretchModes: const [StretchMode.zoomBackground],
      ),
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('\$17,00', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              Icon(Icons.share_outlined, color: Colors.pink.shade300),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Pretium quam vulputate dignissim suspendisse in est. Ac felis donec et odio pellentesque eu mauris id.',
            style: TextStyle(color: Colors.grey.shade600, height: 1.5, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildVariations() {
    const variations = [
      'https://images.pexels.com/photos/1485637/pexels-photo-1485637.jpeg?auto=compress&cs=tinysrgb&w=100',
      'https://images.pexels.com/photos/1055691/pexels-photo-1055691.jpeg?auto=compress&cs=tinysrgb&w=100',
      'https://images.pexels.com/photos/1154861/pexels-photo-1154861.jpeg?auto=compress&cs=tinysrgb&w=100',
    ];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Variations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ...List.generate(variations.length, (index) {
                    return GestureDetector(
                      onTap: () => setState(() => _selectedVariationIndex = index),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _selectedVariationIndex == index ? Colors.blue.shade600 : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(variations[index], width: 50, height: 50, fit: BoxFit.cover),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pink', style: TextStyle(fontWeight: FontWeight.w500)),
                      SizedBox(height: 2),
                      Text('M', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecifications() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Specifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Material', style: TextStyle(color: Colors.grey)),
              const SizedBox(width: 16),
              _buildSpecChip('Cotton 95%'),
              const SizedBox(width: 8),
              _buildSpecChip('Nylon 5%'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Origin', style: TextStyle(color: Colors.grey)),
              const SizedBox(width: 38),
              _buildSpecChip('EU'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Size guide', style: TextStyle(fontWeight: FontWeight.w500)),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.grey.shade100,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildDeliveryOptions() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Delivery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          _buildDeliveryOption(
            index: 0,
            title: 'Standart',
            time: '5-7 days',
            price: '\$3.00',
          ),
          _buildDeliveryOption(
            index: 1,
            title: 'Express',
            time: '1-2 days',
            price: '\$12.00',
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryOption({required int index, required String title, required String time, required String price}) {
    bool isSelected = _selectedDeliveryIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedDeliveryIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Chip(
                  label: Text(time, style: TextStyle(fontSize: 12, color: Colors.blue.shade700)),
                  backgroundColor: Colors.blue.shade100.withOpacity(0.5),
                  visualDensity: VisualDensity.compact,
                  side: BorderSide.none,
                ),
              ],
            ),
            Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingAndReviews() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Rating & Reviews', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  const Text('4/5', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage('https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=100'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Veronika', style: TextStyle(fontWeight: FontWeight.bold)),
                        Row(children: List.generate(5, (i) => Icon(i < 4 ? Icons.star : Icons.star_border, color: Colors.amber, size: 16))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt...',
                      style: TextStyle(color: Colors.grey[600]),
                    )
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('View All Reviews'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMostPopularList() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: mostPopular.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final item = mostPopular[index];
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(item['image']!, fit: BoxFit.cover),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      stops: const [0.0, 0.5],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Row(
                    children: [
                      const Icon(Icons.favorite, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      const Text('1780', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(item['tag']!, style: const TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  SliverPadding _buildYouMightLikeGrid() {
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 24.0,
          crossAxisSpacing: 16.0,
          childAspectRatio: 0.7,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = youMightLike[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(item['image']!, fit: BoxFit.cover, width: double.infinity),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Lorem ipsum dolor sit', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                Text('\$${item['price']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            );
          },
          childCount: youMightLike.length,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(height: 1),
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String title}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Text('See All', style: TextStyle(color: Colors.blue.shade600, fontWeight: FontWeight.w500)),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- WIDGETS TÁCH RỜI ---

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Add to cart'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Buy Now'),
            ),
          ),
        ],
      ),
    );
  }
}