import 'package:flutter/material.dart';

import 'package:recomart/components/custom/skeleton.dart';
import 'package:recomart/utils/responsive.dart';
import 'package:recomart/utils/widget/CustomAppBarMobile.dart';
import 'package:recomart/views/pages/client/home/widgets/product_widget.dart';
import 'package:recomart/views/pages/client/search/widget/search_field.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductImage { 
  final String url;
  ProductImage({required this.url});
}

final Map<String, dynamic> FE_PRODUCT_STUB = {
  'id': 'stub_id',
  'categoryId': 'stub_cat',
  'variantName': 'FE Product',
  'price': 1000000.0,
  'variantDescription': 'FE Description',
  'averageRating': 4.5,
  'images': [ProductImage(url: 'https://picsum.photos/id/500/300/300')],
};


class SearchScreen extends StatefulWidget {
  final List<String> recentSearches;

  const SearchScreen({super.key, required this.recentSearches});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late List<String> _recentSearches;

  List<dynamic> _searchResults = []; 
  bool _isLoading = false;

  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _recentSearches = List.from(widget.recentSearches);
  }

  void _updateSearch(String query) async {
    setState(() {
      searchQuery = query;
      _isLoading = true;
      _searchResults = [];
    });

    if (query.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      await Future.delayed(const Duration(milliseconds: 700));

      final List<dynamic> resultData = []; 
      
      setState(() {
        _searchResults = resultData;
      });

      if (query.isNotEmpty) {
        _recentSearches.remove(query);
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 5) _recentSearches.removeLast();
      }
    } catch (e) {
      print("Search error (Stub): $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearAllSearches() {
    setState(() {
      _recentSearches.clear();
    });
  }

  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty || searchQuery.isNotEmpty) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 12.0, 
        runSpacing: 12.0,
        children: _recentSearches.map((search) {
          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              _searchController.text = search;
              _updateSearch(search);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 18,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0), 
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.history, size: 18, color: Color(0xFF757575)), 
                  const SizedBox(width: 8),
                  Text(
                    search,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF212121),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBarMobile(title: "Tìm kiếm sản phẩm", isBack: true),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thanh tìm kiếm luôn ở trên cùng
            Padding(
              padding: const EdgeInsets.all(16),
              child: SearchField(
                controller: _searchController,
                autofocus: true,
                onSubmitted: _updateSearch,
                onChanged: (value) => setState(() => searchQuery = value), 
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_recentSearches.isNotEmpty && searchQuery.isEmpty)
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Gần đây",
                              style: TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF212121),
                              ),
                            ),
                            TextButton(
                              onPressed: _clearAllSearches,
                              child: const Text(
                                "Xóa tất cả",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF1976D2), 
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    if (searchQuery.isEmpty)
                      _buildRecentSearches()
                    
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Kết quả cho "$searchQuery"',
                                    style: const TextStyle(
                                      fontSize: 16, 
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF212121),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  "${_searchResults.length} sản phẩm", 
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1976D2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Danh sách sản phẩm
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            child: ProductListForSearch(
                                products: _searchResults, 
                                isLoading: _isLoading),
                          ),
                        ],
                      ),
                    const SizedBox(height: 30), 
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductListForSearch extends StatefulWidget {
  final List<dynamic> products; 
  final bool isLoading;

  const ProductListForSearch({
    super.key,
    required this.products,
    required this.isLoading,
  });

  @override
  State<ProductListForSearch> createState() => _ProductListForSearchState();
}

class _ProductListForSearchState extends State<ProductListForSearch> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: widget.isLoading ? 10 : widget.products.length, 
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.isDesktop(context) ? 4 : 2,
        childAspectRatio: 0.55,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        mainAxisExtent: 350,
      ),
      itemBuilder: (context, index) {
        final variant = !widget.isLoading && index < widget.products.length
            ? widget.products[index] 
            : FE_PRODUCT_STUB;

        if (widget.isLoading) {
             return const Skeleton();
        }
        
        if (widget.products.isEmpty) {
            return const Center(child: Text("No results found.")); 
        }

        return ProductView( 
            id: variant['id'] ?? 'FE_ID',
            categoryId: variant['categoryId'] ?? 'FE_CAT',
            variantName: variant['variantName'] ?? 'FE Product',
            images: (variant['images'] as List<ProductImage>), 
            price: (variant['price'] as double) ?? 0.0,
            variantDescription: variant['variantDescription'] ??
                'No description available.',
            averageRating: variant['averageRating']?.toString() ?? '0.0',
          );
      },
    );
  }
}

class ProductView extends StatelessWidget {
  final String variantName;
  final List<ProductImage> images;
  final double price;
  final String variantDescription;
  final String averageRating;
  final String id;
  final String categoryId;

  const ProductView({
    super.key,
    required this.id,
    required this.variantName,
    required this.images,
    required this.price,
    required this.variantDescription,
    required this.averageRating,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
          print('Navigate to product detail ID: $id');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1976D2).withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1976D2).withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 150,
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: images.isNotEmpty ? images[0].url : 'default_image_url',
                  placeholder: (context, url) => const SkeletonImage(
                    imageHeight: 140,
                  ),
                  errorWidget: (context, url, error) =>
                      Image.asset('assets/images/image_default_error.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          variantName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          variantDescription,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$price VNĐ',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1976D2),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              averageRating,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}