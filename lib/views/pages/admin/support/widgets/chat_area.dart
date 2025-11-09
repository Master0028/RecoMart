import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:feather_icons/feather_icons.dart'; // Thêm FeatherIcons

class AppColors {
  static const Color primary = Color(0xFF007AFF);
  static const Color lime = Colors.greenAccent;
}
class Responsive {
  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 800;
}

final List<Map<String, dynamic>> FE_CUSTOMERS_STUB = [
  {
    'id': 'c1',
    'name': 'Client Ẩn Danh',
    'avatar': 'https://i.pravatar.cc/150?img=1', 
    'isOnline': true,
    'lastMessage': 'Anh/chị còn sản phẩm này không ạ?',
    'lastMessageTime': '10:45', 
    'unreadCount': 2,
    'messages': [ 
      {'sender': 'customer', 'text': 'Chào shop.', 'timestamp': DateTime.now().subtract(const Duration(minutes: 10))},
      {'sender': 'support', 'text': 'Chào bạn, RecoMart có thể giúp gì cho bạn?', 'timestamp': DateTime.now().subtract(const Duration(minutes: 9))},
      {'sender': 'customer', 'text': 'Anh/chị còn sản phẩm này không ạ?', 'timestamp': DateTime.now().subtract(const Duration(minutes: 5))},
    ]
  },
  {
    'id': 'c2',
    'name': 'Hỗ trợ Kỹ thuật',
    'avatar': 'https://i.pravatar.cc/150?img=2',
    'isOnline': false,
    'lastMessage': 'Đang chờ phản hồi từ bộ phận kỹ thuật.',
    'lastMessageTime': 'Hôm qua',
    'unreadCount': 0,
    'messages': [ 
      {'sender': 'customer', 'text': 'Đơn hàng 123 bị lỗi kỹ thuật.', 'timestamp': DateTime.now().subtract(const Duration(days: 1))},
      {'sender': 'support', 'text': 'Đang chờ phản hồi từ bộ phận kỹ thuật.', 'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 1))},
    ]
  },
  {
    'id': 'c3',
    'name': 'Nguyễn Văn A',
    'avatar': 'https://i.pravatar.cc/150?img=3',
    'isOnline': true,
    'lastMessage': 'Tôi muốn hủy đơn hàng vừa đặt.',
    'lastMessageTime': 'Thứ 6',
    'unreadCount': 1,
    'messages': [ 
      {'sender': 'customer', 'text': 'Tôi muốn hủy đơn hàng vừa đặt.', 'timestamp': DateTime.now().subtract(const Duration(days: 2))},
    ]
  },
];

const Color PRIMARY_COLOR = Color(0xFF007AFF);

class ChatArea extends StatefulWidget {
  final Map<String, dynamic> customer; 
  final VoidCallback? onBack;

  const ChatArea({super.key, required this.customer, this.onBack});

  @override
  State<ChatArea> createState() => _ChatAreaState();
}

class _ChatAreaState extends State<ChatArea> {
  final ScrollController _scrollController = ScrollController();
  late List<Map<String, dynamic>> messages;
  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    messages = List.from(widget.customer['messages'] ?? []); 
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add({
        'sender': 'support',
        'text': text.trim(),
        'timestamp': DateTime.now(),
      });
      widget.customer['lastMessage'] = text.trim(); 
      
      widget.customer['lastMessageTime'] = DateFormat('HH:mm').format(DateTime.now());
    });

    _inputController.clear();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
  void dispose() {
    _scrollController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  Widget _buildModernHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          isMobile ? 10 : 20, 10, isMobile ? 10 : 20, 10),
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: isMobile
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
        borderRadius: isMobile ? null : BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: widget.onBack,
            ),
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(widget.customer['avatar'] ?? 'https://placehold.co/40'),
            backgroundColor: Colors.white,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.customer['name'] ?? 'Unknown User',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              if (widget.customer['isOnline'] == true)
                const Text(
                  "Online",
                  style: TextStyle(
                      fontSize: 13, color: AppColors.lime, fontWeight: FontWeight.w500),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Column(
      children: [
        if (isMobile)
          _buildModernHeader(true)
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: _buildModernHeader(false),
          ),
        
        const Divider(height: 1, thickness: 0.5, color: Colors.grey),

        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final messageDate = message['timestamp'] as DateTime;
              final isToday = messageDate.day == DateTime.now().day &&
                  messageDate.month == DateTime.now().month &&
                  messageDate.year == DateTime.now().year;

              bool showDateHeader = index == 0 ||
                  (messages[index - 1]['timestamp'] as DateTime).day != messageDate.day;

              return ChatMessage(
                message: message,
                isSupport: message['sender'] == 'support', 
                customerAvatar: widget.customer['avatar'],
                showDateHeader: showDateHeader,
                isToday: isToday,
              );
            },
          ),
        ),
        ChatInput(
          controller: _inputController, 
          onSend: _sendMessage,
        ),
      ],
    );
  }
}

class ChatMessage extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isSupport;
  final String customerAvatar;
  final bool showDateHeader;
  final bool isToday;

  const ChatMessage({
    super.key,
    required this.message,
    required this.isSupport,
    required this.customerAvatar,
    required this.showDateHeader,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isSupport ? AppColors.primary : const Color(0xFFE9E9EB);
    final textColor = isSupport ? Colors.white : Colors.black87;
    final timeColor = isSupport ? Colors.white70 : Colors.black54;
    final alignment = isSupport ? MainAxisAlignment.end : MainAxisAlignment.start;

    return Column(
      children: [
        if (showDateHeader)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isToday ? "HÔM NAY" : DateFormat('dd MMM yyyy').format(message['timestamp']),
                style: const TextStyle(
                    color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        Row(
          mainAxisAlignment: alignment,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isSupport)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  radius: 15,
                  backgroundImage: NetworkImage(customerAvatar ?? 'https://placehold.co/30'),
                ),
              ),
              
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isSupport ? 20 : 5),
                  bottomRight: Radius.circular(isSupport ? 5 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isSupport ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message['text'],
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(message['timestamp']),
                        style: TextStyle(
                          color: timeColor,
                          fontSize: 11,
                        ),
                      ),
                      if (isSupport)
                        const Padding(
                          padding: EdgeInsets.only(left: 4.0),
                          child: Icon(
                            Icons.done_all,
                            size: 14,
                            color: Colors.white70,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ChatInput extends StatelessWidget {
  final void Function(String) onSend;
  final TextEditingController controller;

  const ChatInput({super.key, required this.onSend, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, -5)
          )
        ]
      ),
      child: SafeArea( 
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 28),
              onPressed: () {
                print('Attachment button clicked');
              },
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                child: TextField(
                  controller: controller,
                  maxLines: 5, 
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.send,
                  decoration: const InputDecoration(
                    hintText: "Nhập tin nhắn...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (value) {
                    onSend(value);
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(
                Icons.send_rounded,
                color: AppColors.primary,
                size: 28,
              ),
              onPressed: () {
                onSend(controller.text);
              },
            ),
          ],
        ),
      ),
    );
  }
}