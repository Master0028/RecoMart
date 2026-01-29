import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'recommendation_service.dart';

class ChatService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  static const String adminId = "pvIwRP6zV8cSfcH7rqGe6bbfzNz1";

  Future<Map<String, dynamic>> sendMessageToAI(String query) async {
    String baseUrl = RecommendationService.baseUrl;
    final Uri url = Uri.parse('$baseUrl/api/chat');
    final user = _auth.currentUser;

    try {
      final response = await http.post(
        url,
        headers: {
          "ngrok-skip-browser-warning": "true",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "query": query,
          "user_id": user?.uid ?? "guest",
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        return {
          "response": "AI is busy (Error ${response.statusCode}).",
          "data": [],
          "type": "text"
        };
      }
    } catch (e) {
      return {
        "response": "Connection error: $e",
        "data": [],
        "type": "text"
      };
    }
  }

  FirebaseAuth get auth => _auth;

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
        'lastMessage': '[Image]',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception("Upload failed: $e");
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getChatList() {
    return _firestore
        .collection('chats')
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

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

  String _generateChatId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode ? "${uid1}_$uid2" : "${uid2}_$uid1";
  }
}