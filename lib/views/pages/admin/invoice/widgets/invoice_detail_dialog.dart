import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InvoiceDetailDialog extends StatelessWidget {
  final Map<String, dynamic> invoice; 

  const InvoiceDetailDialog({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final String invoiceId = invoice['id'] ?? 'N/A';
    final String customerName = invoice['customerName'] ?? 'N/A';
    final String orderDateString = invoice['orderDate'] ?? DateTime.now().toIso8601String();
    final double totalAmount = invoice['totalAmount'] as double? ?? 0.0;
    final double discountApplied = invoice['discountApplied'] as double? ?? 0.0;
    final List<dynamic> products = invoice['products'] as List<dynamic>? ?? [];

    String formatCurrency(double amount) {
        return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(amount);
    }

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Invoice Details - $invoiceId",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        "Invoice Information",
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
                            "Invoice Date: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(orderDateString))}",
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
                            "Total Amount: ${formatCurrency(totalAmount)}",
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
                            "Discount Applied: ${formatCurrency(discountApplied)}",
                            style: const TextStyle(fontSize: 14, color: Colors.redAccent),
                          ),
                        ],
                      ),
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
                        "Products",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...products.asMap().entries.map<Widget>((entry) {
                        final index = entry.key;
                        final product = entry.value as Map<String, dynamic>;
                        final double unitPrice = product['unit_price'] as double? ?? 0.0;
                        final int quantity = product['quantity'] as int? ?? 0;
                        
                        return Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.laptop, color: Colors.grey),
                              title: Text(
                                "${product['name'] ?? 'Unknown Product'} (x$quantity)",
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              trailing: Text(
                                formatCurrency(unitPrice * quantity),
                                style: const TextStyle(fontSize: 14, color: Colors.blue),
                              ),
                            ),
                            if (index < products.length - 1) const Divider(),
                          ],
                        );
                      }).toList(),
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Close", style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }
}