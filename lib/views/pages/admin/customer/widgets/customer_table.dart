import 'package:flutter/material.dart';
import 'package:recomart/utils/responsive.dart';
import 'customer_form.dart';
import '../customer_screen.dart'; 


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
    return customers.skip(start).take(_itemsPerPage).toList();
  }

  int get totalPages => (widget.customers.length / _itemsPerPage).ceil();

  Color _getStatusColor(bool isActive) {
    return isActive ? Colors.green : Colors.red;
  }

  List<Map<String, dynamic>> _getVisibleFields(UserModel? customer) {
      if (customer == null) return ALL_FIELDS.take(3).toList();
      
      return ALL_FIELDS.where((field) {
          switch (field['key']) {
              case 'phone': return customer.phone != null && customer.phone!.isNotEmpty;
              case 'loyaltyPoints': return customer.loyaltyPoints > 0;
              case 'address': return customer.address != null && customer.address!.isNotEmpty;
              default: return true;
          }
      }).toList();
  }

  void _toggleStatus(UserModel customer) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final updatedUser = customer.copyWith(isActive: !customer.isActive);
      setState(() {
        final index = widget.customers.indexWhere((c) => c.id == customer.id);
        if (index != -1) {
          widget.customers[index] = updatedUser;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status toggled successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to toggle status.')),
      );
    }
  }

  void _showCustomerForm(UserModel customer) {
    final visibleFields = _getVisibleFields(customer);
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
                labelStyle: TextStyle(color: Colors.black),
                floatingLabelStyle: TextStyle(color: Colors.orange),
              ),
            ),
            child: CustomerForm(
              buttonLabel: "Save",
              initialCustomer: {
                'id': customer.id,
                'name': customer.fullName,
                'phone': customer.phone ?? '',
                'email': customer.email,
                'address': customer.address ?? '',
                'status': customer.isActive ? 'Active' : 'Disabled',
                'avatar': {
                  'url': customer.avatar?.url ?? '',
                  'public_id': customer.avatar?.public_id ?? '',
                },
              },
              visibleFields: visibleFields.map((field) => field['key'] as String).toList(),
              onSubmit: (updatedCustomerData) async {
                try {
                  await Future.delayed(const Duration(milliseconds: 300));
                  
                  final newStatus = updatedCustomerData['status'] == 'Active';
                  final updatedUser = customer.copyWith(isActive: newStatus);

                  setState(() {
                    final index = widget.customers.indexWhere((c) => c.id == customer.id);
                    if (index != -1) {
                      widget.customers[index] = updatedUser;
                    }
                  });
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update customer.')),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  TableRow buildHeaderRow(List<Map<String, dynamic>> fields, List<double> colWidths) {
    return TableRow(
      decoration: const BoxDecoration(
          color: Color.fromARGB(255, 240, 240, 240)),
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

  TableRow buildCustomerRow(UserModel customer, List<Map<String, dynamic>> fields, List<double> colWidths) {
    
    List<Widget> cells = fields
        .asMap()
        .entries
        .map((entry) {
      final index = entry.key;
      final field = entry.value;
      final key = field['key'] as String;
      
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
            value = customer.id.length > 5 ? customer.id.substring(0, 5) : customer.id; 
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
        child: Padding(
            padding: EdgeInsets.zero,
            child: cellContent,
        ),
      );

    }).toList();
    
    return TableRow(children: cells);
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

  Widget customerCell(UserModel customer, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: customer.avatar?.url.isNotEmpty ?? false
                ? NetworkImage(customer.avatar!.url)
                : const NetworkImage(
              'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.fullName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "ID: ${customer.id.length > 5 ? customer.id.substring(0, 5) : customer.id}", 
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = Responsive.isMobile(context);
        final tableWidth = constraints.maxWidth;
        
        final List<Map<String, dynamic>> headerFields = _getVisibleFields(widget.customers.isNotEmpty ? widget.customers.first : null);
        final int numColumns = headerFields.length;
        
        final List<double> desktopWidths = [
            tableWidth * 0.10,
            tableWidth * 0.25,
            tableWidth * 0.15,
            tableWidth * 0.20,
            tableWidth * 0.10,
            tableWidth * 0.20,
        ];
        
        final List<double> mobileWidths = [
            tableWidth * 0.20, 
            tableWidth * 0.55, 
            tableWidth * 0.25
        ];
        
        final List<double> desiredWidths = isMobile ? mobileWidths : desktopWidths;
        
        final List<double> effectiveWidths = List.generate(numColumns, (index) {
            if (index < desiredWidths.length) {
                return desiredWidths[index];
            }
            return tableWidth / numColumns;
        });
        
        final double totalTableWidth = effectiveWidths.fold(0.0, (sum, width) => sum + width);
        
        final double finalTableWidth = isMobile ? tableWidth : totalTableWidth;

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
          child: ConstrainedBox( 
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8), 
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: finalTableWidth,
                  child: Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: {
                      for (int i = 0; i < numColumns; i++)
                        i: FixedColumnWidth(effectiveWidths[i]),
                    },
                    border: TableBorder.all(color: Colors.grey.shade300),
                    children: [
                      buildHeaderRow(headerFields, effectiveWidths),
                      ...filteredCustomers.map(
                          (customer) => buildCustomerRow(customer, headerFields, effectiveWidths),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}