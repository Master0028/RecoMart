import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../services/order.service.dart';

class OrderDetailDialog extends StatefulWidget {
  final Map<String, dynamic> order;
  final void Function(String) onStatusChanged;

  const OrderDetailDialog({
    super.key,
    required this.order,
    required this.onStatusChanged,
  });

  @override
  State<OrderDetailDialog> createState() => _OrderDetailDialogState();
}

class _OrderDetailDialogState extends State<OrderDetailDialog> {
  late String _selectedStatus;
  final List<String> _orderStatuses = ['PENDING', 'SHIPPING', 'DELIVERED', 'CANCELLED'];
  late TextEditingController _statusController;
  final OrderService _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.order['status'] ?? 'PENDING';
    _statusController = TextEditingController(text: _selectedStatus);
  }

  String _formatMoney(double amount) {
    return NumberFormat.decimalPattern('en_US').format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final String orderId = widget.order['id'] ?? 'N/A';
    final String customerName = widget.order['customerName'] ?? 'N/A';
    final DateTime orderDate = widget.order['orderDate'] != null
        ? DateTime.tryParse(widget.order['orderDate']) ?? DateTime.now()
        : DateTime.now();
    final double totalAmount = widget.order['totalAmount'] as double? ?? 0.0;
    final double discountApplied = widget.order['discountApplied'] as double? ?? 0.0;
    final List<dynamic> products = widget.order['products'] as List<dynamic>? ?? [];

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Order Details - $orderId",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- GENERAL ORDER INFO ---
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Order Information",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.person, color: Colors.grey, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Customer: $customerName",
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Order Date: ${DateFormat('dd/MM/yyyy HH:mm').format(orderDate)}",
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.attach_money, color: Colors.grey, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Total Amount: ${_formatMoney(totalAmount)}đ",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.discount, color: Colors.grey, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Discount Applied: -${_formatMoney(discountApplied)}đ",
                            style: const TextStyle(fontSize: 14, color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // --- PRODUCTS LIST ---
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Products",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...products
                          .asMap()
                          .entries
                          .map<Widget>((entry) {
                        final index = entry.key;
                        final product = entry.value as Map<String, dynamic>? ?? {};
                        final double unitPrice = product['unit_price'] as double? ?? product['price'] as double? ?? 0.0;
                        final int quantity = product['quantity'] as int? ?? 0;
                        
                        return Column(
                          children: [
                            ListTile(
                              leading: product['imageUrl'] != ''
                                  ? Image.network(product['imageUrl'], width: 40, height: 40, fit: BoxFit.cover)
                                  : const Icon(Icons.shopping_bag, color: Colors.grey),
                              title: Text(
                                "${product['name']} (x$quantity)",
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              subtitle: product['discount'] != 0
                                  ? Text("Discount: ${product['discount']}%", style: const TextStyle(color: Colors.redAccent))
                                  : null,
                              trailing: Text(
                                "${_formatMoney(unitPrice * quantity)}đ",
                                style: const TextStyle(fontSize: 14, color: Colors.blue),
                              ),
                            ),
                            if (index < products.length - 1)
                              const Divider(),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Status",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownMenu<String>(
                              initialSelection: _selectedStatus,
                              onSelected: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedStatus = value;
                                  });
                                }
                              },
                              dropdownMenuEntries: _orderStatuses
                                  .map((value) => DropdownMenuEntry(
                                    value: value,
                                    label: value,
                                  ))
                                  .toList(),
                              textStyle: const TextStyle(fontSize: 14, color: Colors.black),
                              menuStyle: const MenuStyle(
                                backgroundColor: WidgetStatePropertyAll(Colors.white),
                              ),
                              inputDecorationTheme: const InputDecorationTheme(
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.orange, width: 2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text("Close", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () async {
            final orderId = widget.order['id'];
            if (orderId == null) return;

            try {
              await _orderService.updateOrderStatus(orderId, _selectedStatus);
              widget.onStatusChanged(_selectedStatus);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Order status updated for $orderId: $_selectedStatus"),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                context.pop();
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Error updating status: $e"), 
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text("Save", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}