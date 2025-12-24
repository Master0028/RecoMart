import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/utils/widget/CustomAppBarMobile.dart';

class _Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  bool shouldAnimate;

  _Message(this.text, this.isUser, this.timestamp, {this.shouldAnimate = false});
}

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final List<_Message> _messages = [
    _Message("Hello! How can I help you today?", false, DateTime.now().subtract(const Duration(minutes: 5))),
    _Message("I am having trouble with my order #12345.", true, DateTime.now().subtract(const Duration(minutes: 3))),
    _Message("I understand. Could you please describe the issue in detail?", false, DateTime.now().subtract(const Duration(minutes: 2))),
  ];

  void _handleSendPressed() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_Message(text, true, DateTime.now(), shouldAnimate: false));
    });
    _messageController.clear();
    _scrollToBottom();

    // Mock bot response
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _messages.add(_Message(
          "Hello, how can I assist you further?",
          false,
          DateTime.now(),
          shouldAnimate: true,
        ));
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    // Check if the scroll controller is attached to a view before using it
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
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
        title: 'Support Center',
        isBack: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessageBubble(_messages[index]),
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
                  hintText: 'Type your message...',
                  fillColor: Colors.grey.shade100,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                ),
                onSubmitted: (_) => _handleSendPressed(),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 40,
              width: 40,
              child: FloatingActionButton(
                onPressed: _handleSendPressed,
                backgroundColor: AppColors.primary,
                elevation: 0,
                child: const Icon(FeatherIcons.send, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(_Message message) {
    final bool isUser = message.isUser;
    final alignment = isUser ? MainAxisAlignment.end : MainAxisAlignment.start;
    final bubbleColor = isUser ? AppColors.primary : Colors.white;
    final textColor = isUser ? Colors.white : Colors.black87;

    return Row(
      mainAxisAlignment: alignment,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser && message.shouldAnimate)
                TypewriterText(
                  text: message.text,
                  style: TextStyle(color: textColor, fontSize: 15),
                  onFinished: () => message.shouldAnimate = false,
                )
              else
                Text(
                  message.text,
                  style: TextStyle(color: textColor, fontSize: 15),
                ),
              const SizedBox(height: 4),
              Text(
                '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                style: TextStyle(color: isUser ? Colors.white70 : Colors.grey, fontSize: 10),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class TypewriterText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final VoidCallback? onFinished;

  const TypewriterText({super.key, required this.text, required this.style, this.onFinished});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: text.length),
      duration: Duration(milliseconds: text.length * 30),
      onEnd: onFinished,
      builder: (context, value, child) {
        return Text(text.substring(0, value), style: style);
      },
    );
  }
}