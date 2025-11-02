import 'package:flutter/material.dart';
import 'package:recomart/utils/responsive.dart';
import 'invoice_detail_dialog.dart';

class InvoiceTable extends StatelessWidget {
  final List<Map<String, dynamic>> invoices;

  const InvoiceTable({super.key, required this.invoices});

  String _formatDate(String dateString) {
    return dateString.length >= 10 ? dateString.substring(0, 10) : 'N/A';
  }

  String _formatMoney(double amount) {
    return amount.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  TableRow buildHeaderRow(List<String> headers, List<double> colWidths) {
    return TableRow(
      decoration: const BoxDecoration(color: Color.fromARGB(255, 240, 240, 240)),
      children: List.generate(headers.length, (index) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          width: colWidths[index],
          child: Text(
            headers[index],
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }),
    );
  }

  TableRow buildInvoiceRow(BuildContext context, Map<String, dynamic> invoice, List<double> colWidths) {
    final isMobile = Responsive.isMobile(context);
    
    // Sử dụng hàm format FE Stub
    final formattedDate = _formatDate(invoice['orderDate']);
    final formattedTotal = _formatMoney(invoice['totalAmount']);

    return TableRow(
      children: isMobile
          ? [
        InkWell(
          onTap: () => _showInvoiceDetail(context, invoice),
          child: cellText(invoice['id']?.toString() ?? 'N/A', colWidths[0]),
        ),
        InkWell(
          onTap: () => _showInvoiceDetail(context, invoice),
          child: cellText(formattedDate, colWidths[1]),
        ),
        InkWell(
          onTap: () => _showInvoiceDetail(context, invoice),
          child: cellText('${formattedTotal}đ', colWidths[2]),
        ),
      ]
          : [
        InkWell(
          onTap: () => _showInvoiceDetail(context, invoice),
          child: cellText(invoice['id']?.toString() ?? 'N/A', colWidths[0]),
        ),
        InkWell(
          onTap: () => _showInvoiceDetail(context, invoice),
          child: cellText(invoice['customerName']?.toString() ?? 'N/A', colWidths[1]),
        ),
        InkWell(
          onTap: () => _showInvoiceDetail(context, invoice),
          child: cellText(formattedDate, colWidths[2]),
        ),
        InkWell(
          onTap: () => _showInvoiceDetail(context, invoice),
          child: cellText('${formattedTotal}đ', colWidths[3]),
        ),
      ],
    );
  }

  Widget cellText(String text, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        softWrap: false,
      ),
    );
  }

  void _showInvoiceDetail(BuildContext context, Map<String, dynamic> invoice) {
    showDialog(
      context: context,
      builder: (context) {
        return InvoiceDetailDialog(invoice: invoice); 
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = Responsive.isMobile(context);
        final double tableWidth = constraints.maxWidth;

        final List<double> colWidths = isMobile
            ? [tableWidth * 0.3, tableWidth * 0.3, tableWidth * 0.3]
            : List.generate(4, (index) => tableWidth / 4);

        final headers = isMobile
            ? ["Invoice ID", "Date", "Total Amount"]
            : ["Invoice ID", "Customer", "Date", "Total Amount"];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(50),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Invoice List",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: {
                  for (int i = 0; i < colWidths.length; i++) i: FixedColumnWidth(colWidths[i]),
                },
                border: TableBorder.all(color: Colors.grey.shade300),
                children: [
                  buildHeaderRow(headers, colWidths),
                  ...invoices.map((invoice) => buildInvoiceRow(context, invoice, colWidths)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}