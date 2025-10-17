import 'package:flutter/material.dart';
import 'package:recomart/widgets/Footer/mobile_navigation_bar.dart';

final List<Map<String, String>> recentlyViewedProducts = [
    {'image': 'https://images.pexels.com/photos/3771649/pexels-photo-3771649.jpeg?auto=compress&cs=tinysrgb&w=400', 'price': '17,00'},
    {'image': 'https://images.pexels.com/photos/1304647/pexels-photo-1304647.jpeg?auto=compress&cs=tinysrgb&w=400', 'price': '17,00'},
    {'image': 'https://images.pexels.com/photos/1154861/pexels-photo-1154861.jpeg?auto=compress&cs=tinysrgb&w=400', 'price': '17,00'},
    {'image': 'https://images.pexels.com/photos/1485637/pexels-photo-1485637.jpeg?auto=compress&cs=tinysrgb&w=400', 'price': '17,00'},
];

class RecentlyViewedScreen extends StatefulWidget {
  const RecentlyViewedScreen({super.key});

  @override
  State<RecentlyViewedScreen> createState() => _RecentlyViewedScreenState();
}

class _RecentlyViewedScreenState extends State<RecentlyViewedScreen> {
  int _bottomNavIndex = 2;
  int _selectedDate = 18;

  void _onBottomNavTapped(int index) {
    setState(() {
      _bottomNavIndex = index;
    });
  }

  void _onDateSelected(int date) {
    setState(() {
      _selectedDate = date;
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
                _buildHeader(),
                _buildCalendar(),
                _buildProductGrid(),
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

  // --- WIDGET BUILDERS ---

  SliverToBoxAdapter _buildHeader() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Text(
          'Recently viewed',
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildCalendar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                children: [
                  // Month Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.chevron_left, color: Colors.blue),
                      const Chip(
                        label: Text('April', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        backgroundColor: Colors.blue,
                      ),
                      const Icon(Icons.chevron_right, color: Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Calendar Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                    ),
                    itemCount: 31,
                    itemBuilder: (context, index) {
                      final date = index + 1;
                      final isSelected = date == _selectedDate;
                      return GestureDetector(
                        onTap: () => _onDateSelected(date),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$date',
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
             // Nút expand
            const Icon(Icons.keyboard_arrow_up, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  SliverPadding _buildProductGrid() {
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 250.0, // Responsive
          mainAxisSpacing: 16.0,
          crossAxisSpacing: 16.0,
          childAspectRatio: 0.7,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = recentlyViewedProducts[index];
            return Container(
               decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        item['image']!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         const Text(
                           'Lorem ipsum dolor sit amet consectetur',
                           style: TextStyle(color: Colors.grey),
                           maxLines: 1,
                           overflow: TextOverflow.ellipsis,
                         ),
                         const SizedBox(height: 4),
                         Text(
                           '\$${item['price']}',
                           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                         ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
          childCount: recentlyViewedProducts.length,
        ),
      ),
    );
  }
}