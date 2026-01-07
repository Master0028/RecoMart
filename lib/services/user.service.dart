import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.model.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _users = FirebaseFirestore.instance.collection('users');
  final String collection = 'users';

  Future<Map<String, dynamic>?> getUserInfo(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, uid);
      }
      return null;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  Future<List<UserModel>> fetchUsers() async {
    final snapshot = await _db.collection(collection).get();
    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> updateUser(UserModel user) async {
    await _db.collection(collection).doc(user.id).update(user.toMap());
  }

  Future<void> toggleUserStatus(String id, bool isActive) async {
    await _db.collection(collection).doc(id).update({'isActive': isActive});
  }

  Future<void> deleteUser(String id) async {
    await _db.collection(collection).doc(id).delete();
  }

  Future<double> getLoyaltyPoints(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return 0;
    final data = doc.data();
    return (data?['loyaltyPoints'] ?? 0).toDouble();
  }

  Future<void> updateLoyaltyPoints({
    required String userId,
    required int usedPoints,
    required int earnedPoints,
  }) async {
    final ref = _users.doc(userId);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) {
        throw Exception('User not found');
      }

      final currentPoints = snap.data()?['loyaltyPoints'] ?? 0;
      final newPoints = currentPoints - usedPoints + earnedPoints;

      if (newPoints < 0) {
        throw Exception('Insufficient loyalty points');
      }

      tx.update(ref, {
        'loyaltyPoints': newPoints,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
