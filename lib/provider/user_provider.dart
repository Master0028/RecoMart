import 'package:flutter/material.dart';
import '../models/user.model.dart';
import '../services/user.service.dart';

class UserProvider with ChangeNotifier {
  final UserService _service = UserService();
  List<UserModel> _users = [];
  bool _loading = false;
  String? _error;

  List<UserModel> get users => _users;
  bool get loading => _loading;
  String? get error => _error;

  /// 🔹 Lấy danh sách người dùng
  Future<void> fetchUsers() async {
    try {
      _loading = true;
      notifyListeners();
      _users = await _service.fetchUsers();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// 🔹 Cập nhật thông tin người dùng
  Future<void> updateUser(UserModel user) async {
    try {
      await _service.updateUser(user);
      await fetchUsers();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 🔹 Cấm / mở khóa người dùng
  Future<void> toggleUserStatus(String id, bool isActive) async {
    try {
      await _service.toggleUserStatus(id, isActive);
      await fetchUsers();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 🔹 Xóa người dùng
  Future<void> deleteUser(String id) async {
    try {
      await _service.deleteUser(id);
      await fetchUsers();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
