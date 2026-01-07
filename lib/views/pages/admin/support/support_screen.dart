import 'package:flutter/material.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/services/chat.service.dart';
import 'package:recomart/views/pages/admin/support/widgets/chat_area.dart';
import 'package:recomart/views/pages/admin/support/widgets/chat_list.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<SupportScreen> {
  Map<String, dynamic>? selectedUser;

  void _selectUser(Map<String, dynamic> user) {
    setState(() => selectedUser = user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Hỗ trợ khách hàng (Admin)"),
        backgroundColor: AppColors.primary,
      ),
      body: Row(
        children: [
          // Danh sách user bên trái
          Container(
            width: 320,
            color: Colors.white,
            child: ChatList(
              onUserSelected: _selectUser,
              selectedUserId: selectedUser?['id'],
            ),
          ),

          // Khung chat bên phải
          Expanded(
            child: selectedUser == null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.support_agent_outlined,
                      size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "Chọn khách hàng để xem cuộc trò chuyện",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
                : ChatArea(
              userId: selectedUser!['id'],
              userName: selectedUser!['name'],
            ),
          ),
        ],
      ),
    );
  }
}