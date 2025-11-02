import 'package:go_router/go_router.dart';
import 'package:recomart/views/pages/client/search/search_product_screen.dart';
import 'package:recomart/views/pages/client/search/search_screen.dart';
import 'package:recomart/views/pages/client/search/widget/search_field.dart';
import 'package:flutter/material.dart';
import 'package:recomart/utils/responsive.dart';
import 'package:recomart/config/color.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({super.key});

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _recentSearches = [
    "Macbook",
    "Lenovo",
    "Asus",
    "Chuột không dây",
    "Bàn phím cơ",
    "Màn hình ",
    "Tai nghe Gaming"
  ];
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  String _currentQuery = '';

  void _openSearchScreen({String? query}) {
    _removeOverlay();

    if (Responsive.isDesktop(context)) {
      final finalQuery = query ?? _searchController.text;
      if (finalQuery.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchProductScreen(
              onSearch: (newQuery) {},
              initialQuery: finalQuery,
            ),
          ),
        );
      } else {
        _showOverlay();
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchScreen(recentSearches: _recentSearches),
        ),
      );
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _removeOverlay,
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.transparent)),
            Positioned(
              width: 400,
              child: CompositedTransformFollower(
                link: _layerLink,
                offset: const Offset(0, 50),
                child: Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_recentSearches.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Gần đây",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                TextButton(
                                  onPressed: _clearAllSearches,
                                  child: Text(
                                    "Xóa tất cả",
                                    style: TextStyle(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(),
                        ],
                        ..._recentSearches
                            .where((search) => search
                                .toLowerCase()
                                .contains(_currentQuery.toLowerCase()))
                            .map((search) {
                          return ListTile(
                            title: Text(search),
                            onTap: () {
                              _searchController.text = search;
                              _removeOverlay();
                              _openSearchScreen(query: search);
                            },
                            trailing: IconButton(
                              icon:
                                  const Icon(Icons.close, color: Colors.grey),
                              onPressed: () => _removeRecentSearch(search),
                            ),
                          );
                        }),
                        if (_recentSearches
                            .where((search) => search
                                .toLowerCase()
                                .contains(_currentQuery.toLowerCase()))
                            .isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Không có kết quả gần đây nào."),
                          )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (Overlay.of(context) != null) {
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _clearAllSearches() {
    setState(() {
      _recentSearches.clear();
    });
    _removeOverlay();
    _showOverlay();
  }

  void _removeRecentSearch(String search) {
    setState(() {
      _recentSearches.remove(search);
    });
    _removeOverlay();
    _showOverlay();
  }

  void _onSearchFieldChanged(dynamic inputValue) {
    final String value = inputValue.toString();

    setState(() {
      _currentQuery = value;
    });
    if (Responsive.isDesktop(context)) {
      if (value.isNotEmpty || _recentSearches.isNotEmpty) {
        if (_overlayEntry == null) {
          _showOverlay();
        }
      } else {
        _removeOverlay();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Row(
        mainAxisAlignment: Responsive.isDesktop(context)
            ? MainAxisAlignment.start
            : MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: Responsive.isDesktop(context)
                ? 400
                : MediaQuery.of(context).size.width * 0.7,
            child: SearchField(
              controller: _searchController,
              onChanged: _onSearchFieldChanged,

              onTap: () => {
                if (!Responsive.isDesktop(context))
                  {_openSearchScreen()}
                else
                  {_showOverlay()}
              },
              onSubmitted: (query) {
                _removeOverlay();
                _openSearchScreen(query: query);
              },
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              onPressed: () {
                context.push('/search-camera');
              },
              icon: const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}