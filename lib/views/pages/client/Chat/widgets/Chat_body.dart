import 'dart:io';

import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:image_picker/image_picker.dart';

import 'package:recomart/config/color.dart'; 
import 'package:recomart/utils/responsive.dart';

import '../../../../../services/chat.service.dart';

class ChatBody extends StatefulWidget {
  const ChatBody({super.key});

  @override
  State<ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends State<ChatBody> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _chatService = ChatService();

  final List<Map<String, dynamic>> users = []; 

  List<Map<String, dynamic>> messages = []; 

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    await _chatService.sendMessage(text);
    _messageController.clear();
    _scrollToBottom();
  }



  Widget _buildChatListItem(Map<String, dynamic> user) {
    bool isUnread = user['unread'] ?? false;
    
    final name = user['name'] ?? 'No Chat Selected';
    final message = user['message'] ?? 'Start a new conversation.';
    final time = user['time'] ?? 'Now';
    final avatarUrl = user['avatar'] ?? 'https://placehold.co/400x400/CCCCCC/000000?text=NC';
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: isUnread ? AppColors.primary.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(avatarUrl), 
          backgroundColor: isUnread ? AppColors.primary : Colors.grey.shade300,
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          message,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isUnread ? AppColors.primary : Colors.grey,
            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(time,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            if (isUnread)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primary, 
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('!',
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
        onTap: () {
          print('Chat selected: $name');
        },
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    bool isMe = msg['isMe'] ?? false;
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
      bottomRight: isMe ? Radius.zero : const Radius.circular(20),
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.grey.shade200,
          borderRadius: borderRadius,
          boxShadow: isMe
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Text(
          msg['text'] ?? 'Empty Message',
          style: TextStyle(
              color: isMe ? Colors.white : Colors.black87, fontSize: 15),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = Responsive.isMobile(context);
        
        final String selectedChatName = 'Shane Martinez';
        final String selectedChatAvatar = 'https://placehold.co/400x400/003d80/ffffff?text=FE';
        
        final List<Map<String, dynamic>> displayUsers = users.isEmpty ? 
          [{'name': selectedChatName, 'avatar': selectedChatAvatar, 'unread': false}] : users;


        return Container(
          color: Colors.white,
          child: Row(
            children: [
              if (!isMobile)
                Flexible(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        right: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Chats',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: displayUsers.length, 
                            itemBuilder: (context, index) {
                              return _buildChatListItem(displayUsers[index]);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Chat Conversation Pane (Main)
              Flexible(
                flex: 5,
                child: Column(
                  children: [
                    if (!isMobile)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(selectedChatAvatar),
                              backgroundColor: AppColors.primary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              selectedChatName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('Today',
                          style: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.w500)),
                    ),
                    Expanded(
                      child: StreamBuilder(
                        stream: _chatService.getMessages(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final docs = snapshot.data!.docs;
                          if (docs.isEmpty) {
                            return const Center(child: Text("Chưa có tin nhắn nào."));
                          }

                          return ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final msg = docs[index].data();
                              final bool isMe =
                                  msg['senderId'] == ChatService().auth.currentUser?.uid;
                              return Align(
                                alignment:
                                isMe ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                                  ),
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isMe ? AppColors.primary : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: msg['imageUrl'] != null
                                      ? Image.network(msg['imageUrl'], width: 200)
                                      : Text(
                                    msg['text'] ?? '',
                                    style: TextStyle(
                                      color:
                                      isMe ? Colors.white : Colors.black87,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final picked = await picker.pickImage(source: ImageSource.gallery);
                              if (picked != null) {
                                await _chatService.sendImage(File(picked.path));
                              }
                            },
                            icon: Icon(FeatherIcons.paperclip, color: AppColors.primary),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              onSubmitted: (_) => _sendMessage(), 
                              decoration: InputDecoration(
                                hintText: 'Message...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25), 
                                  borderSide: BorderSide.none,
                                ),
                                fillColor: const Color(0xFFF0F2F5), 
                                filled: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _sendMessage,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.5),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: const Icon(
                                FeatherIcons.send,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}