import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recomart/config/color.dart';
import '../../../../../services/chatadmin.service.dart';

class ChatList extends StatelessWidget {
  final Function(Map<String, dynamic>) onUserSelected;
  final String? selectedUserId;
  final _chatService = ChatAdminService();

  ChatList({
    super.key,
    required this.onUserSelected,
    this.selectedUserId,
  });

  Future<Map<String, dynamic>?> _getUserData(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (snapshot.exists) {
        final data = snapshot.data()!;
        return {
          'name': data['name'] ?? 'User',
          'avatar': data['avatar'] ?? '',
        };
      }
    } catch (e) {
      debugPrint("Load user info error: $e");
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
          return const Center(child: Text("No conversations yet."));
        }

        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index].data();
            final participants = List<String>.from(chat['participants'] ?? []);
            final userId = participants.firstWhere(
              (id) => id != ChatAdminService.adminId,
              orElse: () => 'unknown',
            );

            final isSelected = selectedUserId == userId;
            final unreadCount = chat['unreadCount'] ?? 0;

            return FutureBuilder<Map<String, dynamic>?>(
              future: _getUserData(userId),
              builder: (context, userSnap) {
                final userData = userSnap.data;
                final userName = userData?['name'] ?? userId;
                final userAvatar = userData?['avatar'] ?? '';
                final lastMessage = chat['lastMessage'] ?? '';

                return ListTile(
                  tileColor: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.white,
                  leading: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                        ),
                        child: ClipOval(
                          child: Image.network(
                            userAvatar,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                              const Icon(Icons.person, color: Colors.grey),
                          ),
                        ),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                            child: Text(
                              unreadCount > 9 ? '9+' : '$unreadCount',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    userName,
                    style: TextStyle(
                      fontWeight: unreadCount > 0 || isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.primary : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: unreadCount > 0 ? Colors.black87 : Colors.grey,
                      fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
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