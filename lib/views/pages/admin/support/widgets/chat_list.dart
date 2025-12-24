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
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isCompact = constraints.maxWidth < 90;

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _chatService.getChatList(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final chats = snapshot.data!.docs;
            if (chats.isEmpty) {
              return Center(
                child: isCompact 
                  ? const Icon(Icons.chat_bubble_outline, color: Colors.grey)
                  : const Text("No conversations found.", style: TextStyle(color: Colors.grey)),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              itemCount: chats.length,
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
                    String userName = 'Loading...';
                    String userAvatar = 'https://placehold.co/60x60/cccccc/ffffff?text=...';
                    
                    if (userSnap.hasData) {
                      userName = userSnap.data!['name'];
                      userAvatar = userSnap.data!['avatar'];
                    }

                    final lastMessage = chat['lastMessage'] ?? '';
                    final bool hasUnread = false;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: InkWell(
                        onTap: () => onUserSelected({
                          'id': userId,
                          'name': userName,
                          'avatar': userAvatar,
                        }),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.all(isCompact ? 8 : 12),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppColors.primary.withOpacity(0.1) 
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected 
                                ? Border.all(color: AppColors.primary.withOpacity(0.3)) 
                                : Border.all(color: Colors.transparent),
                          ),
                          child: isCompact 
                            ? _buildCompactItem(userAvatar, isSelected)
                            : _buildFullItem(userAvatar, userName, lastMessage, isSelected),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCompactItem(String avatarUrl, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent, 
              width: 2
            ),
          ),
          child: CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(avatarUrl),
            backgroundColor: Colors.grey.shade200,
          ),
        ),
      ],
    );
  }

  Widget _buildFullItem(String avatarUrl, String name, String message, bool isSelected) {
    return Row(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(avatarUrl),
              backgroundColor: Colors.grey.shade200,
            ),
          ],
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: const Color(0xFF2B2B2B),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message.isNotEmpty ? message : 'No messages yet',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : Colors.grey.shade600,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        if (isSelected)
          const Icon(Icons.chevron_right, size: 18, color: AppColors.primary),
      ],
    );
  }
}