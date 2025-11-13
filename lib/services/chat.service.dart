import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  static const String adminId = "pvIwRP6zV8cSfcH7rqGe6bbfzNz1"; // id mặc định của admin
  FirebaseAuth get auth => _auth;

  /// 🔹 Gửi tin nhắn văn bản
  Future<void> sendMessage(String text, String receiverId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final chatId = _generateChatId(user.uid, receiverId);
    final messageRef = _firestore.collection('chats').doc(chatId).collection('messages').doc();

    await messageRef.set({
      'senderId': user.uid,
      'receiverId': receiverId,
      'text': text,
      'imageUrl': null,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    await _firestore.collection('chats').doc(chatId).set({
      'participants': [user.uid, receiverId],
      'lastMessage': text,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// 🔹 Gửi tin nhắn có hình ảnh
  Future<void> sendImage(File imageFile, String receiverId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final cloudinary = CloudinaryPublic('dqiclelb9', 'dacntt', cache: false);
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(imageFile.path, folder: "chat_images"),
      );

      final imageUrl = response.secureUrl;
      final chatId = _generateChatId(user.uid, receiverId);

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': user.uid,
        'receiverId': receiverId,
        'text': null,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      await _firestore.collection('chats').doc(chatId).set({
        'participants': [user.uid, receiverId],
        'lastMessage': '[Hình ảnh]',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print("❌ Lỗi upload ảnh: $e");
    }
  }

  /// 🔹 Stream danh sách các cuộc chat (dành cho admin)
  Stream<QuerySnapshot<Map<String, dynamic>>> getChatList() {
    return _firestore
        .collection('chats')
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  /// 🔹 Stream tin nhắn giữa 2 người (realtime)
  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(String otherUserId) {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    final chatId = _generateChatId(user.uid, otherUserId);

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  /// 🔹 Sinh id chat thống nhất
  String _generateChatId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode ? "${uid1}_$uid2" : "${uid2}_$uid1";
  }
}
