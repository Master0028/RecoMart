import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recomart/provider/user_provider.dart';
import 'package:recomart/views/pages/admin/customer/widgets/customer_table.dart';
import '../../../../models/user.model.dart';

class CustomerManagementScreen extends StatefulWidget {
  const CustomerManagementScreen({super.key});

  @override
  State<CustomerManagementScreen> createState() =>
      _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<UserProvider>(context, listen: false).fetchUsers());
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final List<UserModel> customers = userProvider.users;

    return Container(
      color: Colors.grey[100],
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      child: userProvider.loading
          ? const Center(child: CircularProgressIndicator())
          : userProvider.error != null
              ? Center(child: Text('Error: ${userProvider.error}')) // Translated
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      customers.isEmpty
                          ? const Center(child: Text('No customers available')) // Translated
                          : CustomerTable(customers: customers),
                    ],
                  ),
                ),
    );
  }
}