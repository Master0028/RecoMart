import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user.model.dart';
import '../services/user.service.dart';

class UserProvider with ChangeNotifier {
  final UserService _service = UserService();
  List<UserModel> _users = [];
  bool _loading = false;
  String? _error;
  double _loyaltyPoints = 0;
  double get loyaltyPoints => _loyaltyPoints;

  List<UserModel> get users => _users;
  bool get loading => _loading;
  String? get error => _error;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;

  UserModel? _userInfo;
  UserModel? get userInfo => _userInfo;

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

  Future<void> fetchUserInfo() async {
    try {
      _loading = true;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("⚠️ No Firebase user logged in");
        _currentUser = null;
        _loading = false;
        notifyListeners();
        return;
      }

      final userData = await _service.getUserById(user.uid);
      if (userData != null) {
        _userInfo = userData;
        print("✅ User info fetched: ${_userInfo!.fullName}");
      } else {
        print("⚠️ No user data found for UID ${user.uid}");
      }
    } catch (e) {
      print('❌ fetchUserInfo error: $e');
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

  /// 🔹 Cập nhật thông tin người dùng hiện tại
  Future<void> updateUserInfo({
    required String name,
    String? phone,
    String? address,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'fullName': name,
        'phone': phone,
        'address': address,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Cập nhật local model
      _userInfo = _userInfo?.copyWith(
        fullName: name,
        phone: phone,
        address: address,
      );

      notifyListeners();
      print("✅ User info updated successfully");
    } catch (e) {
      print("❌ Error updating user info: $e");
      _error = e.toString();
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

  Future<void> fetchLoyaltyPoints() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final points = await _service.getLoyaltyPoints(user.uid);
      _loyaltyPoints = points;
      notifyListeners();
      print("✅ Loyalty points fetched: $_loyaltyPoints");
    } catch (e) {
      print("❌ Error fetching loyalty points: $e");
    }
  }
}
