import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recomart/consts/index.dart';
import 'package:recomart/helpers/formatMoney.dart';
import 'package:recomart/models/brand.model.dart';
import 'package:recomart/models/category.model.dart';
import 'package:recomart/models/product.model.dart';
import 'package:recomart/services/app_exceptions.dart';
import 'package:recomart/services/brand.service.dart';
import 'package:recomart/services/category.service.dart';
import 'package:recomart/services/product.service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../views/pages/admin/brand/widgets/brand_table.dart';

class ProductProvider with ChangeNotifier {
  List<ProductModel> _products = [];
  List<BrandModel> brands = [];
  List<CategoryModel> categories = [];
  List<String> filters = [];
  String? selectedCategoryId;
  String? selectedBrandId;
  int page = 1;
  int limit = 12;
  int totalPage = 0;
  String? errorMessage;
  Box<ProductModel>? _productBox;
  Box<CategoryModel>? _categoryBox;
  Box<BrandModel>? _brandBox;
  bool _loading = false;

  DocumentSnapshot? _lastDoc;
  int _currentPage = 1;
  int get currentPage => _currentPage;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  // --- Filter values ---
  String? _categoryId;
  String? _brandId;
  double? _minPrice;
  double? _maxPrice;
  double? _minRating;

  List<ProductModel> get products => _products;
  bool get loading => _loading;

  Map<String, String> _categoriesMap = {};
  Map<String, String> get categoriesMap => _categoriesMap;

  Map<String, String> _brandsMap = {};
  Map<String, String> get brandsMap => _brandsMap;

  final ProductService _productService = ProductService();


  /// 🔹 Lấy danh sách sản phẩm
  Future<void> fetchProducts() async {
    _loading = true;
    notifyListeners();
    try {
      _products = await _productService.getProducts();
    } catch (e) {
      debugPrint('❌ Lỗi load sản phẩm: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// ✅ Lấy sản phẩm theo trang
  Future<void> fetchProductsPaginated({int page = 1, int limit = 10}) async {
    _loading = true;
    notifyListeners();
    try {
      _products = await _productService.getProductsPaginated(page: page, limit: limit);
    } catch (e) {
      debugPrint('⚠️ Lỗi load sản phẩm: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(ProductModel data) async {
    await _productService.createProduct(data);
    await fetchProducts();
  }

  /// 🔹 Cập nhật sản phẩm
  Future<void> updateProduct(String id, ProductModel data) async {
    await _productService.updateProduct(id, data);
    await fetchProducts();
  }

  /// 🔹 Xóa sản phẩm
  Future<void> deleteProduct(String id) async {
    await _productService.deleteProduct(id);
    await fetchProducts();
  }

  Future<void> fetchCategories() async {
    try {
      _categoriesMap = await _productService.getCategories();
      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ Lỗi tải categories: $e');
    }
  }

  Future<void> fetchBrands() async {
    try {
      _brandsMap = await _productService.getBrands();
      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ Lỗi tải brands: $e');
    }
  }

  Future<void> fetchProductsFilter({bool reset = false}) async {
    if (reset) {
      _products.clear();
      _lastDoc = null;
      _hasMore = true;
      _currentPage = 1;
      notifyListeners();
    }

    if (!_hasMore) return;

    _loading = true;
    notifyListeners();

    try {
      final List<ProductModel> newProducts =
      await _productService.getProductsWithPagination(
        limit: 10,
        lastDoc: _lastDoc,
        categoryId: _categoryId,
        brandId: _brandId,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        minRating: _minRating,
      );

      if (newProducts.isEmpty || newProducts.length < 10) {
        _hasMore = false;
      }

      if (newProducts.isNotEmpty) {
        _lastDoc = await FirebaseFirestore.instance
            .collection('products')
            .doc(newProducts.last.id)
            .get();
        _products.addAll(newProducts);
      }

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _hasMore = false;
      print("❌ Lỗi fetchProductsFilter: $e");
      notifyListeners();
    }
  }

  /// Cập nhật filter và refetch
  void updateFilters({
    String? categoryId,
    String? brandId,
    double? minPrice,
    double? maxPrice,
    double? minRating,
  }) {
    _categoryId = categoryId;
    _brandId = brandId;
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    _minRating = minRating;

    fetchProductsFilter(reset: true);
  }

  /// Chuyển trang
  Future<void> nextPage() async {
    if (_hasMore) {
      _currentPage++;
      await fetchProductsFilter();
    }
  }

  Future<void> resetFilters() async {
    _categoryId = null;
    _brandId = null;
    _minPrice = null;
    _maxPrice = null;
    _minRating = null;
    await fetchProductsFilter(reset: true);
  }
}
