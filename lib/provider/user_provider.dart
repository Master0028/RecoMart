import 'package:firebase_auth/firebase_auth.dart';
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

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;

  UserProvider() {
    // Lắng nghe sự thay đổi đăng nhập
    _auth.authStateChanges().listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  /// Trả về user hiện tại (nếu đã đăng nhập)
  User? get currentUser => _currentUser;

  /// Kiểm tra xem đã đăng nhập chưa
  bool get isLoggedIn => _currentUser != null;

  /// Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  /// Reload user (nếu cần cập nhật avatar, displayName,...)
  Future<void> reloadUser() async {
    await _currentUser?.reload();
    _currentUser = _auth.currentUser;
    notifyListeners();
  }

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
