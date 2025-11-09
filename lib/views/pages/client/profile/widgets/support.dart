import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/utils/widget/CustomAppBarMobile.dart';

class _Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  _Message(this.text, this.isUser, this.timestamp);
}

final List<_Message> _mockMessages = [
  _Message(
    "Xin chào! Tôi có thể giúp gì cho bạn hôm nay?",
    false,
    DateTime.now().subtract(const Duration(minutes: 5)),
  ),
  _Message(
    "Tôi đang gặp sự cố với đơn hàng 12345 của mình.",
    true,
    DateTime.now().subtract(const Duration(minutes: 3)),
  ),
  _Message(
    "Tôi hiểu rồi. Bạn vui lòng mô tả chi tiết sự cố bạn đang gặp phải được không?",
    false,
    DateTime.now().subtract(const Duration(minutes: 2)),
  ),
];

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_Message> _messages = List.from(_mockMessages);

  void _handleSendPressed() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_Message(text, true, DateTime.now()));
    });
    _messageController.clear();
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _messages.add(_Message(
          "Xin chào bạn cần hỗ trợ gì đi",
          false,
          DateTime.now(),
        ));
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: const CustomAppBarMobile(
        title: 'Trung tâm Hỗ trợ',
        isBack: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          _buildMessageInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Nhập tin nhắn của bạn...',
                  fillColor: Colors.grey.shade100,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                ),
                // SỬA: onSubmitted xử lý phím Enter
                onSubmitted: (_) => _handleSendPressed(),
              ),
            ),
            const SizedBox(width: 12),
            FloatingActionButton(
              onPressed: _handleSendPressed,
              backgroundColor: AppColors.primary,
              elevation: 2,
              mini: true,
              child: const Icon(FeatherIcons.send, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(_Message message) {
    final bool isUser = message.isUser;
    
    final MainAxisAlignment alignment =
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start;
        
    final Color bubbleColor = isUser ? AppColors.primary : Colors.white;
    final Color textColor = isUser ? Colors.white : Colors.black87;
    
    final BorderRadius borderRadius = isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
            topRight: Radius.circular(5), 
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(5), 
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
            topRight: Radius.circular(20),
          );

    return Row(
      mainAxisAlignment: alignment,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75 
          ),
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: borderRadius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.text,
                style: TextStyle(color: textColor, fontSize: 15, height: 1.4),
              ),
              const SizedBox(height: 5),
              Text(
                '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: isUser ? Colors.white70 : Colors.grey,
                  fontSize: 12
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}