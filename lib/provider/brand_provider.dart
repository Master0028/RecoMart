import 'package:flutter/material.dart';
import '../models/brand.model.dart';
import '../services/brand.service.dart';

class BrandProvider with ChangeNotifier {
  final BrandService _service = BrandService();

  List<BrandModel> _brands = [];
  List<BrandModel> get brands => _brands;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// 🟢 Lấy danh sách thương hiệu
  Future<void> fetchBrands() async {
    try {
      _isLoading = true;
      notifyListeners();

      _brands = await _service.fetchBrands();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🟢 Thêm thương hiệu
  Future<void> addBrand(BrandModel brand) async {
    try {
      await _service.addBrand(brand);
      await fetchBrands();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 🟢 Cập nhật thương hiệu
  Future<void> updateBrand(BrandModel brand) async {
    try {
      await _service.updateBrand(brand);
      await fetchBrands();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 🟢 Xoá thương hiệu
  Future<void> deleteBrand(String id) async {
    try {
      await _service.deleteBrand(id);
      await fetchBrands();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 🟢 Tìm kiếm thương hiệu
  Future<void> searchBrands(String keyword) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (keyword.isEmpty) {
        await fetchBrands();
      } else {
        _brands = await _service.searchBrands(keyword);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
