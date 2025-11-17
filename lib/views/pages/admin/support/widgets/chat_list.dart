import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recomart/services/chat.service.dart';
import 'package:recomart/config/color.dart';

class ChatList extends StatelessWidget {
  final Function(Map<String, dynamic>) onUserSelected;
  final String? selectedUserId;
  final _chatService = ChatService();

  ChatList({
    super.key,
    required this.onUserSelected,
    this.selectedUserId,
  });

  /// 🔹 Lấy thông tin user từ Firestore theo userId
  Future<Map<String, dynamic>?> _getUserData(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (snapshot.exists) {
        final data = snapshot.data()!;
        return {
          'name': data['name'] ?? 'Người dùng',
          'avatar': data['avatar'] ?? 'https://placehold.co/60x60/cccccc/ffffff?text=U',
        };
      }
    } catch (e) {
      debugPrint("Lỗi load user info: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _chatService.getChatList(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final chats = snapshot.data!.docs;
        if (chats.isEmpty) {
          return const Center(child: Text("Không có cuộc trò chuyện nào."));
        }

        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index].data();
            final participants = List<String>.from(chat['participants'] ?? []);

            // ✅ Loại admin ra, chỉ lấy userId thật
            final userId = participants.firstWhere(
                  (id) => id != ChatService.adminId,
              orElse: () => 'unknown',
            );

            final isSelected = selectedUserId == userId;

            // ✅ Dùng FutureBuilder để lấy thông tin user
            return FutureBuilder<Map<String, dynamic>?>(
              future: _getUserData(userId),
              builder: (context, userSnap) {
                final userData = userSnap.data;
                final userName = userData?['name'] ?? userId;
                final userAvatar = userData?['avatar'] ??
                    'https://placehold.co/60x60/cccccc/ffffff?text=U';
                final lastMessage = chat['lastMessage'] ?? '';

                return ListTile(
                  tileColor:
                  isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(userAvatar),
                    backgroundColor: Colors.grey.shade300,
                  ),
                  title: Text(
                    userName,
                    style: TextStyle(
                      fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () => onUserSelected({
                    'id': userId,
                    'name': userName,
                    'avatar': userAvatar,
                  }),
                );
              },
            );
          },
        );
      },
    );
  }
}
