import 'package:flutter/material.dart';
import 'package:recomart/config/color.dart'; 
import 'package:recomart/utils/responsive.dart';

class OrderView extends StatefulWidget {
  const OrderView({super.key});

  @override
  State<OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<dynamic> orders = []; 
  bool isLoading = false; 

  void initializeView() {
    setState(() {
      isLoading = false;
      orders = []; 
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    initializeView(); 
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildEmptyState(String message) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined, 
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

  Widget buildOrderView(List<dynamic> orders, String state) {
    if (isLoading) {
      return _buildEmptyState('Loading orders...');
    }
    
    final List<dynamic> filteredOrders = []; 

    if (filteredOrders.isEmpty) {
      String message = "No orders in this status.";
      if (state == 'PENDING') message = "No pending orders.";
      if (state == 'SHIPPING') message = "No shipping orders.";
      if (state == 'CANCELLED') message = "No cancelled orders.";
      return _buildEmptyState(message);
    }

    if (Responsive.isMobile(context)) {
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: filteredOrders.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16), 
        itemBuilder: (context, index) {
          // THAY THẾ OrderItem() bằng Container
          return Container(height: 100, color: Colors.blue[100], child: Center(child: Text("Mobile Item: $state #${index+1}"))); 
        },
      );
    }

    return Center(
      child: Container(
        color: Colors.grey[100], 
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: 900), 
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20), 
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1), 
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Center(child: Text("Desktop View: $state List", style: TextStyle(fontSize: 18))),
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
                elevation: 0, 
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
                    fontWeight: FontWeight.bold, 
                  ),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white, 
                  indicatorWeight: 4, 
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
          color: Responsive.isMobile(context) ? Colors.white : Colors.grey[100], 
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