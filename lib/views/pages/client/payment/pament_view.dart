import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recomart/components/custom/snackbar.dart';
import 'package:recomart/config/color.dart'; 
import 'package:recomart/helpers/formatMoney.dart';
import 'package:recomart/utils/responsive.dart';
import 'package:recomart/utils/widget/CustomAppBarMobile.dart';
import 'package:recomart/utils/widget/footer.dart';
import 'package:recomart/views/pages/client/login/widgets/button.dart';
import 'package:recomart/views/pages/client/payment/widgets/order_summary.dart';
import 'package:recomart/views/pages/client/payment/widgets/payment_details.dart';
import 'package:feather_icons/feather_icons.dart';

class OrderItemModelFE {
  final String productVariantName;
  final int quantity;
  final double unitPrice;
  final double discount;
  final String imageUrl;

  OrderItemModelFE({
    required this.productVariantName,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
    required this.imageUrl,
  });
}

final List<OrderItemModelFE> FE_CART_ITEMS = [
  OrderItemModelFE(productVariantName: 'Laptop X1 Carbon', quantity: 1, unitPrice: 25000000, discount: 0, imageUrl: 'url_1'),
  OrderItemModelFE(productVariantName: 'Mouse Logitech', quantity: 2, unitPrice: 800000, discount: 0, imageUrl: 'url_2'),
];
const double FE_SUB_TOTAL_PRICE = 26600000;


class PaymentView extends StatefulWidget {
  const PaymentView({super.key});

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  String _currentLocation = 'District 1, HCM'; 
  
  bool isLoading = false;
  
  String email = 'example@gmail.com'; 
  String name = 'User Giao Diện';
  String address = 'District 1, HCM';
  String paymentMethod = 'BANK_TRANSFER';
  String shippingMethod = 'Express delivery';
  double currentPoint = 500;
  double totalAmountFinal = 0;
  double voucherDiscountMoney = 50000;

  Future<void> handleCreateOrder() async {
    if (name.isEmpty || email.isEmpty || address.isEmpty) {
      if (mounted) showCustomSnackBar(context, 'Please fill in all fields (FE Check)');
      return;
    }

    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    const bool isExistUser = true; 

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  FeatherIcons.checkCircle,
                  color: AppColors.primary,
                  size: 80,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Order Success! (FE Only)',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your order has been placed successfully. (FE Only)',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                isExistUser
                    ? MyButton(
                        text: 'View Order',
                        onTap: (_) {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushReplacementNamed('order-view');
                        },
                      )
                    
                    // ignore: dead_code
                    : Column(
                        children: [
                          const Text(
                            'Please sign in to track your order status.',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          MyButton(
                            text: 'Sign In',
                            onTap: (_) {
                              Navigator.of(context).pop();
                              // Navigator.of(context).pushReplacementNamed('login');
                            },
                          ),
                        ],
                      ),
                const SizedBox(height: 10),
                MyButton(
                  text: 'Back to Home',
                  variantIsOutline: true,
                  onTap: (_) {
                    //Navigator.of(context).pop();
                    context.push('/home');
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      address = _currentLocation;
      _calculateInitialTotalPrice(); 
    });
  }
  
  void _calculateInitialTotalPrice() {
      double totalAmount = FE_SUB_TOTAL_PRICE;

      double maxDiscountFromPoints = totalAmount * 0.5;
      double pointsToUse = currentPoint * 1000 <= maxDiscountFromPoints
          ? currentPoint.floorToDouble()
          : (maxDiscountFromPoints / 1000).floorToDouble();

      double vatPrice = (totalAmount * 0.1).floorToDouble();

      double totalPrice = (totalAmount +
                  (shippingMethod == "Pickup at store" ? 0 : 49000) +
                  vatPrice -
                  pointsToUse * 1000)
              .floorToDouble() -
          voucherDiscountMoney;

      setState(() {
          totalAmountFinal = totalPrice;
      });
  }


  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    final currentLocation = address;
    final cartItems = FE_CART_ITEMS; 
    final totalAmount = FE_SUB_TOTAL_PRICE;
    final isCartLoading = false;

    return Scaffold(
      backgroundColor: Colors.grey.shade50, 
      appBar: CustomAppBarMobile(title: 'Payment', isBack: true),
      body: SafeArea(
        child: Container(
            color: Colors.grey.shade50, 
            child: SingleChildScrollView(
              child: Column(
                children: [
                  isMobile
                      ? Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Order Summary Card
                              _buildModernCard(
                                child: OrderSummary(
                                  // Sử dụng model/data FE
                                  cartItems: cartItems, 
                                  isLoading: isCartLoading,
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Payment Details Card
                              _buildModernCard(
                                child: PaymentDetails(
                                  totalAmount: totalAmount,
                                  address: currentLocation,
                                  name: name,
                                  email: email,
                                  shippingMethod: shippingMethod,
                                  currentPoint: currentPoint,
                                  voucherDiscountMoney:
                                      voucherDiscountMoney,
                                  // Chỉ giữ lại setState (FE logic)
                                  onUpdateTotalPrice: (totalPrice) {
                                    setState(() {
                                      totalAmountFinal = totalPrice;
                                    });
                                  },
                                  onChangeValue: ({
                                    required String name,
                                    required String address,
                                    required String email,
                                    required String paymentMethod,
                                  }) {
                                    setState(() {
                                      this.name = name;
                                      this.address = address;
                                      this.email = email;
                                      this.paymentMethod = paymentMethod;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 64, vertical: 24),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: _buildModernCard(
                                  child: OrderSummary(
                                    // Sử dụng model/data FE
                                    cartItems: cartItems,
                                    isLoading: isCartLoading,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 40),
                              Expanded(
                                flex: 1,
                                child: _buildModernCard(
                                  child: PaymentDetails(
                                    totalAmount: totalAmount,
                                    address: currentLocation,
                                    name: name,
                                    email: email,
                                    shippingMethod: shippingMethod,
                                    currentPoint: currentPoint,
                                    voucherDiscountMoney:
                                        voucherDiscountMoney,
                                    handleCreateOrder: () {
                                      handleCreateOrder(); // Gọi hàm rỗng FE
                                    },
                                    onUpdateTotalPrice: (totalPrice) {
                                      setState(() {
                                        totalAmountFinal = totalPrice;
                                      });
                                    },
                                    onChangeValue: ({
                                      required String name,
                                      required String address,
                                      required String email,
                                      required String paymentMethod,
                                    }) {
                                      setState(() {
                                        this.name = name;
                                        this.address = address;
                                        this.email = email;
                                        this.paymentMethod =
                                            paymentMethod;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                  const SizedBox(height: 40),
                  if (!isMobile) FooterWidget()
                ],
              ),
            ),
          ),
      ),
      bottomNavigationBar: isMobile
          ? Container(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, bottom: 32, top: 20), 
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2), 
                    blurRadius: 15,
                    offset: const Offset(0, -5),
                  ),
                ],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        formatMoney(totalAmountFinal),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary, 
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 50, 
                    width: 150, 
                    child: MyButton(
                        text: 'Order Now',
                        fontSize: 16,
                        isLoading: isLoading,
                        onTap: (_) {
                          handleCreateOrder();
                        }),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

Widget _buildModernCard({required Widget child}) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20), 
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: child,
  );
}