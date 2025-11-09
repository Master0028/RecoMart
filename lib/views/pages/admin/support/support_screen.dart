import 'package:flutter/material.dart';
import 'package:recomart/utils/responsive.dart';
import 'package:recomart/views/pages/admin/support/widgets/chat_area.dart' hide Responsive; 
import 'package:recomart/views/pages/admin/support/widgets/chat_list.dart';

final List<Map<String, dynamic>> FE_CUSTOMERS_STUB = [
  {"id": 1, "name": "John Doe", "lastMessage": "Need help with order #1234.", "isOnline": true, "avatar": "https://placehold.co/60x60/4A90E2/ffffff/png"},
  {"id": 2, "name": "Jane Smith", "lastMessage": "Issue with delivery date.", "isOnline": false, "avatar": "https://placehold.co/60x60/E86872/ffffff/png"},
  {"id": 3, "name": "Alice Johnson", "lastMessage": "How to track my return.", "isOnline": true, "avatar": "https://placehold.co/60x60/8B5CF6/ffffff/png"},
  {"id": 4, "name": "Bob Williams", "lastMessage": "Pricing query on Laptop X.", "isOnline": false, "avatar": "https://placehold.co/60x60/34D399/ffffff/png"},
];
const Color primaryColor = Color(0xFF1E88E5);
const Color secondaryColor = Color(0xFFF5F5F5);


class SupportScreen extends StatefulWidget {
  final ValueChanged<bool> onChatAreaVisibilityChanged;

  const SupportScreen({
    super.key,
    required this.onChatAreaVisibilityChanged,
  });

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  Map<String, dynamic>? selectedCustomer; 
  final List<Map<String, dynamic>> customers = FE_CUSTOMERS_STUB;

  void _selectCustomer(Map<String, dynamic> customer) {
    setState(() {
      selectedCustomer = customer;
      widget.onChatAreaVisibilityChanged(selectedCustomer != null); 
    });
  }

  void _onMobileBack() {
    setState(() {
      selectedCustomer = null;
      widget.onChatAreaVisibilityChanged(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context); 

    return Container(
      color: secondaryColor,
      child: isMobile
          ?
            selectedCustomer == null
              ? ChatList(
                  customers: customers,
                  onSelectCustomer: _selectCustomer,
                )
              : ChatArea(
                  customer: selectedCustomer!,
                  onBack: _onMobileBack, 
                )
          :
            Row(
              children: [
                Container(
                  width: 350,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      right: BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                  ),
                  child: ChatList(
                    customers: customers,
                    onSelectCustomer: _selectCustomer,
                  ),
                ),
                
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: selectedCustomer == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.support_agent_outlined,
                                  size: 80,
                                  color: primaryColor.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Chọn một khách hàng để bắt đầu phiên trò chuyện",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ChatArea(customer: selectedCustomer!),
                  ),
                ),
              ],
            ),
    );
  }
}