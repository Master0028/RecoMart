import 'package:recomart/views/pages/client/home/widgets/appBar_widget.dart';
import 'package:recomart/views/pages/client/home/widgets/product_widget.dart';
import 'package:flutter/material.dart';
import 'package:recomart/config/color.dart';
import 'package:feather_icons/feather_icons.dart';

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

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery;
  }

  void _performSearch() {
    if (_searchController.text.isNotEmpty) {
      widget.onSearch(_searchController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarHomeCustom(),
      body: Column(
        children: [
          // Khu vực Search Bar Hiện Đại
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (value) => _performSearch(),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search for products...',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon: Icon(FeatherIcons.search, color: AppColors.primary),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(FeatherIcons.x, size: 20),
                              color: Colors.grey,
                              onPressed: () {
                                _searchController.clear();
                                setState(() {}); // Cập nhật UI để ẩn nút clear
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.grey.shade100, // Nền xám nhạt cho input
                      contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12), // Bo góc lớn hơn
                        borderSide: BorderSide.none, // Bỏ border
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary, width: 2), // Viền xanh dương khi focus
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {}); // Cập nhật UI để hiển thị nút clear
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // Nút Search (Màu Xanh dương chủ đạo)
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _performSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      elevation: 5, // Tạo độ nổi khối
                      shadowColor: AppColors.primary.withOpacity(0.4),
                    ),
                    child: const Icon(FeatherIcons.search, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          
          // Khu vực Kết quả Tìm kiếm
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Thanh hiển thị kết quả
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "Results for \"${_searchController.text}\"",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Thẻ số lượng tìm thấy (Tag style)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "1000 items found", // Giả định đây là dữ liệu tĩnh
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Danh sách sản phẩm (ProductListViewWidget)
                  const Expanded(
                    child: SingleChildScrollView(
                      child: ProductListViewWidget(),
                      //child: ProductListViewWidget(products: [],), // Mockup Dataset test
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}