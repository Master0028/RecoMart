import 'package:flutter/material.dart';

final List<Map<String, String>> colorOptions = [
  {'image': 'https://images.pexels.com/photos/1485637/pexels-photo-1485637.jpeg?auto=compress&cs=tinysrgb&w=200'},
  {'image': 'https://images.pexels.com/photos/972804/pexels-photo-972804.jpeg?auto=compress&cs=tinysrgb&w=200'},
  {'image': 'https://images.pexels.com/photos/1154861/pexels-photo-1154861.jpeg?auto=compress&cs=tinysrgb&w=200'},
  {'image': 'https://images.pexels.com/photos/3268732/pexels-photo-3268732.jpeg?auto=compress&cs=tinysrgb&w=200'},
];
final List<String> sizeOptions = ['S', 'M', 'L', 'XL', 'XXL', 'XXXL'];

class ProductVariationsScreen extends StatelessWidget {
  const ProductVariationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Page')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const ProductVariationsSheet(),
            );
          },
          child: const Text('Show Variations'),
        ),
      ),
    );
  }
}

class ProductVariationsSheet extends StatefulWidget {
  const ProductVariationsSheet({super.key});

  @override
  State<ProductVariationsSheet> createState() => _ProductVariationsSheetState();
}

class _ProductVariationsSheetState extends State<ProductVariationsSheet> {
  int _selectedColorIndex = 0;
  int _selectedSizeIndex = 1;
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.85,
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
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildColorOptions(),
                    const SizedBox(height: 24),
                    _buildSizeOptions(),
                    const SizedBox(height: 24),
                    _buildQuantitySelector(),
                  ],
                ),
              ),
              // Thanh action cố định ở dưới cùng
              _buildActionButtons(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            'https://images.pexels.com/photos/1036627/pexels-photo-1036627.jpeg?auto=compress&cs=tinysrgb&w=300',
            width: 70,
            height: 70,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '\$17,00',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoChip('Pink'),
                const SizedBox(width: 8),
                _buildInfoChip('M'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.grey.shade100,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
      labelStyle: const TextStyle(fontSize: 12),
    );
  }

  Widget _buildColorOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Color Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: colorOptions.length,
            itemBuilder: (context, index) {
              bool isSelected = _selectedColorIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColorIndex = index;
                  });
                },
                child: Container(
                  width: 70,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(colorOptions[index]['image']!, fit: BoxFit.cover),
                      ),
                      if (isSelected)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.blue,
                              child: Icon(Icons.check, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildSizeOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Size', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: List.generate(sizeOptions.length, (index) {
            bool isSelected = _selectedSizeIndex == index;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSizeIndex = index;
                });
              },
              child: Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected ? Border.all(color: Colors.blue) : null,
                ),
                child: Center(
                  child: Text(
                    sizeOptions[index],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.blue : Colors.black54,
                    ),
                  ),
                ),
              ),
            );
          }),
        )
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Quantity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Row(
          children: [
            _buildQuantityButton(
              icon: Icons.remove,
              onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
            ),
            Container(
              width: 60,
              height: 40,
              alignment: Alignment.center,
              color: Colors.grey.shade100,
              child: Text('$_quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            _buildQuantityButton(
              icon: Icons.add,
              onPressed: () => setState(() => _quantity++),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildQuantityButton({required IconData icon, VoidCallback? onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: onPressed == null ? Colors.grey.shade300 : Colors.black87),
      ),
    );
  }

  Widget _buildActionButtons() {
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