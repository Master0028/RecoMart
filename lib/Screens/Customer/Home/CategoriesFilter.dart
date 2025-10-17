import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final List<Map<String, dynamic>> categoryData = [
  {
    'image': 'https://images.pexels.com/photos/298863/pexels-photo-298863.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'name': 'Clothing',
    'subCategories': ['Dresses', 'Pants', 'Skirts', 'Shorts', 'Jackets', 'Hoodies', 'Shirts', 'Polo', 'T-Shirts', 'Tunics'],
    'isExpanded': true, // Mặc định mở
  },
  {
    'image': 'https://images.pexels.com/photos/19090/pexels-photo.jpg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'name': 'Shoes',
    'subCategories': ['Sneakers', 'Boots', 'Sandals', 'Heels'],
    'isExpanded': false,
  },
  {
    'image': 'https://images.pexels.com/photos/1457983/pexels-photo-1457983.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'name': 'Bags',
    'subCategories': ['Backpacks', 'Handbags', 'Totes'],
    'isExpanded': false,
  },
   {
    'image': 'https://images.pexels.com/photos/4210313/pexels-photo-4210313.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'name': 'Lingerie',
    'subCategories': [],
    'isExpanded': false,
  },
  {
    'image': 'https://images.pexels.com/photos/3771649/pexels-photo-3771649.jpeg?auto=compress&cs=tinysrgb&w=600',
    'name': 'Accessories',
    'subCategories': ['Watches', 'Belts', 'Hats'],
    'isExpanded': false,
  },
];

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  int _selectedGenderIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildGenderFilters(),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: categoryData.length + 1,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index < categoryData.length) {
                      return _buildCategoryItem(index);
                    } else {
                      return _buildJustForYou(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'All Categories',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 28),
            onPressed: () {
              context.pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGenderFilters() {
    final genders = ['All', 'Female', 'Male'];
    return Row(
      children: List.generate(genders.length, (index) {
        bool isSelected = _selectedGenderIndex == index;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedGenderIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.shade600 : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: isSelected ? null : Border.all(color: Colors.grey.shade300),
              ),
              child: Center(
                child: Text(
                  genders[index],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black54,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
  
  // Widget cho một mục danh mục (ví dụ: Clothing, Shoes)
  Widget _buildCategoryItem(int index) {
    final item = categoryData[index];
    bool isExpanded = item['isExpanded'];
    List<String> subCategories = item['subCategories'];

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _CategoryHeader(
            imageUrl: item['image'],
            name: item['name'],
            isExpanded: isExpanded,
            hasSubCategories: subCategories.isNotEmpty,
            onTap: () {
              setState(() {
                for (var data in categoryData) {
                  data['isExpanded'] = false;
                }
                item['isExpanded'] = !isExpanded;
              });
            },
          ),
          if (isExpanded && subCategories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: subCategories.map((subCategory) {
                  return OutlinedButton(
                    onPressed: () {
                      debugPrint("Đã nhấn vào: $subCategory");
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      backgroundColor: Colors.grey.shade50,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(subCategory),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildJustForYou(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            'https://images.pexels.com/photos/1126993/pexels-photo-1126993.jpeg?auto=compress&cs=tinysrgb&w=600',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
        title: const Row(
          children: [
            Text('Just for You', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            SizedBox(width: 4),
            Icon(Icons.star, color: Colors.blue, size: 16),
          ],
        ),
        trailing: Container(
          decoration: BoxDecoration(
            color: Colors.blue.shade600,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: () {
              // Dùng go_router để điều hướng
              context.push('/just-for-you');
            },
          ),
        ),
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final String imageUrl;
  final String name;
  final bool isExpanded;
  final bool hasSubCategories;
  final VoidCallback onTap;

  const _CategoryHeader({
    required this.imageUrl,
    required this.name,
    required this.isExpanded,
    required this.hasSubCategories,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: hasSubCategories ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ),
            if (hasSubCategories)
              Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.blue.shade600),
          ],
        ),
      ),
    );
  }
}