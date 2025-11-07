import 'package:flutter/material.dart';
import 'package:recomart/utils/responsive.dart';
import 'package:intl/intl.dart';
import 'order_detail_dialog.dart';

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
  final int _itemsPerPage = 20;
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

  List<Map<String, dynamic>> get filteredOrders {
    List<Map<String, dynamic>> sorted = List.from(widget.orders)
      ..sort((a, b) {
        final dateA = DateTime.tryParse(a['orderDate'] ?? '') ?? DateTime(2000);
        final dateB = DateTime.tryParse(b['orderDate'] ?? '') ?? DateTime(2000);
        return dateB.compareTo(dateA);
      });

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekStart = today.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    switch (_selectedFilter) {
      case "Today":
        sorted = sorted.where((o) {
          final d = DateTime.tryParse(o['orderDate'] ?? '') ?? DateTime(2000);
          return d.isAfter(today.subtract(const Duration(seconds: 1))) || d.isAtSameMomentAs(today);
        }).toList();
        break;
      case "Yesterday":
        sorted = sorted.where((o) {
          final d = DateTime.tryParse(o['orderDate'] ?? '') ?? DateTime(2000);
          return d.isAfter(yesterday) && d.isBefore(today);
        }).toList();
        break;
      case "This Week":
        sorted = sorted.where((o) {
          final d = DateTime.tryParse(o['orderDate'] ?? '') ?? DateTime(2000);
          return d.isAfter(weekStart.subtract(const Duration(seconds: 1)));
        }).toList();
        break;
      case "This Month":
        sorted = sorted.where((o) {
          final d = DateTime.tryParse(o['orderDate'] ?? '') ?? DateTime(2000);
          return d.isAfter(monthStart.subtract(const Duration(seconds: 1)));
        }).toList();
        break;
      case "Custom":
        if (_customDateRange != null) {
          sorted = sorted.where((o) {
            final d = DateTime.tryParse(o['orderDate'] ?? '') ?? DateTime(2000);
            return d.isAfter(_customDateRange!.start) &&
                d.isBefore(_customDateRange!.end.add(const Duration(days: 1)));
          }).toList();
        }
        break;
    }

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
        order: Map.from(order), // Clone để tránh thay đổi gốc
        onStatusChanged: (newStatus) {
          setState(() {
            order['status'] = newStatus;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Cập nhật trạng thái thành công: $newStatus"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(String title, double width, {bool isMobile = false}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Text(
        title,
        textAlign: isMobile ? TextAlign.left : TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  Widget _buildCell(String text, double width, {Color? color, bool bold = false}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: color ?? Colors.black87,
          fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final width = MediaQuery.of(context).size.width;
    final colCount = isMobile ? 3 : 6;
    final colWidth = width / colCount;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header + Controls
            Row(
              children: [
                const Text("Danh sách đơn hàng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                // Search
                SizedBox(
                  width: isMobile ? 140 : 220,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Tìm mã đơn...",
                      prefixIcon: const Icon(Icons.search, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Filter
                SizedBox(
                  width: isMobile ? 130 : 180,
                  child: DropdownButtonFormField<String>(
                    value: _selectedFilter,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Table
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (filteredOrders.isEmpty)
              const Center(child: Text("Không có đơn hàng nào", style: TextStyle(color: Colors.grey)))
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: constraints.maxWidth),
                      child: Column(
                        children: [
                          // Header Row
                          Row(
                            children: isMobile
                                ? ["Mã đơn", "Ngày", "Tổng tiền"]
                                    .map((h) => _buildHeader(h, colWidth, isMobile: true))
                                    .toList()
                                : ["Mã đơn", "Khách hàng", "Ngày", "Tổng tiền", "Giảm giá", "Trạng thái"]
                                    .map((h) => _buildHeader(h, colWidth))
                                    .toList(),
                          ),
                          // Data Rows
                          ...paginatedOrders.map((order) {
                            final id = (order['id'] as String?) ?? '';
                            final shortId = id.length > 8 ? '${id.substring(0, 8)}...' : id;
                            final date = DateTime.tryParse(order['orderDate'] ?? '') ?? DateTime.now();
                            final total = (order['totalAmount'] as num?)?.toDouble() ?? 0.0;
                            final discount = (order['discountApplied'] as num?)?.toDouble() ?? 0.0;

                            return InkWell(
                              onTap: () => _showOrderDetail(order),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  children: isMobile
                                      ? [
                                          _buildCell(shortId, colWidth, bold: true),
                                          _buildCell(DateFormat('dd/MM/yyyy').format(date), colWidth),
                                          _buildCell('${NumberFormat('#,##0', 'vi').format(total)}đ', colWidth, color: Colors.blue, bold: true),
                                        ]
                                      : [
                                          _buildCell(shortId, colWidth, bold: true),
                                          _buildCell(order['customerName'] ?? 'Khách lẻ', colWidth),
                                          _buildCell(DateFormat('dd/MM/yyyy').format(date), colWidth),
                                          _buildCell('${NumberFormat('#,##0', 'vi').format(total)}đ', colWidth, color: Colors.blue, bold: true),
                                          _buildCell('-${NumberFormat('#,##0', 'vi').format(discount)}đ', colWidth, color: Colors.redAccent),
                                          Container(
                                            width: colWidth,
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            child: Chip(
                                              label: Text(
                                                order['status']?.toString().toUpperCase() ?? 'PENDING',
                                                style: const TextStyle(color: Colors.white, fontSize: 11),
                                              ),
                                              backgroundColor: _getStatusColor(order['status'] ?? 'PENDING'),
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                            ),
                                          ),
                                        ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 16),

            // Pagination
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
                  child: Text("Trang $_currentPage / ${((filteredOrders.length - 1) / _itemsPerPage).ceil()}"),
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
}