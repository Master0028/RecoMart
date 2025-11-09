import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:recomart/components/custom/bottom_navigation_bar.dart';
import 'package:recomart/views/pages/admin/admin_screen.dart';
import 'package:recomart/views/pages/client/login/changepassword.dart';
import 'package:recomart/views/pages/client/login/passwordrecoverymethods.dart';
import 'package:recomart/views/pages/client/login/signup_screen.dart';
import 'package:recomart/views/pages/client/login/verifyemail_view.dart';
import 'package:recomart/views/pages/client/order/order_view.dart';
import 'package:recomart/views/pages/client/profile/module/address.dart';
import 'package:recomart/views/pages/client/profile/module/personalinfor.dart';
import 'package:recomart/views/pages/client/profile/module/utilities.dart';
import 'package:recomart/views/pages/client/profile/widgets/support.dart';
import 'package:recomart/views/pages/client/search/search_screen.dart';
import 'package:recomart/views/pages/client/search/search_camera.dart';
import 'package:recomart/views/pages/client/welcome/welcome_view.dart';
import 'package:recomart/views/pages/client/chat/widgets/chat_view.dart';
import 'package:recomart/views/pages/client/cart/cart_view.dart';
import 'package:recomart/views/pages/client/login/login_view.dart';
import 'package:recomart/views/pages/client/login/newpass_view.dart';
import 'package:recomart/views/pages/client/login/verifyotp_view.dart';
import 'package:recomart/views/pages/client/payment/pament_view.dart';
import 'package:recomart/views/pages/client/product/product_details_view.dart';
import 'package:recomart/views/pages/client/product/product_page_view.dart';
import 'package:recomart/views/pages/client/profile/profile_view.dart';
import 'package:recomart/views/pages/client/splash/splash_view.dart';
import 'package:recomart/views/pages/client/voucher/voucher_view.dart';

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
      builder: (context, state) => const PersonelInformationPage(userInfo: {},),
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
      builder: (context, state) => const SupportAccount(),
    ),
    
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductPageView(),
    ),

    GoRoute(
      path: '/product-details/:productId',
      builder: (context, state) {
        final productId = state.pathParameters['productId'] ?? '';
        final categoryId = state.uri.queryParameters['categoryId'] ?? '';
        
        return ProductDetailsView(
          productId: productId,
          categoryId: categoryId,
        );
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
      path: '/orders',
      builder: (context, state) => const OrderView(),
    ),
    GoRoute(
      path: '/payment',
      builder: (context, state) => const PaymentView(),
    ),
    GoRoute(
      path: '/voucher',
      builder: (context, state) => const VoucherView(),
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
      path: '/admin',
      builder: (context, state) => const AdminScreen(),
    ),
  ],
  
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Lỗi')),
    body: Center(child: Text('Không tìm thấy trang: ${state.uri}')),
  ),
);
