import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:recomart/components/custom/bottom_navigation_bar.dart';
import 'package:recomart/models/order.model.dart';
import 'package:recomart/views/pages/admin/admin_screen.dart';
import 'package:recomart/views/pages/client/login/changepassword.dart';
import 'package:recomart/views/pages/client/login/passwordrecoverymethods.dart';
import 'package:recomart/views/pages/client/login/signup_screen.dart';
import 'package:recomart/views/pages/client/login/verifyemail_view.dart';
import 'package:recomart/views/pages/client/order/order_details.dart';
import 'package:recomart/views/pages/client/order/order_list.dart';
import 'package:recomart/views/pages/client/profile/module/address.dart';
import 'package:recomart/views/pages/client/profile/module/atm.dart';
import 'package:recomart/views/pages/client/profile/module/epay.dart';
import 'package:recomart/views/pages/client/profile/module/history.dart';
import 'package:recomart/views/pages/client/profile/module/personalinfor.dart';
import 'package:recomart/views/pages/client/profile/module/utilities.dart';
import 'package:recomart/views/pages/client/profile/widgets/support.dart';
import 'package:recomart/views/pages/client/search/search_screen.dart';
import 'package:recomart/views/pages/client/search/search_camera.dart';
import 'package:recomart/views/pages/client/splash/about_app.dart';
import 'package:recomart/views/pages/client/splash/help-support.dart';
import 'package:recomart/views/pages/client/welcome/welcome_view.dart';
import 'package:recomart/views/pages/client/chat/widgets/chat_view.dart';
import 'package:recomart/views/pages/client/cart/cart_view.dart';
import 'package:recomart/views/pages/client/login/login_view.dart';
import 'package:recomart/views/pages/client/login/newpass_view.dart';
import 'package:recomart/views/pages/client/login/verifyotp_view.dart';
import 'package:recomart/views/pages/client/product/product_details_view.dart';
import 'package:recomart/views/pages/client/product/product_page_view.dart';
import 'package:recomart/views/pages/client/profile/profile_view.dart';
import 'package:recomart/views/pages/client/splash/splash_view.dart';

import '../views/pages/client/order/ordercheckout.dart';
import '../views/pages/client/profile/module/orderdetail.dart';


final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashView(),
    ),

    GoRoute(
      path: '/intro',
      builder: (context, state) => const IntroScreen(),
    ),

    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginView(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpScreen(),
    ),

    GoRoute(
      path: '/recovery',
      builder: (context, state) {
        return const RecoveryMethodScreen();
      },
    ),

    GoRoute(
      path: '/setup-pass',
      builder: (context, state) => const SetupNewPasswordScreen(userId: '',),
    ),

    GoRoute(
      path: '/verify-email',
      builder: (context, state) => const VerifyEmailView(),
    ),
    // GoRoute(
    //   path: '/input-otp',
    //   builder: (context, state) => const VerifyOtpView(userId: null, obscuredEmail: null,),
    // ),
    GoRoute(
      path: '/verify-otp',
      builder: (context, state){
        final email = state.uri.queryParameters['email'];
        final extraData = state.extra as Map<String, dynamic>? ?? {}; 
        
        return VerifyOtpView(
          email: email,
          userId: extraData['userId'],
          obscuredEmail: extraData['obscuredEmail'],
        );
      },
    ),
    GoRoute(
      path: '/change-password',
      builder: (context, state) => const ChangePasswordApp(),
    ),

    GoRoute(
      path: '/home',
      builder: (context, state) => const BottomNavigationBarCustom(),
    ),

    //Profile
    GoRoute(
      path: '/personal-information',
      builder: (context, state) => const PersonelInformationPage(),
    ),

    GoRoute(
      path: '/address',
      builder: (context, state) => const AddressPage(),
    ),
    
    GoRoute(
      path: '/utilities',
      builder: (context, state) => const MyUtilitiesPage(),
    ),

    GoRoute(
      path: '/support',
      builder: (context, state) => const SupportChatScreen(),
    ),

    GoRoute(
      path: '/atm',
      builder: (context, state) => const PaymentMethodsScreen(),
    ),

    GoRoute(
      path: '/e-wallets',
      builder: (context, state) => const EWalletPage(),
    ),
    
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductPageView(),
    ),

    GoRoute(
      // Bên ProductView đang là: '/product-detail/$id'
      path: '/product-detail/:id', 
      
      builder: (context, state) {
        // Lấy ID từ đường dẫn
        final productId = state.pathParameters['id'] ?? '';
        
        final extra = state.extra as Map<String, dynamic>?;
        final categoryId = extra?['categoryId'] ?? ''; 
        
        return ProductDetailsView(
          productId: productId,
          categoryId: categoryId,
        );
      },
    ),

    GoRoute(
      path: '/product-page-view/:categoryId', // Định nghĩa tham số :categoryId
      builder: (context, state) {
        final categoryId = state.pathParameters['categoryId'];
        
        return ProductPageView(
          categoryId: categoryId,
        );
      },
    ),

    GoRoute(
      path: '/orders/:id',
      builder: (context, state) {
        final orderId = state.pathParameters['id']!;
        return OrderDetailPage(orderId: orderId);
      },
    ),

    GoRoute(
      path: '/search',
      builder: (context, state) {
        final recentSearches = state.extra as List<String>? ?? [];
        return SearchScreen(recentSearches: recentSearches);
      },
    ),
    GoRoute(
      path: '/search-camera',
      builder: (context, state) => const SearchCameraPage(),
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartView(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileView(),
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) => const ChatView(),
    ),

    GoRoute(
      path: '/help-support',
      builder: (context, state) => const HelpCenterScreen(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutRecoMartScreen(),
    ),

    GoRoute(
      path: '/history',
      builder: (context, state) {
        final String id = state.extra as String? ?? ''; 
        return OrderHistoryPage(userId: id);
      },
    ),

    GoRoute(
      path: '/checkout',
      name: 'checkout',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;

        return OrderCheckoutPage(
          productId: extra?['productId'],
          productName: extra?['productName'],
          imageUrl: extra?['imageUrl'],
          unitPrice: extra?['unitPrice'],
          quantity: extra?['quantity'],
          discount: extra?['discount'],
        );
      },
    ),

    GoRoute(
    path: '/history',
    builder: (context, state) {
      //final userId = state.extra as String;
      return const OrderListScreen();
    },
  ),

  GoRoute(
    path: '/order-detail',
    builder: (context, state) {
      final order = state.extra as OrderModel;
      return OrderDetailScreen(order: order, orderId: '',);
    },
  ),

  GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminScreen(),
    ),
  ],
  
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Lỗi')),
    body: Center(child: Text('Không tìm thấy trang: ${state.uri}')),
  ),
);
