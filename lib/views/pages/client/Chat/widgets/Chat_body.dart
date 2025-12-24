import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/services/api_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final String type; // 'text', 'product_list', 'order_list'
  final List<dynamic>? data;
  bool shouldAnimate;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.type = 'text',
    this.data,
    this.shouldAnimate = false,
  });
}

class ChatBody extends StatefulWidget {
  const ChatBody({super.key});

  @override
  State<ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends State<ChatBody> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hello! I am RecoMart AI Assistant. How can I help you today?",
      isUser: false,
      shouldAnimate: true,
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

    try {
      final response = await ApiService.chatWithAI(text);
      
      if (mounted) {
        setState(() {
          _isTyping = false;
          final replyText = response['response'] ?? "I didn't understand that.";
          final type = response['type'] ?? 'text';
          final data = response['data'] ?? [];

          _messages.add(ChatMessage(
            text: replyText,
            isUser: false,
            type: type,
            data: data,
            shouldAnimate: true,
          ));
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(
            text: "Sorry, connection error. Please try again.",
            isUser: false,
            shouldAnimate: true,
          ));
        });
        _scrollToBottom();
      }
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
                      "AI is typing...",
                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                  ),
                );
              }
              return _buildMessageBubble(_messages[index]);
            },
          ),
        ),

        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, -2))
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Ask about products or orders...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

  Widget _buildMessageBubble(ChatMessage msg) {
    final isMe = msg.isUser;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Text Bubble
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
                  ? Text(msg.text, style: TextStyle(color: isMe ? Colors.white : Colors.black87))
                  : TypewriterText(
                      text: msg.text,
                      style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                      onFinished: () {
                        msg.shouldAnimate = false;
                      },
                    ),
            ),

            // --- PRODUCT LIST (Carousel) ---
            if (!isMe && msg.type == 'product_list' && msg.data != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: msg.data!.length,
                  itemBuilder: (context, index) {
                    final product = msg.data![index];
                    final imgUrl = product['image'] ?? product['imageUrl'] ?? '';
                    
                    return GestureDetector(
                      onTap: () {
                        if (product['id'] != null) {
                          context.push('/product-detail/${product['id']}');
                        }
                      },
                      child: Container(
                        width: 140,
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
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                child: imgUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: imgUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorWidget: (_, __, ___) => const Icon(Icons.image, color: Colors.grey),
                                      )
                                    : const Center(child: Icon(Icons.image, color: Colors.grey)),
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
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${product['price']} VND",
                                    style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
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

            // --- ORDER LIST (Vertical Cards) ---
            if (!isMe && msg.type == 'order_list' && msg.data != null) ...[
              const SizedBox(height: 10),
              Column(
                children: msg.data!.map<Widget>((order) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.shade200),
                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Order #${order['id'].toString().substring(0, 5)}", 
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(order['status'], 
                                  style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 11)),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        Text("Items: ${(order['items'] as List).join(', ')}", 
                            style: const TextStyle(fontSize: 12, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Date: ${order['date']}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            Text("${order['total']} đ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                          ],
                        )
                      ],
                    ),
                  );
                }).toList(),
              )
            ]
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