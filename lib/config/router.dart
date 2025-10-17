import 'package:go_router/go_router.dart';
import 'package:recomart/Screens/Customer/Home/CategoriesFilter.dart';
import 'package:recomart/Screens/Customer/Home/FavouriteList.dart';
import 'package:recomart/Screens/Customer/Home/FlashSale.dart';
import 'package:recomart/Screens/Customer/Home/Home.dart';
import 'package:recomart/Screens/Customer/Home/Livestream.dart';
import 'package:recomart/Screens/Customer/Home/ProductSale.dart';
import 'package:recomart/Screens/Customer/Home/ProductVariations.dart';
import 'package:recomart/Screens/Customer/Home/RecentlyViewed.dart';
import 'package:recomart/Screens/Customer/Home/RecognizingImagine.dart';
import 'package:recomart/Screens/Customer/Home/Review.dart';
import 'package:recomart/Screens/Customer/Home/SearchImage.dart';
import 'package:recomart/Screens/Customer/Home/ShopClothing.dart';
import 'package:recomart/Screens/Customer/Login/CreateAccountScreen.dart';
import 'package:recomart/Screens/Customer/Login/EmailOptions.dart';
import 'package:recomart/Screens/Customer/Login/Login.dart';
import 'package:recomart/Screens/Customer/Login/Intro.dart';
import 'package:recomart/Screens/Customer/Login/PasswordRecoveryMethod.dart';
import 'package:recomart/Screens/Customer/Login/PreparePassword.dart';
import 'package:recomart/Screens/Customer/Login/RecoverySMSCodeScreen.dart';
import 'package:recomart/Screens/Customer/Login/SetUpNewPasswordScreen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/', 
  routes: [
    //Login
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/create-account',
      builder: (context, state) => const CreateAccountScreen(),
    ),
    GoRoute(
      path: '/password-verify',
      builder: (context, state) => const PasswordVerifyScreen(),
    ),
    GoRoute(
      path: '/recovery-method',
      builder: (context, state) => const RecoveryMethodScreen(),
    ),
    GoRoute(
      path: '/recovery-sms',
      builder: (context, state) => const RecoveryCodeScreen(),
    ),
    GoRoute(
      path: '/recovery-email',
      builder: (context, state) => const RecoveryEmailCodeScreen(),
    ),
    GoRoute(
      path:  '/setup-newpass',
      builder: (context, state) => const SetupNewPasswordScreen(),
    ),

    //Home
    GoRoute(
      path:  '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path:  '/flash-sale',
      builder: (context, state) => const FlashSaleScreen(),
    ),
    GoRoute(
      path:  '/live-stream',
      builder: (context, state) => const LiveStreamScreen(),
    ),
    GoRoute(
      path:  '/shopping-cloth',
      builder: (context, state) => const ShopScreen(),
    ),
    GoRoute(
      path:  '/categories-filter',
      builder: (context, state) => const FilterScreen(),
    ),
    GoRoute(
      path:  '/search-image',
      builder: (context, state) => const ImageSearchScreen(),
    ),
    GoRoute(
      path:  '/recognizing-imagine',
      builder: (context, state) => const ImageRecognitionScreen(),
    ),
    GoRoute(
      path:  '/product-variations',
      builder: (context, state) => const ProductVariationsScreen(),
    ),
    GoRoute(
      path:  '/product-sales',
      builder: (context, state) => const ProductSaleDetailScreen(),
    ),
    GoRoute(
      path:  '/reviews', 
      builder: (context, state) => const ReviewScreen(),
    ),
    GoRoute(
      path:  '/recently-viewed', 
      builder: (context, state) => const RecentlyViewedScreen(),
    ),
    //BottomNavigationBar
    GoRoute(
    path: '/favorite-list', 
    builder: (context, state) => const WishlistScreen(),
  ),
  ],
);