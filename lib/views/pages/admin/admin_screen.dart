import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/views/pages/admin/brand/brand_screen.dart';
import 'package:recomart/views/pages/admin/category/category_screen.dart';
import 'package:recomart/views/pages/admin/dashboard/dashboard_screen.dart';
import 'package:recomart/views/pages/admin/customer/customer_screen.dart';
import 'package:recomart/views/pages/admin/log_screen.dart'; 
import 'package:recomart/views/pages/admin/order/order_screen.dart';
import 'package:recomart/views/pages/admin/invoice/invoice_screen.dart';
import 'package:recomart/views/pages/admin/product/product_screen.dart';
import 'package:recomart/views/pages/admin/coupon/coupon_screen.dart';
import 'package:recomart/views/pages/admin/support/support_screen.dart';
import 'package:recomart/utils/responsive.dart';

class AdminSidebar extends StatelessWidget {
  final String selectedMenu;
  final Function(String) onMenuTap;

  const AdminSidebar({
    super.key,
    required this.selectedMenu,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final menuItems = {
      "Dashboard": FeatherIcons.grid,
      "Product": FeatherIcons.box,
      "Category": FeatherIcons.list,
      "Brand": FeatherIcons.tag,
      "Order": FeatherIcons.shoppingBag,
      "Invoice": FeatherIcons.fileText,
      "Customer": FeatherIcons.users,
      "Coupon": FeatherIcons.gift,
      "Support": FeatherIcons.messageCircle,
      "System Logs": FeatherIcons.activity,
      "Logout": FeatherIcons.logOut,
    };

    return Container(
      width: 280,
      color: const Color(0xFF1E293B),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            alignment: Alignment.centerLeft,
            child: const Text(
              'RECOMART ADMIN',
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const Divider(color: Color(0xFF334155), height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 10),
              children: menuItems.entries.map((entry) {
                final isSelected = entry.key == selectedMenu;
                final isLogout = entry.key == "Logout";
                final color = isLogout ? Colors.redAccent : const Color(0xFFCBD5E1);
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  child: Material(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () => onMenuTap(entry.key),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        child: Row(
                          children: [
                            Icon(
                              entry.value,
                              color: isSelected ? Colors.white : color,
                              size: 20,
                            ),
                            const SizedBox(width: 15),
                            Text(
                              entry.key,
                              style: TextStyle(
                                color: isSelected ? Colors.white : color,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  String _selectedMenu = "Dashboard";
  Widget _currentScreen = const DashboardScreen();
  bool _hideAppBar = false;

  @override
  void initState() {
    super.initState();
    _currentScreen = const DashboardScreen(); 
  }
  
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to log out?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              context.push('/login');
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  void _onMenuTap(String menu) {
    if (menu == "Logout") {
      _handleLogout();
      return;
    }

    setState(() {
      _selectedMenu = menu;
      _hideAppBar = false; 
      switch (menu) {
        case "Dashboard":
          _currentScreen = const DashboardScreen();
          break;
        case "Product":
          _currentScreen = const ProductManagementScreen();
          break;
        case "Category":
          _currentScreen = const CategoryManagementScreen();
          break;
        case "Brand":
          _currentScreen = const BrandManagementScreen();
          break;
        case "Customer":
          _currentScreen = const CustomerManagementScreen();
          break;
        case "Order":
          _currentScreen = const OrderManagementScreen();
          break;
        case "Invoice":
          _currentScreen = const InvoiceManagementScreen();
          break;
        case "Coupon":
          _currentScreen = const CouponManagementScreen();
          break;
        case "Support":
          _currentScreen = const SupportScreen();
          break;
        case "System Logs":
          _currentScreen = const LogViewerScreen();
          break;
        default:
          _currentScreen = const DashboardScreen();
      }
    });
  }
  
  PreferredSizeWidget _buildMobileAppBar() {
      return AppBar(
          title: const Text(
              "Admin Panel Dashboard",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
          ),
          backgroundColor: AppColors.primary,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: Responsive.isMobile(context) && !_hideAppBar
          ? _buildMobileAppBar()
          : null,
      
      drawer: Responsive.isMobile(context)
          ? Drawer(
              width: 250,
              child: AdminSidebar(
                selectedMenu: _selectedMenu,
                onMenuTap: (menu) {
                  Navigator.pop(context);
                  _onMenuTap(menu);
                },
              ),
            )
          : null,
          
      body: Responsive.isDesktop(context)
          ? Row(
              children: [
                AdminSidebar(
                  selectedMenu: _selectedMenu,
                  onMenuTap: _onMenuTap,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: _currentScreen,
                    ),
                  ),
                ),
              ],
            )
          : _currentScreen,
    );
  }
}