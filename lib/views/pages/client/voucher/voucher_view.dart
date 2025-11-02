import 'package:flutter/material.dart';
import 'package:recomart/components/custom/my_text_field.dart';
import 'package:recomart/components/custom/snackbar.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/helpers/formatMoney.dart';
import 'package:recomart/utils/widget/CustomAppBarMobile.dart';
import 'package:feather_icons/feather_icons.dart';

class VoucherView extends StatefulWidget {
  const VoucherView({super.key});

  @override
  State<VoucherView> createState() => _VoucherViewState();
}

class _VoucherViewState extends State<VoucherView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
    });
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, 
      appBar: CustomAppBarMobile(
        title: 'Voucher Hub', 
        isBack: true,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1), 
              borderRadius: BorderRadius.circular(30), 
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTabButton(0, 'Enter Code', FeatherIcons.tag),
                _buildTabButton(1, 'My Wallet', FeatherIcons.gift),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: 2,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: index == 0 ? EnterVoucherCode() : const VoucherWidget(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int page, String text, IconData icon) {
    final isSelected = _currentPage == page;
    return Expanded(
      child: ElevatedButton(
        onPressed: () => _goToPage(page),
        style: ElevatedButton.styleFrom(
          elevation: isSelected ? 5 : 0, 
          backgroundColor: isSelected
              ? AppColors.primary 
              : Colors.transparent, 
          shadowColor: AppColors.primary.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25), 
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.primary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VoucherWidget extends StatelessWidget {
  const VoucherWidget({
    super.key,
  });

  void _handleApply(BuildContext context) {
      print('Apply voucher clicked');
      final appliedDiscount = 75000.0;
      
      Navigator.pop(context, appliedDiscount); 
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        final Color accentColor = AppColors.secondary; 
        
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16), 
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), 
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              // Phần trái: Giá trị và điểm nhấn (FE logic)
              Container(
                width: 100,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary, 
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(FeatherIcons.star, color: Colors.white, size: 28),
                    const SizedBox(height: 4),
                    Text(
                      formatMoney(50000 + index * 10000), // Giá trị hiển thị FE
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Phần phải: Chi tiết Voucher (FE logic)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'VOUCHER_FE_${index + 1}',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.w900, 
                              letterSpacing: 1.0, 
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: AppColors.green, width: 1),
                            ),
                            child: const Text(
                              'Active',
                              style: TextStyle(
                                color: AppColors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Minimum order ${formatMoney(500000)}',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Expires: Today',
                            style: TextStyle(
                              color: Colors.black45,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          // Nút Apply
                          ElevatedButton(
                            onPressed: () => _handleApply(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor, 
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            child: const Text(
                              'Apply ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class EnterVoucherCode extends StatelessWidget {
  EnterVoucherCode({super.key});

  final TextEditingController controller = TextEditingController();

  void handleApplyCode(BuildContext context) {
    final discountAmount = 50000.0; 

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), 
          contentPadding: const EdgeInsets.all(24),
          elevation: 10,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FeatherIcons.checkCircle, 
                  color: AppColors.green, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Voucher Applied Successfully!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'You saved ${formatMoney(discountAmount)} on your order.',
                  style: TextStyle(fontSize: 16, color: AppColors.primary, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context, discountAmount); 
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                         padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), 
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Enter your promotional code:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          MyTextField(
            hintText: 'e.g., TECHSALE2024',
            prefixIcon: FeatherIcons.code, 
            controller: controller,
            obscureText: false,
          ),
          const SizedBox(height: 8),
          const Text(
            'You descreased your total by 50% (FE Stub)', 
            style: TextStyle(
              color: Colors.red,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isEmpty) {
                showCustomSnackBar(context, 'Please enter a voucher code');
                return;
              }
              handleApplyCode(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 5,
              shadowColor: AppColors.primary.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Apply Code',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}