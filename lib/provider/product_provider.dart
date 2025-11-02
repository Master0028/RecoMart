import 'dart:core';
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

class ProductProvider with ChangeNotifier {
  List<ProductModel> products = [];
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

  final BrandService brandService = BrandService();
  final CategoryService categoryService = CategoryService();
  final ProductService productService = ProductService();

  Future<void> fetchBrands() async {
    try {
      final response = await brandService.getBrands();
      brands = response.map((brand) => brand).toList();

      // Lưu cache
      if (_brandBox != null) {
        await _brandBox!.clear();
        for (var brand in brands) {
          await _brandBox!.put(brand.id, brand);
        }
      }
    } catch (e) {
      // Nếu lỗi (mất mạng), lấy từ cache
      if (_brandBox != null && _brandBox!.isNotEmpty) {
        brands = _brandBox!.values.toList();
        debugPrint("Đã load brand từ cache do lỗi: $e");
      } else {
        debugPrint("Không có dữ liệu brand cache và lỗi xảy ra: $e");
      }
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await categoryService.getCategories();
      categories = response.map((category) => category).toList();
      await _updateCategoryHiveCache(categories);
    } catch (e) {
      // Nếu lỗi (mất mạng), lấy từ cache
      if (_categoryBox != null && _categoryBox!.isNotEmpty) {
        categories = _categoryBox!.values.toList();
        debugPrint("Đã load category từ cache do lỗi: $e");
      } else {
        debugPrint("Không có dữ liệu category cache và lỗi xảy ra: $e");
      }
    }

    notifyListeners();
  }

  Future<void> _updateCategoryHiveCache(
      List<CategoryModel> newCategories) async {
    if (_categoryBox == null) return;
    await _categoryBox!.clear();
    for (var category in newCategories) {
      await _categoryBox!.put(category.id, category);
    }
  }

}
