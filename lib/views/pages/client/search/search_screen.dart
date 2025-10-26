import 'package:recomart/components/custom/skeleton.dart';
import 'package:recomart/models/product.model.dart';
import 'package:recomart/services/product.service.dart';
import 'package:recomart/utils/responsive.dart';
import 'package:recomart/utils/widget/CustomAppBarMobile.dart';
import 'package:recomart/views/pages/client/home/widgets/product_widget.dart';
import 'package:recomart/views/pages/client/search/widget/search_field.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  final List<String> recentSearches;

  const SearchScreen({super.key, required this.recentSearches});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late List<String> _recentSearches;

  List<ProductModel> _searchResults = [];
  ProductService productService = ProductService();
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
      final result = await productService.searchProductVariants(name: query);
      setState(() {
        _searchResults = result['data'] as List<ProductModel>;
      });

      if (query.isNotEmpty) {
        _recentSearches.remove(query);
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 5) _recentSearches.removeLast();
      }
    } catch (e) {
      print("Search error: $e");
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
        spacing: 12.0, // Tăng khoảng cách
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
                  const Icon(Icons.history, size: 18, color: Color(0xFF757575)), // Giả định AppColors.disabledText
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
                                  color: Color(0xFF212121), // Giả định AppColors.darkText
                              ),
                            ),
                            TextButton(
                              onPressed: _clearAllSearches,
                              child: const Text(
                                "Xóa tất cả",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF1976D2), // Giả định AppColors.primary
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
                                      fontSize: 16, // Tăng kích thước
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF212121), // Giả định AppColors.darkText
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  "${_searchResults.length} sản phẩm",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1976D2), // Giả định AppColors.primary
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
                                products: _searchResults, isLoading: _isLoading),
                          ),
                        ],
                      ),
                    const SizedBox(height: 30), // Thêm khoảng cách cuối cùng
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
  final List<ProductModel> products;
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
            : null;

        return widget.isLoading
            ? const Skeleton()
            : ProductView(
                id: variant?.id ?? '',
                categoryId: variant?.categoryId ?? '',
                variantName: variant?.variantName ?? '',
                // Giả định images được xử lý đúng trong ProductView
                images: (variant?.images as List<ProductImage>), 
                price: (variant?.price as double),
                variantDescription: variant?.variantDescription ??
                    'No description available',
                averageRating: variant?.averageRating.toString() ?? '0.0',
              );
      },
    );
  }
}