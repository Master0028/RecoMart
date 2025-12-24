import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recomart/components/custom/skeleton.dart';
import 'package:recomart/utils/responsive.dart';
import 'package:recomart/utils/widget/CustomAppBarMobile.dart';
import 'package:recomart/views/pages/client/search/widget/search_field.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../services/api_service.dart';

class ProductImage { 
  final String url;
  ProductImage({required this.url});
}

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
      setState(() => _isLoading = false);
      return;
    }

    try {
      final results = await ApiService.searchProducts(query);
      
      if (mounted) {
        setState(() {
          _searchResults = results;
        });

        if (query.isNotEmpty) {
          if (_recentSearches.contains(query)) {
            _recentSearches.remove(query);
          }
          _recentSearches.insert(0, query);
          if (_recentSearches.length > 5) _recentSearches.removeLast();
        }
      }
    } catch (e) {
      print("Search UI error: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearAllSearches() {
    setState(() => _recentSearches.clear());
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
      appBar: CustomAppBarMobile(title: "Search Product", isBack: true),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      _buildRecentSearchesSection(),
                    
                    if (searchQuery.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Results for "$searchQuery"',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (!_isLoading)
                                  Text(
                                    "${_searchResults.length} items", 
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1976D2)),
                                  ),
                              ],
                            ),
                          ),
                          
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ProductListForSearch(
                                products: _searchResults, 
                                isLoading: _isLoading
                            ),
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

  Widget _buildRecentSearchesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Recent", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
              TextButton(
                onPressed: _clearAllSearches,
                child: const Text("Clear all", style: TextStyle(fontSize: 14, color: Color(0xFF1976D2), fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        Padding(
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
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0), 
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.history, size: 18, color: Color(0xFF757575)), 
                      const SizedBox(width: 8),
                      Text(search, style: const TextStyle(fontSize: 15, color: Color(0xFF212121), fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class ProductListForSearch extends StatelessWidget {
  final List<dynamic> products; 
  final bool isLoading;

  const ProductListForSearch({
    super.key,
    required this.products,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return GridView.builder(
        itemCount: 6,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: Responsive.isDesktop(context) ? 4 : 2,
          childAspectRatio: 0.6,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (_, __) => const Skeleton(),
      );
    }

    if (products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 50),
          child: Text("No results found.", style: TextStyle(color: Colors.grey)),
        )
      ); 
    }

    return GridView.builder(
      itemCount: products.length, 
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.isDesktop(context) ? 4 : 2,
        childAspectRatio: 0.60,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final variant = products[index];
        
        final String name = variant['name'] ?? variant['variantName'] ?? 'Unknown Product';
        
        final double price = (variant['price'] is int) 
            ? (variant['price'] as int).toDouble() 
            : (variant['price'] as double? ?? 0.0);

        List<ProductImage> imgList = [];
        if (variant['images'] != null && (variant['images'] as List).isNotEmpty) {
           var imgs = variant['images'] as List;
           if (imgs[0] is String) {
             imgList = imgs.map((e) => ProductImage(url: e)).toList().cast<ProductImage>();
           } else if (imgs[0] is Map) {
             imgList = imgs.map((e) => ProductImage(url: e['url'] ?? '')).toList().cast<ProductImage>();
           }
        }
        if (imgList.isEmpty) {
          if (variant['image'] != null && variant['image'] is String) {
             imgList.add(ProductImage(url: variant['image']));
          } else {
             imgList.add(ProductImage(url: 'https://via.placeholder.com/300'));
          }
        }

        final String description = variant['product_description'] ?? 
                                   variant['description'] ?? 
                                   variant['variantDescription'] ?? '';

        final String rating = variant['averageRating']?.toString() ?? '0.0';

        return ProductView( 
            id: variant['id'].toString(),
            categoryId: variant['categoryId'] ?? '',
            variantName: name,
            images: imgList, 
            price: price,
            variantDescription: description,
            averageRating: rating,
        );
      },
    );
  }
}

// === WIDGET ĐÃ SỬA LỖI OVERFLOW ===
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
          context.push('/product-detail/$id');
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
            // --- SỬA LỖI: Dùng Expanded thay vì cố định height 140 ---
            Expanded(
              flex: 5, // Chiếm 5 phần không gian (cho ảnh)
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: images.isNotEmpty ? images[0].url : '',
                    // SỬA LỖI: Wrap Skeleton trong FittedBox để nó không bị tràn khi không gian hẹp
                    placeholder: (context, url) => const FittedBox(
                      fit: BoxFit.cover,
                      child: SkeletonImage(imageHeight: 140),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            
            // --- Phần Text chiếm phần còn lại ---
            Expanded(
              flex: 4, // Chiếm 4 phần không gian (cho text)
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
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
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (variantDescription.isNotEmpty)
                          Text(
                            variantDescription,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${price.toStringAsFixed(0)} VND',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1976D2),
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              averageRating,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontSize: 12,
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