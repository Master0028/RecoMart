class ChatMessage {
  final String text;
  final bool isUser;
  final List<dynamic>? products;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.products,
  });
}