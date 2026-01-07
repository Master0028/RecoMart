import 'package:flutter/material.dart';
import 'package:recomart/utils/responsive.dart';
import 'package:intl/intl.dart';
import 'order_detail_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderManagementTable extends StatefulWidget {
  final List<Map<String, dynamic>> orders;

  const OrderManagementTable({super.key, required this.orders});

  @override
  State<OrderManagementTable> createState() => _OrderManagementTableState();
}

class _OrderManagementTableState extends State<OrderManagementTable> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = "All";
  DateTimeRange? _customDateRange;
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  bool _isLoading = false; 

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _currentPage = 1);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  DateTime _parseOrderDate(Map<String, dynamic> order) {
    final raw = order['createdAt'];

    if (raw == null) return DateTime(2000);

    // Firestore Timestamp
    if (raw is Timestamp) {
      return raw.toDate();
    }

    // ISO String
    if (raw is String) {
      return DateTime.tryParse(raw) ?? DateTime(2000);
    }

    // Already DateTime
    if (raw is DateTime) {
      return raw;
    }

    return DateTime(2000);
  }

  List<Map<String, dynamic>> get filteredOrders {
    // 1. Initial Sorting (Newest first)
    List<Map<String, dynamic>> sorted = List.from(widget.orders)
      ..sort((a, b) {
        final dateA = _parseOrderDate(a);
        final dateB = _parseOrderDate(b);
        return dateB.compareTo(dateA);
      });

    // 2. Date Filtering
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekStart = today.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    switch (_selectedFilter) {
      case "Today":
        sorted = sorted.where((o) {
          final d = _parseOrderDate(o);
          return d.isAfter(today.subtract(const Duration(seconds: 1)));
        }).toList();
        break;
      case "Yesterday":
        sorted = sorted.where((o) {
          final d = _parseOrderDate(o);
          return d.isAfter(yesterday) && d.isBefore(today);
        }).toList();
        break;
      case "This Week":
        sorted = sorted.where((o) {
          final d = _parseOrderDate(o);
          return d.isAfter(weekStart.subtract(const Duration(seconds: 1)));
        }).toList();
        break;
      case "This Month":
        sorted = sorted.where((o) {
          final d = _parseOrderDate(o);
          return d.isAfter(monthStart.subtract(const Duration(seconds: 1)));
        }).toList();
        break;
      case "Custom":
        if (_customDateRange != null) {
          sorted = sorted.where((o) {
            final d = _parseOrderDate(o);
            return d.isAfter(_customDateRange!.start) &&
                d.isBefore(_customDateRange!.end.add(const Duration(days: 1)));
          }).toList();
        }
        break;
    }

    // 3. Search Filtering (by Order ID)
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      sorted = sorted.where((o) {
        return (o['id'] as String?)?.toLowerCase().contains(query) ?? false;
      }).toList();
    }

    return sorted;
  }

  List<Map<String, dynamic>> get paginatedOrders {
    final start = (_currentPage - 1) * _itemsPerPage;
    final end = start + _itemsPerPage;
    return filteredOrders.length > start
        ? filteredOrders.sublist(start, end > filteredOrders.length ? filteredOrders.length : end)
        : [];
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING': return Colors.orange.shade700;
      case 'SHIPPING': return Colors.blue.shade700;
      case 'DELIVERED': return Colors.teal.shade700;
      case 'CANCELLED': return Colors.red.shade700;
      default: return Colors.grey.shade600;
    }
  }

  void _showOrderDetail(Map<String, dynamic> order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => OrderDetailDialog(
        order: Map.from(order), 
        onStatusChanged: (newStatus) {
          // Update local state after dialog closes
          setState(() {
            final index = widget.orders.indexWhere((o) => o['id'] == order['id']);
            if (index != -1) {
              widget.orders[index]['status'] = newStatus;
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Status updated successfully: $newStatus"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final int totalPages = ((filteredOrders.length - 1) / _itemsPerPage).ceil();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildControls(isMobile),
            const SizedBox(height: 20),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (filteredOrders.isEmpty)
              const Center(heightFactor: 5, child: Text("No orders found", style: TextStyle(color: Colors.grey)))  
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                  headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                  dataRowMinHeight: 60, 
                  dataRowMaxHeight: 80,
                  columnSpacing: 20, 
                  columns: _buildTableColumns(isMobile),
                  rows: paginatedOrders.map((order) => _buildDataRow(order, isMobile)).toList(),
                ),
              ),
            
            const SizedBox(height: 16),

            if (totalPages > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentPage > 1
                        ? () => setState(() => _currentPage--)
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text("Page $_currentPage / $totalPages"),  
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: (_currentPage * _itemsPerPage) < filteredOrders.length
                        ? () => setState(() => _currentPage++)
                        : null,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildControls(bool isMobile) {
    return isMobile
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Order List", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),  
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildSearchField()),
                const SizedBox(width: 12),
                Expanded(child: _buildFilterDropdown()),
              ],
            )
          ],
        )
      : Row(
          children: [
            const Text("Order List", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),  
            const Spacer(),
            SizedBox(width: 220, child: _buildSearchField()),
            const SizedBox(width: 12),
            SizedBox(width: 180, child: _buildFilterDropdown()),
          ],
        );
  }
  
  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: "Search order ID...",  
        prefixIcon: const Icon(Icons.search, size: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        isDense: true,
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedFilter,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        isDense: true,
      ),
      items: ["All", "Today", "Yesterday", "This Week", "This Month", "Custom"]
          .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13))))
          .toList(),
      onChanged: (value) async {
        if (value == "Custom") {
          final picked = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            initialDateRange: _customDateRange,
          );
          if (picked != null && mounted) {
            setState(() {
              _customDateRange = picked;
              _selectedFilter = value!;
              _currentPage = 1;
            });
          }
        } else if (value != null) {
          setState(() {
            _selectedFilter = value;
            _customDateRange = null;
            _currentPage = 1;
          });
        }
      },
    );
  }

  List<DataColumn> _buildTableColumns(bool isMobile) {
    if (isMobile) {
      return const [
        DataColumn(label: Text('Order ID')),  
        DataColumn(label: Text('Date')),  
        DataColumn(label: Text('Total'), numeric: true),  
      ];
    }
    return const [
      DataColumn(label: Text('Order ID')),  
      DataColumn(label: Text('Customer')),  
      DataColumn(label: Text('Date')),  
      DataColumn(label: Text('Total'), numeric: true),  
      DataColumn(label: Text('Discount'), numeric: true),  
      DataColumn(label: Text('Status')),  
    ];
  }

  DataRow _buildDataRow(Map<String, dynamic> order, bool isMobile) {
    final id = (order['id'] as String?) ?? '';
    final shortId = id.length > 8 ? '${id.substring(0, 8)}...' : id;
    final date = _parseOrderDate(order);
    final total = (order['totalAmount'] as num?)?.toDouble() ?? 0.0;
    final discount = (order['discountApplied'] as num?)?.toDouble() ?? 0.0;
    final status = order['status']?.toString().toUpperCase() ?? 'PENDING';
    final customerName = order['userName'] ?? 'Guest';  
    
    // Currency format for VND, kept local for display accuracy
    final currencyFormatter = NumberFormat('#,##0', 'en_US'); 

    DataCell _clickableCell(Widget child) {
        return DataCell(child, onTap: () => _showOrderDetail(order));
    }
    
    if (isMobile) {
      return DataRow(cells: [
        _clickableCell(Text(shortId, style: const TextStyle(fontWeight: FontWeight.bold))),
        _clickableCell(Text(DateFormat('MM/dd/yyyy').format(date))),
        _clickableCell(Text(
          '${currencyFormatter.format(total)}đ',
          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          textAlign: TextAlign.end,
        )),
      ]);
    }
    
    return DataRow(cells: [
      _clickableCell(Text(shortId, style: const TextStyle(fontWeight: FontWeight.bold))),
      _clickableCell(Text(customerName, overflow: TextOverflow.ellipsis)),
      _clickableCell(Text(DateFormat('MM/dd/yyyy').format(date))),
      _clickableCell(Text(
        '${currencyFormatter.format(total)}đ',
        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        textAlign: TextAlign.end,
      )),
      _clickableCell(Text(
        '-${currencyFormatter.format(discount)}đ',
        style: const TextStyle(color: Colors.redAccent),
        textAlign: TextAlign.end,
      )),
      DataCell(
        Chip(
          label: Text(
            status,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
          ),
          backgroundColor: _getStatusColor(status),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          labelPadding: EdgeInsets.zero,
        ),
        onTap: () => _showOrderDetail(order),
      ),
    ]);
  }
}