import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:recomart/components/custom/skeleton.dart';
import 'package:recomart/utils/responsive.dart';
import 'package:recomart/utils/widget/CustomAppBarMobile.dart';
import 'package:recomart/views/pages/client/search/widget/search_field.dart';
import '../../../../../services/api_service.dart';

class SearchScreen extends StatefulWidget {
  final List<String> recentSearches;
  const SearchScreen({super.key, required this.recentSearches});
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _ctrl = TextEditingController();
  late List<String> _recent;
  List<dynamic> _results = [];
  bool _loading = false;
  String _query = "";

  @override
  void initState() {
    super.initState();
    _recent = List.from(widget.recentSearches);
  }

  void _onSearch(String q) async {
    if (q.trim().isEmpty) return;
    setState(() { _query = q; _loading = true; _results = []; });
    try {
      final res = await ApiService.searchProducts(q);
      if (mounted) {
        setState(() {
          _results = res;
          if (!_recent.contains(q)) _recent.insert(0, q);
          if (_recent.length > 5) _recent.removeLast();
        });
      }
    } catch (e) {
      debugPrint("Search error: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBarMobile(title: "Search Product", isBack: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchField(
              controller: _ctrl,
              autofocus: true,
              onSubmitted: _onSearch,
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                if (_query.isEmpty && _recent.isNotEmpty) _buildRecentSliver(),
                if (_query.isNotEmpty) ...[
                  _buildHeaderSliver(),
                  _buildProductSliver(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSliver() => SliverToBoxAdapter(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(padding: EdgeInsets.all(16), child: Text("Recent", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Wrap(spacing: 8, children: _recent.map((s) => ActionChip(
          label: Text(s), 
          onPressed: () { _ctrl.text = s; _onSearch(s); }
        )).toList()),
      ),
    ]),
  );

  Widget _buildHeaderSliver() => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(child: Text('Results for "$_query"', style: const TextStyle(fontWeight: FontWeight.bold))),
        if (!_loading) Text("${_results.length} items", style: const TextStyle(color: Colors.blue)),
      ]),
    ),
  );

  Widget _buildProductSliver() {
    if (_loading) {
      return SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverGrid(
          gridDelegate: _gridDelegate(),
          delegate: SliverChildBuilderDelegate((_, __) => const Skeleton(), childCount: 4),
        ),
      );
    }
    if (_results.isEmpty) return const SliverFillRemaining(child: Center(child: Text("No results found.")));
    
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: _gridDelegate(),
        delegate: SliverChildBuilderDelegate((_, i) => ProductItem(data: _results[i]), childCount: _results.length),
      ),
    );
  }

  SliverGridDelegate _gridDelegate() => SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: Responsive.isDesktop(context) ? 4 : 2,
    childAspectRatio: 0.62,
    crossAxisSpacing: 12, 
    mainAxisSpacing: 12,
  );
}

class ProductItem extends StatelessWidget {
  final dynamic data;
  const ProductItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final String name = data['name'] ?? data['variantName'] ?? 'Unknown';
    final double price = (data['price'] is num) ? (data['price'] as num).toDouble() : 0.0;
    
    String rawImg = '';
    
    if (data['images'] != null && (data['images'] as List).isNotEmpty) {
      var first = data['images'][0];
      rawImg = (first is Map) ? (first['url'] ?? first['imageUrl'] ?? '') : first.toString();
    } else {
      rawImg = (data['image'] ?? data['imageUrl'] ?? '').toString();
    }

    String cleanImg = rawImg.trim();
    if (cleanImg.isNotEmpty && cleanImg.startsWith('http')) {
      cleanImg = Uri.encodeFull(cleanImg); 
    } else {
      cleanImg = 'https://via.placeholder.com/300';
    }

    return GestureDetector(
      onTap: () => context.push('/product-detail/${data['id']}'),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: cleanImg,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  memCacheHeight: 400, 
                  placeholder: (_, __) => const Skeleton(),
                  errorWidget: (context, url, error) {
                    debugPrint("Error to load image: $url | Error: $error");
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, height: 1.2),
                    ),
                    const Spacer(),
                    Text(
                      '${price.toStringAsFixed(0)} VND',
                      style: const TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
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