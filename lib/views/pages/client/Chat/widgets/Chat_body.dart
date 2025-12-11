import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/services/chat.service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final List<dynamic>? products;
  bool shouldAnimate; 

  ChatMessage({
    required this.text,
    required this.isUser,
    this.products,
    this.shouldAnimate = false, // Default false
  });
}

class ChatBody extends StatefulWidget {
  const ChatBody({super.key});

  @override
  State<ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends State<ChatBody> {
  final TextEditingController _controller = TextEditingController();
  final ChatService _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hello! I am RecoMart AI Assistant. What product are you looking for? (e.g., 'Gaming Laptop', 'Sony Headphones', 'Cheap Mouse')",
      isUser: false,
      shouldAnimate: true, // Animate the welcome message
    ),
  ];

  bool _isTyping = false;

  void _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, shouldAnimate: false));
      _isTyping = true;
      _controller.clear();
    });
    _scrollToBottom();

    final response = await _chatService.sendMessageToAI(text);

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          text: response['reply'] ?? "I didn't understand that.",
          isUser: false,
          products: response['products'],
          shouldAnimate: true, 
        ));
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // MESSAGE LIST
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length + (_isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _messages.length) {
                return const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "AI is searching...",
                      style: TextStyle(
                          fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                  ),
                );
              }

              final msg = _messages[index];
              return _buildMessageBubble(msg);
            },
          ),
        ),

        // INPUT FIELD
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black12, blurRadius: 5, offset: Offset(0, -2))
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Ask AI about products...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                backgroundColor: AppColors.primary,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 20),
                  onPressed: _handleSend,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // CHAT BUBBLE WIDGET
  Widget _buildMessageBubble(ChatMessage msg) {
    final isMe = msg.isUser;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Text content
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
                  bottomRight: isMe ? Radius.zero : const Radius.circular(12),
                ),
              ),
              child: isMe || !msg.shouldAnimate
                  ? Text(
                      msg.text,
                      style: TextStyle(
                          color: isMe ? Colors.white : Colors.black87),
                    )
                  : TypewriterText(
                      text: msg.text,
                      style: TextStyle(
                          color: isMe ? Colors.white : Colors.black87),
                      onFinished: () {
                        // Once finished, set flag to false to prevent re-animation on scroll
                        msg.shouldAnimate = false;
                      },
                    ),
            ),

            // Suggested Products
            if (!isMe && msg.products != null && msg.products!.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: msg.products!.length,
                  itemBuilder: (context, pIndex) {
                    final product = msg.products![pIndex];
                    return GestureDetector(
                      onTap: () {
                        context.push('/product-detail/${product['id']}');
                      },
                      child: Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(10)),
                                ),
                                child: const Center(
                                    child: Icon(Icons.image,
                                        color: Colors.grey)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'] ?? 'Unknown',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "ID: ${product['id']}",
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.primary),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class TypewriterText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final VoidCallback? onFinished;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.onFinished,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: text.length),
      duration: Duration(milliseconds: text.length * 30),
      builder: (context, value, child) {
        return Text(
          text.substring(0, value),
          style: style,
        );
      },
      onEnd: onFinished,
    );
  }
}