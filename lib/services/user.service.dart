import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.model.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collection = 'users';

  /// 🔹 Lấy danh sách tất cả người dùng
  Future<List<UserModel>> fetchUsers() async {
    final snapshot = await _db.collection(collection).get();
    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// 🔹 Cập nhật thông tin người dùng
  Future<void> updateUser(UserModel user) async {
    await _db.collection(collection).doc(user.id).update(user.toMap());
  }

  /// 🔹 Cấm hoặc mở khóa người dùng
  Future<void> toggleUserStatus(String id, bool isActive) async {
    await _db.collection(collection).doc(id).update({'isActive': isActive});
  }

  /// 🔹 Xóa người dùng (tuỳ chọn)
  Future<void> deleteUser(String id) async {
    await _db.collection(collection).doc(id).delete();
  }
}
