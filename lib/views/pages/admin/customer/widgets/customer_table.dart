import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recomart/utils/responsive.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:recomart/config/color.dart';
import '../../../../../models/user.model.dart';
import '../../../../../provider/user_provider.dart';
import 'customer_form.dart';

class CustomerTable extends StatefulWidget {
  final List<UserModel> customers;
  final Function(UserModel) onViewDetail;

  const CustomerTable({
    super.key,
    required this.customers,
    required this.onViewDetail,
  });

  @override
  State<CustomerTable> createState() => _CustomerTableState();
}

class _CustomerTableState extends State<CustomerTable> {
  final TextEditingController _searchController = TextEditingController();
  final int _itemsPerPage = 10;
  // int _currentPage = 1; // (Tạm chưa dùng phân trang để đơn giản hóa)

  static const List<Map<String, dynamic>> ALL_FIELDS = [
    {'key': 'id', 'label': 'ID'},
    {'key': 'fullName', 'label': 'Customer'},
    {'key': 'phone', 'label': 'Phone'},
    {'key': 'email', 'label': 'Email'},
    {'key': 'loyaltyPoints', 'label': 'Points'},
    {'key': 'address', 'label': 'Address'},
    {'key': 'isActive', 'label': 'Status'},
    {'key': 'actions', 'label': 'Actions'},
  ];

  // --- 1. FIX LỖI RANGE ERROR (MÀN HÌNH ĐỎ) ---
  String _getShortId(String? id) {
    if (id == null || id.isEmpty) return 'N/A';
    if (id.length <= 5) return id; // Nếu ID ngắn quá thì trả về nguyên gốc
    return id.substring(0, 5); // Chỉ cắt khi ID đủ dài
  }

  List<UserModel> get filteredCustomers {
    var customers = widget.customers;
    if (_searchController.text.isNotEmpty) {
      customers = customers.where((customer) {
        return customer.fullName != null &&
            customer.fullName!
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());
      }).toList();
    }
    // Tạm thời return all để tránh lỗi logic phân trang khi list rỗng
    return customers; 
  }

  Color _getStatusColor(bool isActive) =>
      isActive ? Colors.green : Colors.red;

  List<Map<String, dynamic>> _getVisibleFields(UserModel? customer) {
    if (Responsive.isMobile(context)) {
      return ALL_FIELDS.where((f) => 
        ['id', 'fullName', 'isActive', 'actions'].contains(f['key'])
      ).toList();
    }
    return ALL_FIELDS;
  }

  Future<void> _toggleStatus(UserModel customer) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final newStatus = !(customer.isActive ?? false);

    try {
      if (customer.id != null) {
        await userProvider.toggleUserStatus(customer.id!, newStatus);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(newStatus ? 'Account activated' : 'Account banned'),
              backgroundColor: newStatus ? Colors.green : Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showCustomerForm(UserModel customer) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(customer.fullName ?? 'Edit User'),
          content: CustomerForm(customer: customer, canEditStatus: true),
        );
      },
    );
  }

  TableRow buildHeaderRow(
      List<Map<String, dynamic>> fields, List<double> colWidths) {
    return TableRow(
      decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
      children: List.generate(fields.length, (index) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          alignment: Alignment.centerLeft,
          child: Text(
            fields[index]['label'],
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
          ),
        );
      }),
    );
  }

  TableRow buildCustomerRow(UserModel customer,
      List<Map<String, dynamic>> fields, List<double> colWidths) {
    
    List<Widget> cells = fields.map((field) {
      final key = field['key'];

      if (key == 'fullName') {
        return customerCell(customer);
      } 
      else if (key == 'isActive') {
        final isActive = customer.isActive ?? false;
        return TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () => _toggleStatus(customer),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isActive ? Colors.green : Colors.red),
                ),
                child: Text(
                  isActive ? 'Active' : 'Banned',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isActive ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      } 
      else if (key == 'actions') {
        return TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(FeatherIcons.eye, size: 18, color: AppColors.primary),
                tooltip: "View Insight",
                onPressed: () => widget.onViewDetail(customer),
              ),
              IconButton(
                icon: const Icon(FeatherIcons.edit2, size: 18, color: Colors.grey),
                onPressed: () => _showCustomerForm(customer),
              ),
            ],
          ),
        );
      } 
      else {
        String value = '';
        switch (key) {
          case 'id': value = _getShortId(customer.id); break; // Sử dụng hàm an toàn
          case 'phone': value = customer.phone ?? '-'; break;
          case 'email': value = customer.email ?? '-'; break;
          case 'loyaltyPoints': value = '${customer.loyaltyPoints ?? 0}'; break;
          case 'address': value = customer.address ?? '-'; break;
        }
        return cellText(value);
      }
    }).toList();

    return TableRow(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      children: cells,
    );
  }

  Widget cellText(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
    child: Text(text, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
  );

  Widget customerCell(UserModel customer) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    child: Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage: NetworkImage(customer.avatar ?? 'https://placehold.co/100'),
          backgroundColor: Colors.grey[200],
          onBackgroundImageError: (_,__) {},
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(customer.fullName ?? 'Unknown', 
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  overflow: TextOverflow.ellipsis),
              Text("ID: ${_getShortId(customer.id)}", // Sử dụng hàm an toàn
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
      final headerFields = _getVisibleFields(null); 
      
      final Map<int, TableColumnWidth> colWidths = {};
      final double totalWidth = constraints.maxWidth;
      
      // Cấu hình độ rộng cột
      if (isMobile) {
        colWidths[0] = FixedColumnWidth(totalWidth * 0.15); 
        colWidths[1] = FixedColumnWidth(totalWidth * 0.40); 
        colWidths[2] = FixedColumnWidth(totalWidth * 0.20); 
        colWidths[3] = FixedColumnWidth(totalWidth * 0.25); 
      } else {
        // Desktop: Tự động chia tỷ lệ
        for(int i=0; i<headerFields.length; i++) {
           if (headerFields[i]['key'] == 'fullName') {
             colWidths[i] = const FlexColumnWidth(2);
           } else if (headerFields[i]['key'] == 'email') {
             colWidths[i] = const FlexColumnWidth(1.5);
           } else {
             colWidths[i] = const FlexColumnWidth(1);
           }
        }
      }

      return Container(
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
        child: Column(
          mainAxisSize: MainAxisSize.min, // 2. FIX LỖI UNBOUNDED HEIGHT
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Title + Search
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text("All Customers", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  SizedBox(
                    width: isMobile ? 150 : 250,
                    height: 40,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: const Icon(FeatherIcons.search, size: 16),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
            ),
            
            // 3. FIX LỖI RENDERFLEX: 
            // Xóa Expanded bao quanh SingleChildScrollView vì widget cha bên ngoài đã cuộn rồi.
            // Hoặc dùng SingleChildScrollView trực tiếp nếu cần cuộn ngang.
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: isMobile ? totalWidth : constraints.maxWidth, // Đảm bảo width
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: colWidths,
                  children: [
                    buildHeaderRow(headerFields, []),
                    ...filteredCustomers.map((c) => buildCustomerRow(c, headerFields, [])),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      );
    });
  }
}