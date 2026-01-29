import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:recomart/config/color.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:recomart/views/pages/client/home/widgets/appBar_widget.dart';
import 'package:recomart/views/pages/client/home/widgets/product_widget.dart' hide AppColors;
import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:recomart/services/recommendation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchProductScreen extends StatefulWidget {
  final Function(String) onSearch;
  final String initialQuery;

  const SearchProductScreen({
    super.key,
    required this.onSearch,
    required this.initialQuery,
  });

  @override
  _SearchProductScreenState createState() => _SearchProductScreenState();
}

class _SearchProductScreenState extends State<SearchProductScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) runAddToCartAnimation;

  List<dynamic> _searchResults = [];
  List<String> _searchHistory = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  final List<Map<String, dynamic>> _hotSuggestions = [
    {'name': 'iPhone', 'icon': Icons.phone_iphone},
    {'name': 'Macbook', 'icon': Icons.laptop_mac},
    {'name': 'Asus', 'icon': Icons.computer},
    {'name': 'Samsung', 'icon': Icons.smartphone},
    {'name': 'AirPods', 'icon': Icons.headphones},
  ];

  @override
  void initState() {
    super.initState();
        _searchController.text = widget.initialQuery;
    _loadSearchHistory();
    _searchController.addListener(_handleSearchTextChange);
    if (widget.initialQuery.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch(query: widget.initialQuery);
      });
    }
  }

  void _handleSearchTextChange() {
    if (_searchController.text.isEmpty && _hasSearched) {
      setState(() {
        _hasSearched = false;
        _searchResults = [];
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchTextChange);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList('recent_searches') ?? [];
      setState(() {
        _searchHistory = history;
      });
    } catch (e) {
      print("Loading history fail!: $e");
    }
  }

  Future<void> _saveToHistory(String keyword) async {
    if (keyword.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    _searchHistory.remove(keyword);
    _searchHistory.insert(0, keyword);
    if (_searchHistory.length > 5) _searchHistory.removeLast();
    
    await prefs.setStringList('recent_searches', _searchHistory);
    setState(() {});
  }

  Future<void> _performSearch({String? query}) async {
    final keyword = query ?? _searchController.text.trim();
    if (keyword.isEmpty) return;

    if (query != null) _searchController.text = query;
    _saveToHistory(keyword);

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _searchResults = [];
    });

    try {
      var baseUrl = RecommendationService.baseUrl;
      final url = '$baseUrl/api/search?keyword=$keyword';
      final response = await http.get(Uri.parse(url), headers: {
        "ngrok-skip-browser-warning": "true",
        "Content-Type": "application/json",
      }).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _searchResults = data['results'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AddToCartAnimation(
      cartKey: cartKey,
      height: 30,
      width: 30,
      opacity: 0.85,
      createAddToCartAnimation: (run) => runAddToCartAnimation = run,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        appBar: AppBarHomeCustom(cartKey: cartKey),
        body: Column(
          children: [
            _buildModernSearchBar(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildModernSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(25)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: const Color(0xFFF1F2F6), borderRadius: BorderRadius.circular(15)),
              child: TextField(
                controller: _searchController,
                onSubmitted: (val) => _performSearch(),
                decoration: const InputDecoration(
                  hintText: 'Search Asus, Macbook...',
                  prefixIcon: Icon(FeatherIcons.search, size: 18, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Nút Filter
          IconButton(
            icon: const Icon(FeatherIcons.sliders),
            onPressed: _performSearch,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) return const Center(child: CupertinoActivityIndicator(radius: 15));
    if (_searchController.text.trim().isEmpty) {
      return _buildSuggestionsUI();
    }
    if (_hasSearched && _searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FeatherIcons.search, size: 50, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text("No results found for '${_searchController.text}'", 
                style: const TextStyle(color: Colors.grey)),
          ],
        )
      );
    }
    return _buildResultsGrid();
  }

  Widget _buildSuggestionsUI() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (_searchHistory.isNotEmpty) ...[
          const Text("Recent Searches", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: _searchHistory.map((h) => ActionChip(
              label: Text(h),
              onPressed: () => _performSearch(query: h),
              backgroundColor: Colors.white,
            )).toList(),
          ),
          const SizedBox(height: 25),
        ],
        const Text("Hot Suggestions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 15),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, 
            mainAxisSpacing: 10, 
            crossAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemCount: _hotSuggestions.length,
          itemBuilder: (context, index) {
            final item = _hotSuggestions[index];
            return GestureDetector(
              onTap: () => _performSearch(query: item['name']),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item['icon'], color: AppColors.primary, size: 28),
                    const SizedBox(height: 8),
                    Text(item['name'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildResultsGrid() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = _searchResults[index];

                // --- BƯỚC 1: Lấy dữ liệu thô ---
                // Ưu tiên 'imageUrl', nếu không có thì tìm 'image', không có nữa thì lấy rỗng
                String rawImg = (item['imageUrl'] ?? item['image'] ?? '').toString();

                // --- BƯỚC 2: In ra log để bắt lỗi (Xem ở tab Run/Terminal) ---
                print("--- DEBUG ẢNH VỊ TRÍ $index ---");
                print("Tên SP: ${item['name']}");
                print("Link gốc: '$rawImg'"); // Để trong nháy đơn để xem có dư khoảng trắng không

                // --- BƯỚC 3: Xử lý làm sạch chuỗi (Quan trọng nhất) ---
                String productImg = rawImg.trim(); // Cắt bỏ khoảng trắng đầu/cuối

                // Logic chọn ảnh cuối cùng
                if (productImg.isEmpty) {
                  // Link dự phòng nếu không có ảnh
                  productImg = 'https://via.placeholder.com/300x300.png?text=No+Image';
                } else if (!productImg.startsWith('http')) {
                   // Nếu link là đường dẫn nội bộ (không có http), nối thêm Base URL
                   // Ví dụ: assets/img.jpg -> https://api.com/assets/img.jpg
                   var baseUrl = RecommendationService.baseUrl;
                   // Xử lý dấu / để tránh bị 2 dấu //
                   if (!productImg.startsWith('/')) productImg = '/$productImg';
                   productImg = '$baseUrl$productImg';
                }

                print("Link sau xử lý: $productImg");

                return ProductView(
                  id: (item['id'] ?? '').toString(),
                  categoryId: (item['category'] ?? '').toString(),
                  name: (item['name'] ?? 'No Name').toString(),
                  image: productImg, // Truyền link đã xử lý sạch sẽ
                  price: (item['price'] ?? 0).toDouble(),
                  averageRating: (item['rating'] ?? '0').toString(),
                );
              },
              childCount: _searchResults.length,
            ),
          ),
        ),
      ],
    );
  }
}