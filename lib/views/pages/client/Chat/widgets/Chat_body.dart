import 'package:recomart/config/color.dart';
import 'package:recomart/utils/responsive.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart'; // Dùng icon hiện đại

class ChatBody extends StatefulWidget {
  const ChatBody({super.key});

  @override
  State<ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends State<ChatBody> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Mock data Users (giả lập danh sách chat)
  final List<Map<String, dynamic>> users = [
    {
      'name': 'Shane Martinez (Staff)',
      'message': 'We have received your request...',
      'time': '5 min',
      'avatar': 'https://placehold.co/400x400/003d80/ffffff?text=SM',
      'unread': true,
    },
    {
      'name': 'Technical Support',
      'message': 'Please try restarting your device.',
      'time': '15 min',
      'avatar': 'https://placehold.co/400x400/17A2B8/ffffff?text=TS',
      'unread': false,
    },
    {
      'name': 'Sales Team',
      'message': 'The new laptop model is available now.',
      'time': '1 hour',
      'avatar': 'https://placehold.co/400x400/28A745/ffffff?text=ST',
      'unread': false,
    },
  ];

  // Mock data Messages (giả lập nội dung chat)
  List<Map<String, dynamic>> messages = [
    {'text': 'Hello, I have a question about my recent order.', 'isMe': true},
    {'text': 'Welcome! How may I assist you today?', 'isMe': false},
    {'text': 'I need tracking information for order #90210.', 'isMe': true},
    {'text': 'Please hold while I check the details for you.', 'isMe': false},
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        // Thêm tin nhắn mới vào danh sách
        messages.add({'text': text, 'isMe': true});
        // Giả lập phản hồi từ đối phương sau 1 giây
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            messages.add({'text': 'Thank you for your message, our staff will reply shortly.', 'isMe': false});
          });
          _scrollToBottom();
        });
      });
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    // Đảm bảo tin nhắn mới nhất hiển thị ở cuối
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // --- Widgets con tùy chỉnh cho thiết kế hiện đại ---

  Widget _buildChatListItem(Map<String, dynamic> user) {
    bool isUnread = user['unread']! as bool;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: isUnread ? AppColors.primary.withOpacity(0.05) : Colors.white, // Nền xanh nhạt cho tin nhắn chưa đọc
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(user['avatar']! as String),
          backgroundColor: isUnread ? AppColors.primary : Colors.grey.shade300,
        ),
        title: Text(
          user['name']! as String,
          style: TextStyle(
            fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          user['message']! as String,
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
            Text(user['time']! as String,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            if (isUnread)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary, // Màu xanh dương nổi bật
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('1',
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
        onTap: () {
          // Xử lý khi chọn chat
        },
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    bool isMe = msg['isMe']! as bool;
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
          msg['text']! as String,
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
        return Container(
          color: Colors.white,
          child: Row(
            children: [
              // Chat List Pane (Desktop/Tablet)
              if (!isMobile)
                Flexible(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        right: BorderSide(
                          color: Colors.grey.shade200, // Viền nhẹ hơn
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
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              return _buildChatListItem(users[index]);
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
                    // Header Conversation (Desktop/Tablet)
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
                              backgroundImage: NetworkImage(users[0]['avatar']! as String),
                              backgroundColor: AppColors.primary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              users[0]['name']! as String,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    // Timeline Date (Modern)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('Today',
                          style: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.w500)),
                    ),
                    // Message List
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          return _buildMessageBubble(messages[index]);
                        },
                      ),
                    ),
                    // Input Bar (Modern, có thể nhập và gửi)
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
                          // Nút Attachment/File
                          IconButton(
                            onPressed: () {},
                            icon: Icon(FeatherIcons.paperclip, color: AppColors.primary),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              onSubmitted: (_) => _sendMessage(), // Nhấn Enter/Done để gửi
                              decoration: InputDecoration(
                                hintText: 'Message...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25), // Bo góc tròn hơn
                                  borderSide: BorderSide.none,
                                ),
                                fillColor: const Color(0xFFF0F2F5), // Màu nền nhẹ
                                filled: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Nút Gửi (Send Button)
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