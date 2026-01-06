import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../models/product.model.dart';
import '../../../../../provider/product_provider.dart';
import 'package:recomart/utils/responsive.dart';
import '../../../../../views/pages/admin/product/widgets/product_form.dart';
import 'add_product_btn.dart';

class ProductTable extends StatefulWidget {
  const ProductTable({super.key});

  @override
  State<ProductTable> createState() => _ProductTableState();
}

class _ProductTableState extends State<ProductTable> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<ProductModel> _productsData = [];
  Map<String, String> _categoryMap = {};
  int _page = 1;
  bool _hasNextPage = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _fetchCategories(),
      _fetchBrands(),
      _fetchFromFirebase(page: 1),
    ]);
  }

  Future<void> _fetchCategories() async {
    try {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      await provider.fetchCategories();
      if (!mounted) return;
      setState(() {
        _categoryMap = provider.categoriesMap;
      });
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<void> _fetchBrands() async {
    try {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      await provider.fetchBrands();
    } catch (e) {
      debugPrint('Error loading brands: $e');
    }
  }

  Future<void> _fetchFromFirebase({int page = 1}) async {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    
    await provider.fetchProductsPaginated(page: page);

    if (!mounted) return;

    setState(() {
      _page = page;
      _productsData = List.from(provider.products);
      _hasNextPage = provider.hasMore; 
    });
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      final text = _searchController.text.toLowerCase();
      final provider = Provider.of<ProductProvider>(context, listen: false);

      setState(() {
        _productsData = text.isEmpty
            ? List.from(provider.products)
            : provider.products
                .where((p) => p.name.toLowerCase().contains(text))
                .toList();
      });
    });
  }

  List<ProductModel> get filteredProducts {
    return _productsData;
  }

  List<ProductModel> _sortProducts(List<ProductModel> products) {
    return products..sort((a, b) => b.id.compareTo(a.id));
  }

  Color _getStatusColor(bool isActive) {
    return isActive ? Colors.green : Colors.red;
  }

  void _showProductForm(ProductModel product) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(product.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          content: ProductForm(
            buttonLabel: 'Save',
            initialProduct: product.toJson(),
            onSubmit: (updatedData) async {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop();
                }
              });

              if (mounted) await _fetchFromFirebase(page: 1);
            },
            onDelete: () async {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop();
                }
              });

              await Provider.of<ProductProvider>(context, listen: false)
                  .deleteProduct(product.id);

              if (mounted) await _fetchFromFirebase(page: 1);
            },
          ),
        );
      },
    );
  }

  TableRow buildHeaderRow(List<String> headers, List<double> colWidths) {
    return TableRow(
      decoration:
          const BoxDecoration(color: Color.fromARGB(255, 240, 240, 240)),
      children: List.generate(headers.length, (index) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          width: colWidths[index],
          child: Text(
            headers[index],
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }),
    );
  }

  TableRow buildProductRow(ProductModel product, List<double> colWidths) {
    final isMobile = Responsive.isMobile(context);
    String getShortId(String id) => id.length > 5 ? id.substring(0, 5) : id;

    String categoryName = _categoryMap[product.categoryId] ?? 'N/A';
    final totalStock = product.stock.toString();

    return TableRow(
      children: isMobile
          ? [
              InkWell(
                onTap: () => _showProductForm(product),
                child: cellText(getShortId(product.id), colWidths[0]),
              ),
              InkWell(
                onTap: () => _showProductForm(product),
                child: productCell(product, colWidths[1]),
              ),
              InkWell(
                onTap: () => _showProductForm(product),
                child: cellText(
                    product.isActive ? 'Active' : 'Disabled', colWidths[2]),
              ),
            ]
          : [
              InkWell(
                onTap: () => _showProductForm(product),
                child: cellText(getShortId(product.id), colWidths[0]),
              ),
              InkWell(
                onTap: () => _showProductForm(product),
                child: productCell(product, colWidths[1]),
              ),
              InkWell(
                onTap: () => _showProductForm(product),
                child: cellText(totalStock, colWidths[2]),
              ),
              InkWell(
                onTap: () => _showProductForm(product),
                child: cellText(categoryName, colWidths[3]),
              ),
              InkWell(
                onTap: () => _showProductForm(product),
                child: Container(
                  width: colWidths[4],
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Chip(
                    label: Text(
                      product.isActive ? 'Active' : 'Disabled',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: _getStatusColor(product.isActive),
                  ),
                ),
              ),
            ],
    );
  }

  Widget cellText(String text, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  Widget productCell(ProductModel product, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                width: 50,
                height: 50,
                alignment: Alignment.center,
                child: const Text("No Image"),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Price: ${product.price.toStringAsFixed(0)}₫'),
                Text('Stock: ${product.stock}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _page > 1 ? () => _fetchFromFirebase(page: _page - 1) : null,
        ),
        Text('Page $_page'),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _hasNextPage ? () => _fetchFromFirebase(page: _page + 1) : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final sortedProducts = _sortProducts(filteredProducts);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = Responsive.isMobile(context);
        final tableWidth = constraints.maxWidth;

        final List<double> colWidths = isMobile
            ? [tableWidth * 0.08, tableWidth * 0.55, tableWidth * 0.25]
            : [
                tableWidth * 0.08,
                tableWidth * 0.35,
                tableWidth * 0.12,
                tableWidth * 0.20,
                tableWidth * 0.15,
              ];

        final headers = isMobile
            ? ['ID', 'Product', 'Status']
            : ['ID', 'Product', 'Stock', 'Category', 'Status'];

        Widget buildSearchBar({bool fullWidth = false}) {
          return Row(
            children: [
              fullWidth
                  ? Expanded(
                      child: SizedBox(
                        height: 36,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            hintText: 'Search by name',
                            prefixIcon: const Icon(Icons.search, size: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    )
                  : SizedBox(
                      width: 200,
                      height: 36,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          hintText: 'Search by name',
                          prefixIcon: const Icon(Icons.search, size: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
              const SizedBox(width: 12),
              AddProductButton(onProductAdded: () => _fetchFromFirebase(page: 1)),
            ],
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(50),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMobile) ...[
                const Text(
                  'Product List',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                buildSearchBar(fullWidth: true),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Product List',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    buildSearchBar(fullWidth: false),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth > 600 ? tableWidth - 40 : 600, 
                  child: Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: {
                      for (int i = 0; i < colWidths.length; i++)
                        i: FixedColumnWidth(colWidths[i]),
                    },
                    border: TableBorder.all(color: Colors.grey.shade300),
                    children: [
                      buildHeaderRow(headers, colWidths),
                      ...sortedProducts
                          .map((product) => buildProductRow(product, colWidths)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildPagination(),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}