import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recomart/models/interaction_model.dart';
import 'package:recomart/services/interaction_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.model.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  final InteractionService _interactionService = InteractionService();
  String? _userId;
  String? _userName;
  String? _accessToken;
  
  UserModel? _userInfo;
  
  List<UserModel> _users = [];

  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;
  String get userId => _userId ?? "";
  String get userName => _userName ?? "Guest";
  String? get accessToken => _accessToken;
  
  UserModel? get user => _userInfo;
  UserModel? get userInfo => _userInfo;
  
  List<UserModel> get users => _users;

  bool get isLoggedIn => _userId != null && _userId!.isNotEmpty;

  UserProvider() {
    _loadFromPrefs();
  }

  Future<void> loginSuccess(String id, String name, String token) async {
    _userId = id;
    _userName = name;
    _accessToken = token;

    await _saveToPrefs();

    // LẤY TOÀN BỘ USER TỪ FIRESTORE
    await fetchUserInfo();

    notifyListeners();
  }
  
  void setUser(UserModel user) {
    _userInfo = user;
    _userId = user.id;
    _userName = user.fullName;
    notifyListeners();
  }

  Future<void> logout() async {
    await signOut();
  }

  Future<void> signOut() async {
    _userId = null;
    _userName = null;
    _accessToken = null;
    _userInfo = null;
    _users = [];

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (_userId != null) await prefs.setString('user_id', _userId!);
    if (_userName != null) await prefs.setString('user_name', _userName!);
    if (_accessToken != null) await prefs.setString('access_token', _accessToken!);
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('user_id');
    _userName = prefs.getString('user_name');
    _accessToken = prefs.getString('access_token');

    if (_userId != null && _userId!.isNotEmpty) {
      await fetchUserInfo(); // FIRESTORE LÀ NGUỒN DUY NHẤT
    }

    notifyListeners();
  }

  Future<void> fetchUsers() async {
    _loading = true;
    notifyListeners();

    try {
      final data = await ApiService.getAllUsers();
      _users = data.map((json) => UserModel.fromJson(json)).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> toggleUserStatus(String id, bool newStatus) async {
    try {
      await ApiService.toggleUserStatus(id, newStatus);

      final index = _users.indexWhere((u) => u.id == id);
      if (index != -1) {
        _users[index] = _users[index].copyWith(isActive: newStatus);
        notifyListeners(); 
      }
    } catch (e) {
      print("Error toggling status: $e");
      _error = e.toString();
      notifyListeners();
      rethrow; 
    }
  }

  Future<void> fetchUserInfo() async {
    if (_userId == null || _userId!.isEmpty) return;

    _loading = true;
    notifyListeners();

    try {
      final docSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .get();

      if (!docSnap.exists) {
        throw Exception("User not found in Firestore");
      }

      final data = docSnap.data()!;

      _userInfo = UserModel.fromJson({
        ...data,
        'id': _userId,
      });

      _userName = _userInfo!.fullName;
      _error = null;

    } catch (e) {
      print("fetchUserInfo error: $e");
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserInfo({
    required String name,
    String? phone,
    String? address,
  }) async {
    if (!isLoggedIn) return;

    try {
      _loading = true;
      notifyListeners();

      _userName = name;
      _userInfo = _userInfo?.copyWith(
        fullName: name,
        phone: phone,
        address: address,
      );
      
      await _saveToPrefs();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(UserModel updatedUser) async {
    try {
      _loading = true;
      notifyListeners();

      await ApiService.updateUser(updatedUser);

      // LẤY LẠI USER TỪ FIRESTORE
      await fetchUserInfo();

      await _saveToPrefs();

    } catch (e) {
      print("Error updating user: $e");
      _error = e.toString();
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> trackInteraction({
    required String productId,
    required InteractionType type,
    int? duration,
  }) async {
    final interaction = InteractionModel(
      userId: userId,
      productId: productId,
      type: type,
      duration: duration ?? 0,
      createdAt: DateTime.now(),
    );

    await _interactionService.logInteraction(interaction);
  }
}