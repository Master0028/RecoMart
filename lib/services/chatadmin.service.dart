import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

import '../pattern/singleton.dart';

class ChatAdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String adminId =
      "eb5d3f84-53af-49eb-8f7e-45aec1c908de"; // id admin mặc định

  /// 🔹 Lấy userId hiện tại từ Session
  String? get _currentUserId => UserSession.instance.userId;

  /// 🔹 Gửi tin nhắn văn bản
  Future<void> sendMessage(String text, String receiverId) async {
    final senderId = _currentUserId;
    if (senderId == null) return;

    final chatId = _generateChatId(senderId, receiverId);
    final messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    await messageRef.set({
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'imageUrl': null,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    await _firestore.collection('chats').doc(chatId).set({
      'participants': [senderId, receiverId],
      'lastMessage': text,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// 🔹 Gửi tin nhắn có hình ảnh
  Future<void> sendImage(File imageFile, String receiverId) async {
    final senderId = _currentUserId;
    if (senderId == null) return;

    try {
      final cloudinary =
      CloudinaryPublic('dqiclelb9', 'dacntt', cache: false);

      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(imageFile.path, folder: "chat_images"),
      );

      final imageUrl = response.secureUrl;
      final chatId = _generateChatId(senderId, receiverId);

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': senderId,
        'receiverId': receiverId,
        'text': null,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      await _firestore.collection('chats').doc(chatId).set({
        'participants': [senderId, receiverId],
        'lastMessage': '[Hình ảnh]',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print("❌ Lỗi upload ảnh: $e");
    }
  }

  /// 🔹 Stream danh sách các cuộc chat (admin)
  Stream<QuerySnapshot<Map<String, dynamic>>> getChatList() {
    return _firestore
        .collection('chats')
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  /// 🔹 Stream tin nhắn giữa 2 người
  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(
      String otherUserId) {
    final senderId = _currentUserId;
    if (senderId == null) return const Stream.empty();

    final chatId = _generateChatId(senderId, otherUserId);

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  /// 🔹 Sinh chatId cố định cho 2 user
  String _generateChatId(String uid1, String uid2) {
    return uid1.compareTo(uid2) < 0 ? "${uid1}_$uid2" : "${uid2}_$uid1";
  }
}
