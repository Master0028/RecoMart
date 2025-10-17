import 'package:flutter/material.dart';

final List<Map<String, String>> searchResults = [
  {
    'imageUrl': 'https://images.pexels.com/photos/1036627/pexels-photo-1036627.jpeg?auto=compress&cs=tinysrgb&w=600',
    'description': 'Lorem ipsum dolor sit amet consectetur',
    'price': '17,00'
  },
  {
    'imageUrl': 'https://images.pexels.com/photos/972804/pexels-photo-972804.jpeg?auto=compress&cs=tinysrgb&w=600',
    'description': 'Lorem ipsum dolor sit amet consectetur',
    'price': '17,00'
  },
  {
    'imageUrl': 'https://images.pexels.com/photos/3268732/pexels-photo-3268732.jpeg?auto=compress&cs=tinysrgb&w=600',
    'description': 'Lorem ipsum dolor sit amet consectetur',
    'price': '17,00'
  },
  {
    'imageUrl': 'https://images.pexels.com/photos/1858407/pexels-photo-1858407.jpeg?auto=compress&cs=tinysrgb&w=600',
    'description': 'Lorem ipsum dolor sit amet consectetur',
    'price': '17,00'
  },
  {
    'imageUrl': 'https://images.pexels.com/photos/1485637/pexels-photo-1485637.jpeg?auto=compress&cs=tinysrgb&w=600',
    'description': 'Lorem ipsum dolor sit amet consectetur',
    'price': '17,00'
  },
  {
    'imageUrl': 'https://images.pexels.com/photos/1154861/pexels-photo-1154861.jpeg?auto=compress&cs=tinysrgb&w=600',
    'description': 'Lorem ipsum dolor sit amet consectetur',
    'price': '17,00'
  },
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Show Search Results')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const ImageSearchResultsSheet(),
            );
          },
          child: const Text('Show Image Search Results'),
        ),
      ),
    );
  }
}


// --- WIDGET CHÍNH CHO GIAO DIỆN KẾT QUẢ TÌM KIẾM ---

class ImageSearchResultsSheet extends StatelessWidget {
  const ImageSearchResultsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    // Chiếm 90% chiều cao màn hình
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.0),
              topRight: Radius.circular(24.0),
            ),
          ),
          child: Column(
            children: [
              // Header với tiêu đề và nút đóng
              _buildHeader(context),
              // Dòng chữ xác nhận
              _buildConfirmationBar(),
              const SizedBox(height: 24),
              // Lưới sản phẩm có thể cuộn
              Expanded(
                child: GridView.builder(
                  controller: controller, // Cho phép cuộn bên trong sheet
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 24.0,
                    childAspectRatio: 0.65, // Điều chỉnh tỉ lệ để card cao hơn
                  ),
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final item = searchResults[index];
                    return _ProductCard(
                      imageUrl: item['imageUrl']!,
                      description: item['description']!,
                      price: item['price']!,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- CÁC WIDGET CON ---

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Image Search',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 28),
            onPressed: () {
              // Đóng Bottom Sheet
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildConfirmationBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          const Text('Shoes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {},
            child: const Text(
              'Is this what you meant?',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}


// --- WIDGET TÁI SỬ DỤNG CHO THẺ SẢN PHẨM ---

class _ProductCard extends StatelessWidget {
  final String imageUrl;
  final String description;
  final String price;

  const _ProductCard({
    required this.imageUrl,
    required this.description,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const SizedBox(height: 8),
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
    );
  }
}