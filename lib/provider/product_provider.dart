import 'package:flutter/material.dart';
import '../models/product.model.dart';
import '../models/brand.model.dart';
import '../models/category.model.dart';
import '../models/review.model.dart';
import '../services/product.service.dart';
import '../services/review.service.dart';

class ProductProvider with ChangeNotifier {
  List<ProductModel> _products = [];
  List<BrandModel> brands = [];
  List<CategoryModel> categories = [];
  
  bool _loading = false;
  int _currentPage = 1;
  int limit = 12;
  bool _hasMore = true;
  String? errorMessage;

  String? _categoryId;
  String? _brandId;
  double? _minPrice;
  double? _maxPrice;
  // ignore: unused_field
  double? _minRating;
  String _currentSort = 'All Products';

  List<ProductModel> get products => _products;
  bool get loading => _loading;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;
  String get currentSort => _currentSort;

  final ProductService _productService = ProductService();
  final ReviewService _reviewService = ReviewService();

  Map<String, String> _categoriesMap = {};
  Map<String, String> get categoriesMap => _categoriesMap;
  Map<String, String> _brandsMap = {};
  Map<String, String> get brandsMap => _brandsMap;
  
  Map<String, List<ReviewModel>> _productReviews = {};
  Map<String, List<ReviewModel>> get productReviews => _productReviews;

  Future<void> fetchProductsPaginated({int page = 1, bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _products = [];
      _hasMore = true;
    } else {
      _currentPage = page;
    }

    _loading = true;
    notifyListeners();

    try {
      String? apiSortParam = _getApiSortParam(_currentSort);

      if (_hasActiveFilters()) {
        final filteredList = await _productService.getProductsByCategory(
             _categoryId ?? '' 
        );
        
        _products = filteredList;
        _hasMore = false;
      } else {
        final newProducts = await _productService.getProducts(
          page: _currentPage,
          limit: limit,
          sort: apiSortParam,
        );

        if (refresh) {
          _products = newProducts;
        } else {
          _products.addAll(newProducts);
        }

        _hasMore = newProducts.length == limit;
      }
    } catch (e) {
      errorMessage = 'Failed to load products';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  bool _hasActiveFilters() {
    return _categoryId != null || _brandId != null || _minPrice != null || _maxPrice != null;
  }

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

    fetchProductsPaginated(refresh: true);
  }

  Future<void> resetFilters() async {
    _categoryId = null;
    _brandId = null;
    _minPrice = null;
    _maxPrice = null;
    _minRating = null;
    _currentSort = 'All Products';
    
    await fetchProductsPaginated(refresh: true);
  }

  void sortProducts(String sortOption) {
    if (_currentSort == sortOption) return;
    
    _currentSort = sortOption;
    fetchProductsPaginated(refresh: true);
  }

  String? _getApiSortParam(String uiSort) {
    switch (uiSort) {
      case 'Price: Low to High': return 'price_asc';
      case 'Price: High to Low': return 'price_desc';
      case 'Name: A to Z': return 'name_asc';
      case 'Name: Z to A': return 'name_desc';
      default: return null;
    }
  }

  Future<void> addProduct(ProductModel data) async {
    await _productService.createProduct(data);
    fetchProductsPaginated(refresh: true);
  }

  Future<void> updateProduct(String id, ProductModel data) async {
    await _productService.updateProduct(id, data);
    fetchProductsPaginated(refresh: true);
  }

  Future<void> deleteProduct(String id) async {
    await _productService.deleteProduct(id);
    fetchProductsPaginated(refresh: true);
  }

  Future<void> fetchCategories() async {
    notifyListeners();
  }

  Future<void> fetchBrands() async {
    notifyListeners();
  }

  Future<void> addReview({
    required String productId,
    required String userId,
    required String content,
    required int rating,
    required String userName,
    required String userAvatar,
  }) async {
    try {
      final review = ReviewModel(
        id: '',
        productId: productId,
        userId: userId,
        content: content,
        rating: rating,
        user: UserModelForReview(
          id: userId,
          name: userName,
          avatar: userAvatar,
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _reviewService.addReviewForProduct(productId, review);

      if (_productReviews[productId] == null) {
        _productReviews[productId] = [];
      }
      _productReviews[productId]!.insert(0, review);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}