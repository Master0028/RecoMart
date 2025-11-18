import 'package:flutter/material.dart';
import '../models/category.model.dart';
import '../services/category.service.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryService _service = CategoryService();

  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchCategories() async {
    try {
      _isLoading = true;
      notifyListeners();
      _categories = await _service.getCategories();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchCategories(String keyword) async {
    try {
      _isLoading = true;
      notifyListeners();
      _categories = await _service.searchCategories(keyword);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      await _service.addCategory(category);
      await fetchCategories();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      final docId = await _service.getDocIdByNumericId(category.id);

      if (docId != null) {
        await _service.updateCategory(category, docId);
        await fetchCategories();
      } else {
        _error = "Không tìm thấy danh mục có id = ${category.id}";
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      final numericId = int.tryParse(id) ?? 0;
      await _service.deleteCategoryByNumericId(numericId);

      await fetchCategories();

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      print('Lỗi khi xoá danh mục: $e');
    }
  }
}
