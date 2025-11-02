import 'package:flutter/material.dart';
import 'package:recomart/views/pages/admin/invoice/widgets/invoice_table.dart'; 

// Dữ liệu giả lập 
final List<Map<String, dynamic>> FE_INVOICES_STUB = [
  {
    'id': 'INV-001',
    'customerName': 'Nguyễn Văn A',
    'orderDate': '2025-10-25',
    'totalAmount': 55000000.0,
    'discountApplied': 5000000.0,
    'products': [
      {'name': 'Laptop XPS 15', 'quantity': 1, 'unit_price': 50000000.0},
      {'name': 'Mouse Logitech', 'quantity': 1, 'unit_price': 500000.0},
    ],
  },
  {
    'id': 'INV-002',
    'customerName': 'Trần Thị B',
    'orderDate': '2025-10-26',
    'totalAmount': 12000000.0,
    'discountApplied': 0.0,
    'products': [
      {'name': 'Điện thoại Sam', 'quantity': 2, 'unit_price': 6000000.0},
    ],
  },
];

class InvoiceManagementScreen extends StatelessWidget {
  const InvoiceManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    const bool isLoading = false;
    final List<Map<String, dynamic>> invoices = FE_INVOICES_STUB;

    return Container(
      color: Colors.grey[100],
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLoading)
              // ignore: dead_code
              const Center(child: CircularProgressIndicator())
            else if (invoices.isEmpty)
              const Center(child: Text("No paid invoices found"))
            else
              InvoiceTable(invoices: invoices),
          ],
        ),
      ),
    );
  }
}