import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;

  static const String adminId = "admin_recomart"; // người nhận mặc định
  FirebaseAuth get auth => _auth;

  /// 🔹 Gửi tin nhắn văn bản
  Future<void> sendMessage(String text) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final chatId = _generateChatId(user.uid, adminId);
    final messageRef = _firestore.collection('chats').doc(chatId).collection('messages').doc();

    await messageRef.set({
      'senderId': user.uid,
      'receiverId': adminId,
      'text': text,
      'imageUrl': null,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    await _firestore.collection('chats').doc(chatId).set({
      'participants': [user.uid, adminId],
      'lastMessage': text,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// 🔹 Gửi tin nhắn có hình ảnh
  Future<void> sendImage(File imageFile) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // ✅ Upload ảnh lên Cloudinary (preset DACNTT bạn tạo)
      final cloudinary = CloudinaryPublic('dqiclelb9', 'dacntt', cache: false);

      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(imageFile.path, folder: "chat_images"),
      );

      final imageUrl = response.secureUrl;
      final chatId = _generateChatId(user.uid, adminId);

      // ✅ Gửi tin nhắn hình ảnh vào đúng collection của chat
      final messageRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc();

      await messageRef.set({
        'senderId': user.uid,
        'receiverId': adminId,
        'text': null,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      // ✅ Cập nhật tin nhắn cuối cùng trong danh sách chat
      await _firestore.collection('chats').doc(chatId).set({
        'participants': [user.uid, adminId],
        'lastMessage': '[Hình ảnh]',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print("✅ Ảnh đã gửi: $imageUrl");
    } catch (e) {
      print("❌ Lỗi upload ảnh Cloudinary: $e");
    }
  }


  /// 🔹 Stream tin nhắn realtime
  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    final chatId = _generateChatId(user.uid, adminId);
    return _firestore.collection('chats').doc(chatId).collection('messages').orderBy('createdAt', descending: false).snapshots();
  }

  String _generateChatId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode ? "${uid1}_$uid2" : "${uid2}_$uid1";
  }
}
