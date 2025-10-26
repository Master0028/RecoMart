import 'package:recomart/config/color.dart';
import 'package:recomart/models/order.model.dart';
import 'package:recomart/services/order.service.dart';
import 'package:flutter/material.dart';
import 'package:recomart/utils/responsive.dart';
import 'package:recomart/views/pages/client/order/widget/order_item.dart';
import 'package:recomart/views/pages/client/order/widget/timeline_list.dart';

class OrderView extends StatefulWidget {
  const OrderView({super.key});

  @override
  State<OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  OrderService orderService = OrderService();

  List<OrderModel> orders = [];
  bool isLoading = true; // Thêm trạng thái loading

  Future<void> fetchOrders() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Giả lập độ trễ mạng
      await Future.delayed(const Duration(milliseconds: 500)); 
      final response = await orderService.getOrdersById();
      setState(() {
        orders = response;
      });
    } catch (e) {
      // Handle error (có thể hiển thị Snackbar hoặc thông báo lỗi)
      print('Error fetching orders: $e'); 
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Widget hiển thị khi không có đơn hàng hoặc đang tải
  Widget _buildEmptyState(String message) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined, // Icon hiện đại hơn
            size: 80,
            color: AppColors.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18, 
              color: Colors.black54, 
              fontWeight: FontWeight.w600
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOrderView(List<OrderModel> orders, String state) {
    if (isLoading) {
      return _buildEmptyState('Loading orders...');
    }
    
    final filteredOrders =
        orders.where((order) => order.status == state).toList();

    if (filteredOrders.isEmpty) {
      String message = "No orders in this status.";
      if (state == 'PENDING') message = "No pending orders.";
      if (state == 'SHIPPING') message = "No shipping orders.";
      if (state == 'CANCELLED') message = "No cancelled orders.";
      return _buildEmptyState(message);
    }

    // Giao diện Mobile (List View)
    if (Responsive.isMobile(context)) {
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: filteredOrders.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16), // Tăng khoảng cách
        itemBuilder: (context, index) {
          // Giả định OrderItem được thiết kế hiện đại (bo góc, shadow nhẹ)
          return OrderItem(order: filteredOrders[index], state: state); 
        },
      );
    }

    // Giao diện Desktop/Tablet (Constrained Card View)
    return Center(
      child: Container(
        color: Colors.grey[100], // Nền xám nhạt hiện đại
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: 900), // Giới hạn chiều rộng lớn hơn
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20), // Bo góc lớn hơn
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1), // Bóng xanh dương nhẹ
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            // Sử dụng TimelineList cho Desktop/Tablet
            child: TimelineList(orders: filteredOrders, state: state), 
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: Responsive.isMobile(context)
            ? AppBar(
                backgroundColor: AppColors.primary,
                elevation: 0, // Loại bỏ elevation cho phong cách phẳng
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                title: const Text(
                  'Order Management',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold, // Tăng độ đậm
                  ),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  // Cải thiện TabBar style
                  indicatorColor: Colors.white, // Màu xanh dương/trắng cho indicator
                  indicatorWeight: 4, // Độ dày indicator
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(0.7),
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  tabs: const [
                    Tab(text: 'Pending'),
                    Tab(text: 'Shipping'),
                    Tab(text: 'Cancelled'),
                  ],
                ),
              )
            : null,
        body: Container(
          color: Responsive.isMobile(context) ? Colors.white : Colors.grey[100], // Nền xám nhạt cho desktop
          height: MediaQuery.of(context).size.height,
          child: TabBarView(
            controller: _tabController,
            children: [
              buildOrderView(orders, 'PENDING'),
              buildOrderView(orders, 'SHIPPING'),
              buildOrderView(orders, 'CANCELLED'),
            ],
          ),
        ),
      ),
    );
  }
}