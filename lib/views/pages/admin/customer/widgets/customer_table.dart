import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recomart/utils/responsive.dart';
import '../../../../../models/user.model.dart';
import '../../../../../provider/user_provider.dart';
import 'customer_form.dart';

class CustomerTable extends StatefulWidget {
  final List<UserModel> customers;

  const CustomerTable({super.key, required this.customers});

  @override
  State<CustomerTable> createState() => _CustomerTableState();
}

class _CustomerTableState extends State<CustomerTable> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  static const List<Map<String, dynamic>> ALL_FIELDS = [
    {'key': 'id', 'label': 'ID'},
    {'key': 'fullName', 'label': 'Customer'},
    {'key': 'phone', 'label': 'Phone'},
    {'key': 'email', 'label': 'Email'},
    {'key': 'loyaltyPoints', 'label': 'Points'},
    {'key': 'address', 'label': 'Address'},
    {'key': 'isActive', 'label': 'Status'},
  ];

  List<UserModel> get filteredCustomers {
    var customers = widget.customers;
    if (_searchController.text.isNotEmpty) {
      customers = customers.where((customer) {
        return customer.fullName
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
      }).toList();
    }
    final start = (_currentPage - 1) * _itemsPerPage;
    // Ensure we don't skip more than available
    if (start >= customers.length) return [];
    
    return customers.skip(start).take(_itemsPerPage).toList();
  }

  // Not used in UI yet, but kept for future pagination UI
  int get totalPages => (widget.customers.length / _itemsPerPage).ceil();

  Color _getStatusColor(bool isActive) =>
      isActive ? Colors.green : Colors.red;

  List<Map<String, dynamic>> _getVisibleFields(UserModel? customer) {
    if (customer == null) return ALL_FIELDS.take(3).toList();

    return ALL_FIELDS.where((field) {
      switch (field['key']) {
        case 'phone':
          return customer.phone != null && customer.phone!.isNotEmpty;
        case 'loyaltyPoints':
          return customer.loyaltyPoints > 0;
        case 'address':
          return customer.address != null && customer.address!.isNotEmpty;
        default:
          return true;
      }
    }).toList();
  }

  /// 🔹 Ban or Activate Customer (update Firestore)
  Future<void> _toggleStatus(UserModel customer) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final newStatus = !customer.isActive;

    try {
      await userProvider.toggleUserStatus(customer.id, newStatus);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              newStatus ? 'Account activated successfully' : 'Customer has been banned'),
          backgroundColor: newStatus ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCustomerForm(UserModel customer) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            customer.fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: const InputDecorationTheme(
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange, width: 2),
                ),
              ),
            ),
            child: CustomerForm(
              customer: customer,
              canEditStatus: true,
            ),
          ),
        );
      },
    );
  }

  TableRow buildHeaderRow(
      List<Map<String, dynamic>> fields, List<double> colWidths) {
    return TableRow(
      decoration:
      const BoxDecoration(color: Color.fromARGB(255, 240, 240, 240)),
      children: List.generate(fields.length, (index) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          width: colWidths[index],
          child: Text(
            fields[index]['label'] as String,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }),
    );
  }

  TableRow buildCustomerRow(UserModel customer,
      List<Map<String, dynamic>> fields, List<double> colWidths) {
    List<Widget> cells = fields.asMap().entries.map((entry) {
      final index = entry.key;
      final key = entry.value['key'] as String;

      Widget cellContent;

      if (key == 'fullName') {
        cellContent = customerCell(customer, colWidths[index]);
      } else if (key == 'isActive') {
        cellContent = GestureDetector(
          onTap: () => _toggleStatus(customer),
          child: Container(
            width: colWidths[index],
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Chip(
              label: Text(
                customer.isActive ? 'Active' : 'Disabled',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: _getStatusColor(customer.isActive),
            ),
          ),
        );
      } else {
        String value;
        switch (key) {
          case 'id':
            value = customer.id.length > 5
                ? customer.id.substring(0, 5)
                : customer.id;
            break;
          case 'phone':
            value = customer.phone ?? 'N/A';
            break;
          case 'email':
            value = customer.email;
            break;
          case 'loyaltyPoints':
            value = customer.loyaltyPoints.toStringAsFixed(1);
            break;
          case 'address':
            value = customer.address ?? 'N/A';
            break;
          default:
            value = '';
        }
        cellContent = cellText(value, colWidths[index]);
      }

      return InkWell(
        onTap: key != 'isActive' ? () => _showCustomerForm(customer) : null,
        child: cellContent,
      );
    }).toList();

    return TableRow(children: cells);
  }

  Widget cellText(String text, double width) => Container(
    width: width,
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    child: Text(
      text,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    ),
  );

  Widget customerCell(UserModel customer, double width) => Container(
    width: width,
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    child: Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: customer.avatar != null &&
              customer.avatar!.isNotEmpty
              ? NetworkImage(customer.avatar!)
              : const NetworkImage(
              'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(customer.fullName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1),
              Text(
                "ID: ${customer.id.length > 5 ? customer.id.substring(0, 5) : customer.id}",
                style:
                TextStyle(fontSize: 12, color: Colors.grey.shade600),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = Responsive.isMobile(context);
      final tableWidth = constraints.maxWidth;
      final headerFields = _getVisibleFields(
          widget.customers.isNotEmpty ? widget.customers.first : null);
      final numColumns = headerFields.length;

      final desktopWidths = [
        tableWidth * 0.08, // ID
        tableWidth * 0.25, // Customer
        tableWidth * 0.15, // Phone
        tableWidth * 0.20, // Email
        tableWidth * 0.10, // Points
        tableWidth * 0.20, // Address
        tableWidth * 0.10, // Status
      ];

      final mobileWidths = [
        tableWidth * 0.20,
        tableWidth * 0.55,
        tableWidth * 0.25,
      ];

      final desiredWidths = isMobile ? mobileWidths : desktopWidths;

      final effectiveWidths = List.generate(numColumns, (index) {
        if (index < desiredWidths.length) return desiredWidths[index];
        return tableWidth / numColumns;
      });

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
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Customer List',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 200,
                  height: 36,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12),
                      hintText: 'Search by name',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: {
                    for (int i = 0; i < numColumns; i++)
                      i: FixedColumnWidth(effectiveWidths[i]),
                  },
                  border: TableBorder.all(color: Colors.grey.shade300),
                  children: [
                    buildHeaderRow(headerFields, effectiveWidths),
                    ...filteredCustomers.map((c) =>
                        buildCustomerRow(c, headerFields, effectiveWidths)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}