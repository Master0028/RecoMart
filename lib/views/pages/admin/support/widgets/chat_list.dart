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

  Future<Map<String, dynamic>?> _getUserData(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (snapshot.exists) {
        final data = snapshot.data()!;
        return {
          'name': data['name'] ?? 'User',
          'avatar': data['avatar'] ?? 'https://placehold.co/60x60/cccccc/ffffff?text=U',
        };
      }
    } catch (e) {
      debugPrint("Error loading user info: $e");
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
          return const Center(child: Text("No conversations found."));
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListView.separated(
            itemCount: chats.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF0F0F0)),
            itemBuilder: (context, index) {
              final chat = chats[index].data();
              final participants = List<String>.from(chat['participants'] ?? []);

              final userId = participants.firstWhere(
                (id) => id != ChatService.adminId,
                orElse: () => 'unknown',
              );

              final isSelected = selectedUserId == userId;

              return FutureBuilder<Map<String, dynamic>?>(
                future: _getUserData(userId),
                builder: (context, userSnap) {
                  if (!userSnap.hasData && !userSnap.hasError) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                    );
                  }
                  
                  final userData = userSnap.data;
                  final userName = userData?['name'] ?? userId;
                  final userAvatar = userData?['avatar'] ??
                      'https://placehold.co/60x60/cccccc/ffffff?text=U';
                  final lastMessage = chat['lastMessage'] ?? 'No message history.';

                  // --- MODERNIZED LIST ITEM ---
                  return InkWell(
                    onTap: () => onUserSelected({
                      'id': userId,
                      'name': userName,
                      'avatar': userAvatar,
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(userAvatar),
                            backgroundColor: Colors.grey.shade300,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: Colors.black87,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  lastMessage,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: isSelected ? Colors.black54 : Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: isSelected ? AppColors.primary : Colors.grey.shade400, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}