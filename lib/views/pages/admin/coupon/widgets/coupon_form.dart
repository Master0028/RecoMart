import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../../../../../provider/coupon_provider.dart';
import '../../../../../models/coupon.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CouponForm extends StatefulWidget {
  final void Function(Map<String, dynamic>) onSubmit;
  final String buttonLabel;
  final CouponModel? initialCoupon;

  const CouponForm({
    super.key,
    required this.onSubmit,
    required this.buttonLabel,
    this.initialCoupon,
  });

  @override
  State<CouponForm> createState() => _CouponFormState();
}

class _CouponFormState extends State<CouponForm> {
  late TextEditingController codeController;
  late TextEditingController discountController;
  late TextEditingController usageLimitController;
  late bool isActive;
  bool _localIsLoading = false;

  @override
  void initState() {
    super.initState();
    final data = widget.initialCoupon;
    codeController = TextEditingController(
      text: data?.code ?? _generateRandomCode(),
    );
    discountController = TextEditingController(
      text: data?.discountValue.toString() ?? '0',
    );
    usageLimitController = TextEditingController(
      text: data?.maxUsage.toString() ?? '1',
    );
  }

  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(6, (index) => chars[Random().nextInt(chars.length)]).join();
  }

  bool _isValidCode(String code) {
    return RegExp(r'^[A-Z0-9]{5,6}$').hasMatch(code);
  }

  String? _validateDiscount(String value) {
    final numValue = double.tryParse(value);
    if (numValue == null) return 'Discount must be a number';
    if (numValue <= 0) return 'Must be greater than 0';
    return null;
  }

  String? _validateUsageLimit(String value) {
    final intValue = int.tryParse(value);
    if (intValue == null) return 'Usage limit must be an integer';
    if (intValue < 1) return 'At least 1';
    if (intValue > 1000) return 'Cannot exceed 1000';
    return null;
  }

  /// ✅ Gửi dữ liệu lên Firestore (Tạo hoặc Cập nhật)
  Future<void> _handleSubmit() async {
    if (!_isValidCode(codeController.text) ||
        _validateDiscount(discountController.text) != null ||
        _validateUsageLimit(usageLimitController.text) != null) {
      return;
    }

    setState(() => _localIsLoading = true);

    try {
      final provider = Provider.of<CouponProvider>(context, listen: false);

      // 🔹 Nếu đang chỉnh sửa → cập nhật
      if (widget.initialCoupon != null && widget.initialCoupon!.id != null) {
        final updatedCoupon = CouponModel(
          id: widget.initialCoupon!.id,
          code: codeController.text.trim(),
          discountValue: double.parse(discountController.text),
          maxUsage: int.parse(usageLimitController.text),
          usedCount: widget.initialCoupon?.usedCount ?? 0,
          createdAt: widget.initialCoupon!.createdAt,
          appliedOrders:
          List<String>.from(widget.initialCoupon?.appliedOrders ?? []),
        );

        await provider.updateCoupon(updatedCoupon);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Coupon updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // 🔹 Nếu tạo mới
        final newCoupon = CouponModel(
          id: '',
          code: codeController.text.trim(),
          discountValue: double.parse(discountController.text),
          maxUsage: int.parse(usageLimitController.text),
          usedCount: 0,
          createdAt: Timestamp.now(),
          appliedOrders: [],
        );

        await provider.addCoupon(newCoupon);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Coupon created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving coupon: $e')),
      );
    } finally {
      setState(() => _localIsLoading = false);
    }
  }

  /// ✅ Xóa coupon
  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this coupon?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final provider = Provider.of<CouponProvider>(context, listen: false);
        await provider.deleteCoupon(widget.initialCoupon!.id);
        if (mounted) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Coupon deleted successfully!'),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting coupon: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final bool isButtonDisabled = _localIsLoading ||
        !_isValidCode(codeController.text) ||
        _validateDiscount(discountController.text) != null ||
        _validateUsageLimit(usageLimitController.text) != null;

    return SizedBox(
      width: 400,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: codeController,
              decoration: InputDecoration(
                labelText: 'Coupon Code',
                border: const OutlineInputBorder(),
                errorText: !_isValidCode(codeController.text)
                    ? 'Code must be 5–6 uppercase letters/numbers'
                    : null,
              ),
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: discountController,
              decoration: InputDecoration(
                labelText: 'Discount Amount',
                border: const OutlineInputBorder(),
                suffixText: 'đ',
                errorText: _validateDiscount(discountController.text),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 20),
            Text(
              'Created At: ${DateFormat('dd/MM/yyyy HH:mm').format(_parseDate(widget.initialCoupon?.createdAt))}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: usageLimitController,
              decoration: InputDecoration(
                labelText: 'Usage Limit',
                border: const OutlineInputBorder(),
                errorText: _validateUsageLimit(usageLimitController.text),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 20),
            Text(
              'Applied Orders: ${widget.initialCoupon?.appliedOrders?.join(', ') ?? 'None'}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            // ✅ Nút thao tác
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: isButtonDisabled ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: _localIsLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(widget.buttonLabel, style: const TextStyle(color: Colors.white)),
                  ),
                  if (widget.initialCoupon != null) ...[
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.delete),
                      label: const Text("Delete"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: _localIsLoading ? null : _handleDelete,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
