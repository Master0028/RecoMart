import 'package:flutter/material.dart';
import 'package:recomart/config/color.dart';
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

  Widget _buildEmptyState() {
    return const Center(
      key: ValueKey('empty_state'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.support_agent_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "Select a customer to view the conversation", // Translated
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Customer Support (Admin)"), // Translated
        backgroundColor: AppColors.primary,
      ),
      body: Row(
        children: [
          // Left Pane: User List
          Container(
            width: 320,
            color: Colors.white,
            child: ChatList(
              onUserSelected: _selectUser,
              selectedUserId: selectedUser?['id'],
            ),
          ),

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (Widget child, Animation<double> animation) {
                // Fade effect when content changes
                return FadeTransition(opacity: animation, child: child);
              },
              child: selectedUser == null
                  ? _buildEmptyState()
                  : ChatArea(
                      key: ValueKey(selectedUser!['id']), 
                      userId: selectedUser!['id'],
                      userName: selectedUser!['name'],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}