import 'dart:async';
import 'package:flutter/material.dart';

import 'package:recomart/utils/responsive.dart';
import '../../../../../views/pages/admin/product/widgets/product_form.dart';

class ProductImageFE {
  final String? url;
  final String? publicId;

  ProductImageFE({this.url, this.publicId});

  Map<String, dynamic> toMap() {
    return {'url': url, 'public_id': publicId};
  }
}

class ProductEntityFE {
  final String id;
  final String productName;
  final bool isActive;
  final String categoryId;
  final String brandId;
  final ProductImageFE? productImage;
  final List<dynamic> variants;

  ProductEntityFE({
    required this.id,
    required this.productName,
    required this.isActive,
    required this.categoryId,
    required this.brandId,
    this.productImage,
    required this.variants,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'product_name': productName,
      'disabled': !isActive,
      'category': categoryId,
      'brand': brandId,
      'product_image': productImage?.toMap(),
      'variants': variants,
    };
  }
}

//Mockiup Dataset
final List<ProductEntityFE> FE_PRODUCT_DATA = [
  ProductEntityFE(
    id: '66a01',
    productName: 'Laptop Pro 14',
    isActive: true,
    categoryId: 'cat_id_1',
    brandId: 'brand_id_1',
    productImage: ProductImageFE(url: 'https://placehold.co/40x40/FF7F50/white?text=A'),
    variants: [{'quantity': 5}, {'quantity': 7}],
  ),
  ProductEntityFE(
    id: '66a02',
    productName: 'Gaming Mouse X',
    isActive: false,
    categoryId: 'cat_id_2',
    brandId: 'brand_id_2',
    productImage: ProductImageFE(url: 'https://placehold.co/40x40/3CB371/white?text=B'),
    variants: [{'quantity': 10}],
  ),
];

final Map<String, String> FE_CATEGORIES_MAP = {'cat_id_1': 'Laptop', 'cat_id_2': 'Phụ kiện'};
final Map<String, String> FE_BRANDS_MAP = {'brand_id_1': 'Brand A', 'brand_id_2': 'Brand B'};
const int FE_TOTAL_PAGE = 5;
const int FE_LIMIT = 12;


class ProductTable extends StatefulWidget {
  const ProductTable({super.key});

  @override
  State<ProductTable> createState() => _ProductTableState();
}

class _ProductTableState extends State<ProductTable> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<ProductEntityFE> _productsData = FE_PRODUCT_DATA;
  int _page = 1;
  int _limit = FE_LIMIT;
  int _totalPage = FE_TOTAL_PAGE;


  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isEmpty) {
        _fetchFilteredProductsManagement(page: 1, limit: _limit);
      } else {
        _searchFilteredProducts(
          name: _searchController.text,
          page: 1,
          limit: _limit,
        );
      }
    });
  }
  
  void _fetchFilteredProductsManagement({required int page, required int limit}) {
      setState(() {
          _page = page;
          _limit = limit;
          _productsData = FE_PRODUCT_DATA; 
          _totalPage = FE_TOTAL_PAGE;
      });
  }
  
  void _searchFilteredProducts({required String name, required int page, required int limit}) {
      setState(() {
          _page = page;
          _limit = limit;
          _productsData = FE_PRODUCT_DATA.where((p) => p.productName.toLowerCase().contains(name.toLowerCase())).toList();
          _totalPage = 1;
      });
  }


  List<ProductEntityFE> get filteredProducts {
    return _productsData;
  }

  List<ProductEntityFE> _sortProducts(List<ProductEntityFE> products) {
    return products..sort((a, b) => b.id.compareTo(a.id)); 
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Disabled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showProductForm(ProductEntityFE product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            product.productName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: const InputDecorationTheme(
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange, width: 2),
                ),
                labelStyle: TextStyle(color: Colors.black),
                floatingLabelStyle: TextStyle(color: Colors.orange),
              ),
            ),
            child: ProductForm(
              buttonLabel: 'Save',
              initialProduct: product.toMap(),
              onSubmit: (updatedProductData) async {
                print('ProductTable onSubmit: Logic updated UI state.');
                _fetchFilteredProductsManagement(page: _page, limit: _limit);
                Navigator.of(context).pop();
              },
              onDelete: () async {
                print('ProductTable onDelete: Logic updated UI state.');
                _fetchFilteredProductsManagement(page: 1, limit: _limit);
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }

  // Row Header Table (FE logic)
  TableRow buildHeaderRow(List<String> headers, List<double> colWidths) {
    return TableRow(
      decoration: const BoxDecoration(color: Color.fromARGB(255, 240, 240, 240)),
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

  TableRow buildProductRow(ProductEntityFE product, List<double> colWidths) {
    final isMobile = Responsive.isMobile(context);

    String getShortId(String id) {
      return id.length > 5 ? id.substring(0, 5) : id;
    }

    String categoryName = FE_CATEGORIES_MAP[product.categoryId] ?? 'N/A';
    String brandName = FE_BRANDS_MAP[product.brandId] ?? 'N/A';

    final totalStock = product.variants.isNotEmpty
        ? product.variants
        .map((variant) => variant['quantity'] ?? 0)
        .reduce((a, b) => a + b)
        .toString()
        : '0';

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
          child: cellText(product.isActive ? 'Active' : 'Disabled', colWidths[2]),
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
          child: cellText(brandName, colWidths[4]),
        ),
        InkWell(
          onTap: () => _showProductForm(product),
          child: Container(
            width: colWidths[5],
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Chip(
              label: Text(
                product.isActive ? 'Active' : 'Disabled',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: _getStatusColor(product.isActive ? 'Active' : 'Disabled'),
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

  Widget productCell(ProductEntityFE product, double width) {
    String getShortId(String id) {
      return id.length > 5 ? id.substring(0, 5) : id;
    }

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: product.productImage?.url != null && product.productImage!.url!.isNotEmpty
                ? Image.network(
              product.productImage!.url!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Center(child: Text("No Image")),
                );
              },
            )
                : Container(
              color: Colors.grey[300],
              child: const Center(child: Text("No Image")),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                Text(
                  'ID: ${getShortId(product.id)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Logic phân trang (FE logic)
  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _page > 1
              ? () {
            _fetchFilteredProductsManagement(
              page: _page - 1,
              limit: _limit,
            );
          }
              : null,
        ),
        Text('Page $_page of $_totalPage'),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _page < _totalPage
              ? () {
            _fetchFilteredProductsManagement(
              page: _page + 1,
              limit: _limit,
            );
          }
              : null,
        ),
        const SizedBox(width: 16),
        DropdownButton<int>(
          value: _limit,
          items: [12, 24, 48].map((value) => DropdownMenuItem(
            value: value,
            child: Text('$value per page'),
          )).toList(),
          onChanged: (value) {
            if (value != null) {
              _fetchFilteredProductsManagement(page: 1, limit: value);
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedProducts = _sortProducts(filteredProducts);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = Responsive.isMobile(context);
        final tableWidth = constraints.maxWidth;

        final List<double> colWidths = isMobile
            ? [tableWidth * 0.08, tableWidth * 0.55, tableWidth * 0.25]
            : [
          tableWidth * 0.08,
          tableWidth * 0.30,
          tableWidth * 0.12,
          tableWidth * 0.15,
          tableWidth * 0.15,
          tableWidth * 0.15,
        ];

        final headers = isMobile
            ? ['ID', 'Product', 'Status']
            : ['ID', 'Product', 'Stock', 'Category', 'Brand', 'Status'];

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
              // Header + Search
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Product List',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 200,
                    height: 36,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        hintText: 'Search by name',
                        prefixIcon: const Icon(Icons.search, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.orange),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Table
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth - 40,
                  child: Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: {
                      for (int i = 0; i < colWidths.length; i++) i: FixedColumnWidth(colWidths[i]),
                    },
                    border: TableBorder.all(color: Colors.grey.shade300),
                    children: [
                      buildHeaderRow(headers, colWidths),
                      ...sortedProducts.map((product) => buildProductRow(product, colWidths)),
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