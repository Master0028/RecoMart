import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class AdminChatPageScreen extends StatefulWidget {
  const AdminChatPageScreen({super.key});

  @override
  State<AdminChatPageScreen> createState() => _AdminChatPageScreenState();
}

class _AdminChatPageScreenState extends State<AdminChatPageScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final List<Map<String, dynamic>> _messages = [
    {
      "type": "text", 
      "content": "Hello! I am your AI Assistant. How can I help you?", 
      "isMe": false, 
      "isAnimated": true
    },
  ];

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Gửi tin nhắn văn bản
  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _messages.add({"type": "text", "content": _controller.text, "isMe": true});
    });
    
    _controller.clear();
    _scrollToBottom();
    _mockAdminResponse();
  }

  // Giả lập gửi tin nhắn ảnh
  void _sendImage() {
    setState(() {
      _messages.add({
        "type": "image", 
        "content": "https://picsum.photos/400/300", // URL ảnh mẫu
        "isMe": true
      });
    });
    _scrollToBottom();
    _mockAdminResponse();
  }

  void _mockAdminResponse() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add({
          "type": "text", 
          "content": "I received your message. Let me check that for you!", 
          "isMe": false,
          "isAnimated": true
        });
      });
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                itemCount: _messages.length,
                itemBuilder: (context, index) => _buildChatBubble(_messages[index]),
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> msg) {
    bool isMe = msg['isMe'];
    bool isAnimated = msg['isAnimated'] ?? false;
    bool isImage = msg['type'] == 'image';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        // Nếu là ảnh thì không cần padding lớn
        padding: isImage ? const EdgeInsets.all(5) : const EdgeInsets.all(15),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF4ECCA3) : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 20),
          ),
        ),
        child: isImage 
          ? ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                msg['content'],
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: Color(0xFF4ECCA3)),
                  );
                },
              ),
            )
          : (isAnimated && !isMe)
            ? DefaultTextStyle(
                style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
                child: AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(msg['content'], speed: const Duration(milliseconds: 50)),
                  ],
                  totalRepeatCount: 1,
                  displayFullTextOnTap: true,
                ),
              )
            : Text(
                msg['content'],
                style: GoogleFonts.inter(color: isMe ? Colors.black87 : Colors.white, fontSize: 15),
              ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 30),
      child: Row(
        children: [
          // Nút gửi ảnh
          _buildActionButton(Icons.image_outlined, _sendImage, isPrimary: false),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                textInputAction: TextInputAction.send,
                onSubmitted: (value) => _sendMessage(),
                decoration: const InputDecoration(
                  hintText: "Type a message...",
                  hintStyle: TextStyle(color: Colors.white30),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _buildActionButton(Icons.send, _sendMessage, isPrimary: true),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap, {bool isPrimary = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF4ECCA3) : Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon, 
          color: isPrimary ? Colors.black87 : Colors.white70, 
          size: 22
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
      color: Colors.white.withOpacity(0.02),
      child: Row(
        children: [
          const CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11')),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Admin Support", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
              const Text("Active Now", style: TextStyle(color: Color(0xFF4ECCA3), fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}