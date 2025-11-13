import 'dart:io';
import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/services/chat.service.dart';

class ChatArea extends StatefulWidget {
  final String userId;
  final String userName;

  const ChatArea({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<ChatArea> createState() => _ChatConversationPanelState();
}

class _ChatConversationPanelState extends State<ChatArea> {
  final _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await _chatService.sendMessage(text, widget.userId);
    _controller.clear();
    _scrollToBottom();
  }

  Future<void> _sendImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      await _chatService.sendImage(File(picked.path), widget.userId);
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _chatService.auth.currentUser;

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: Colors.white,
          child: Row(
            children: [
              const CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://placehold.co/60x60/003d80/ffffff?text=U'),
              ),
              const SizedBox(width: 12),
              Text(
                widget.userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Danh sách tin nhắn realtime
        Expanded(
          child: StreamBuilder(
            stream: _chatService.getMessages(widget.userId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final messages = snapshot.data!.docs;

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index].data();
                  final bool isMe = msg['senderId'] == user?.uid;

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isMe ? AppColors.primary : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: msg['imageUrl'] != null
                          ? Image.network(msg['imageUrl'], width: 180)
                          : Text(
                        msg['text'] ?? '',
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Ô nhập tin nhắn
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              IconButton(
                onPressed: _sendImage,
                icon: Icon(FeatherIcons.paperclip, color: AppColors.primary),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: 'Nhập tin nhắn...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(FeatherIcons.send,
                      color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
