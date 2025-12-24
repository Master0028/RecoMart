import 'package:flutter/material.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/views/pages/admin/support/widgets/chat_area.dart';
import 'package:recomart/views/pages/admin/support/widgets/chat_list.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  Map<String, dynamic>? selectedUser;

  void _selectUser(Map<String, dynamic> user, bool isMobile) {
    setState(() => selectedUser = user);
    
    if (isMobile) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text(user['name'] ?? 'Chat'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            body: ChatArea(
              userId: user['id'],
              userName: user['name'],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth > 768;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FB),
          appBar: AppBar(
            elevation: 0.5,
            backgroundColor: Colors.white,
            centerTitle: false,
            title: const Text(
              "Customer Support",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: isWideScreen ? _buildWebLayout() : _buildMobileLayout(),
        );
      },
    );
  }

  Widget _buildWebLayout() {
    return Row(
      children: [
        Container(
          width: 350,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ChatList(
              onUserSelected: (user) => _selectUser(user, false),
              selectedUserId: selectedUser?['id'],
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(top: 16, bottom: 16, right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: selectedUser == null
                  ? _buildEmptyState()
                  : ChatArea(
                      key: ValueKey(selectedUser!['id']),
                      userId: selectedUser!['id'],
                      userName: selectedUser!['name'],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return ChatList(
      onUserSelected: (user) => _selectUser(user, true),
      selectedUserId: selectedUser?['id'],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      key: const ValueKey('empty_state'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.forum_rounded, 
              size: 64, 
              color: AppColors.primary.withOpacity(0.5)
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Select a conversation",
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.w600, 
              color: Colors.blueGrey
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Message content will appear here",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}