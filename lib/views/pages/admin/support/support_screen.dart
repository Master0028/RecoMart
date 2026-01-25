import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/pattern/singleton.dart';
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
    setState(() {
      selectedUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isLogged = UserSession.instance.userId != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Customer Support (Admin Dashboard)",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: !isLogged 
        ? _buildLoginRequired()
        : Row(
            children: [
              Container(
                width: 320,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    right: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
                ),
                child: ChatList(
                  onUserSelected: _selectUser,
                  selectedUserId: selectedUser?['id']?.toString(),
                ),
              ),
              Expanded(
                child: selectedUser == null
                    ? _buildEmptyState()
                    : ChatArea(
                        key: ValueKey(selectedUser!['id'].toString()),
                        userId: selectedUser!['id'].toString(),
                        userName: selectedUser!['name'] ?? "Guest User",
                      ),
              ),
            ],
          ),
    );
  }

  Widget _buildLoginRequired() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, size: 80, color: Colors.redAccent),
          const SizedBox(height: 16),
          const Text(
            "Access Denied",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Please login as Admin to view messages",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/login'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text("Go to Login", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.support_agent_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Please choose a customer to support",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Select a conversation from the left panel",
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}