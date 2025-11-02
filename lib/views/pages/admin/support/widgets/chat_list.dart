import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';

//Cấu trúc dữ liệu 
final List<Map<String, dynamic>> FE_CUSTOMERS_STUB = [
  {
    'id': 'c1',
    'name': 'Client Ẩn Danh',
    'avatar': 'https://placehold.co/40x40/007AFF/FFFFFF/png', 
    'isOnline': true,
    'lastMessage': 'Anh/chị còn sản phẩm này không ạ?',
    'lastMessageTime': '10:45', 
    'unreadCount': 2,
  },
  {
    'id': 'c2',
    'name': 'Hỗ trợ Kỹ thuật',
    'avatar': 'https://placehold.co/40x40/FF5722/FFFFFF/png',
    'isOnline': false,
    'lastMessage': 'Đang chờ phản hồi từ bộ phận kỹ thuật.',
    'lastMessageTime': 'Hôm qua',
    'unreadCount': 0,
  },
  {
    'id': 'c3',
    'name': 'Nguyễn Văn A',
    'avatar': 'https://placehold.co/40x40/00C853/FFFFFF/png',
    'isOnline': true,
    'lastMessage': 'Tôi muốn hủy đơn hàng vừa đặt.',
    'lastMessageTime': 'Thứ 6',
    'unreadCount': 1,
  },
];
const Color PRIMARY_COLOR = Color(0xFF007AFF);
const Color ACCENT_COLOR = Color(0xFFFF9500);


class ChatList extends StatelessWidget {
  final List<dynamic> customers; 
  final void Function(Map<String, dynamic>) onSelectCustomer;

  const ChatList({
    super.key,
    required this.customers,
    required this.onSelectCustomer,
  });

  @override
  Widget build(BuildContext context) {
    final List<dynamic> chatCustomers = FE_CUSTOMERS_STUB;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header
          const Padding(
            padding: EdgeInsets.only(top: 24, bottom: 8, left: 24, right: 24),
            child: Text(
              "Messages",
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.w900, 
                color: Color(0xFF1E1E1E)
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Tìm kiếm cuộc hội thoại...",
                prefixIcon: const Icon(FeatherIcons.search, color: PRIMARY_COLOR, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text(
                  "Sắp xếp theo:",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4A4A4A)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: "Newest",
                      icon: const Icon(FeatherIcons.chevronDown, color: PRIMARY_COLOR),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF1E1E1E),
                        fontWeight: FontWeight.w500,
                      ),
                      items: ["Newest", "Oldest", "Unread"].map((value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        print('Sort by: $value');
                      },
                      dropdownColor: Colors.white,
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Danh sách Chats
          Expanded(
            child: ListView.separated(
              itemCount: chatCustomers.length,
              itemBuilder: (context, index) {
                final customer = chatCustomers[index];
                return ChatListItem(
                  customer: customer,
                  onTap: () => onSelectCustomer(customer.cast<String, dynamic>()), 
                  showTyping: index == 0,
                  unreadCount: customer['unreadCount'] ?? 0,
                  isSelected: index == 0,
                );
              },
              separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                  height: 0,
                  thickness: 0.5,
                  color: Colors.grey.shade200,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatListItem extends StatelessWidget {
  final Map<String, dynamic> customer;
  final VoidCallback onTap;
  final bool showTyping;
  final int unreadCount;
  final bool isSelected;

  const ChatListItem({
    super.key,
    required this.customer,
    required this.onTap,
    this.showTyping = false,
    this.unreadCount = 0,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasUnread = unreadCount > 0;
    
    return Container(
      color: isSelected ? PRIMARY_COLOR.withOpacity(0.08) : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(customer['avatar'] ?? 'https://placehold.co/40x40'), 
                  ),
                  if (customer['isOnline'] == true)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.shade400,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer['name'] ?? 'Unknown User',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (showTyping)
                      Text(
                        "...is typing",
                        style: TextStyle(
                          fontSize: 13, 
                          color: PRIMARY_COLOR, 
                          fontStyle: FontStyle.italic
                        ),
                      )
                    else
                      Text(
                        customer['lastMessage'] ?? 'No message',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: hasUnread ? Colors.black : Colors.grey.shade600,
                          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                  ],
                ),
              ),
              
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    customer['lastMessageTime'] ?? 'N/A',
                    style: TextStyle(
                      fontSize: 12, 
                      color: hasUnread ? PRIMARY_COLOR : Colors.grey.shade500
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (hasUnread)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: PRIMARY_COLOR,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unreadCount.toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}