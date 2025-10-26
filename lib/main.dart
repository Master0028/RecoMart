import 'package:recomart/models/brand.model.dart';
import 'package:recomart/models/category.model.dart';
import 'package:recomart/models/product.model.dart';
import 'package:recomart/provider/brand_provider.dart';
import 'package:recomart/provider/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recomart/provider/cart_provider.dart';
import 'package:recomart/provider/product_provider.dart';
import 'package:recomart/provider/user_provider.dart';
import 'package:recomart/provider/coupon_provider.dart';
import 'package:recomart/routes/app_routes.dart';
import 'package:recomart/test/mockdatatest.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => BrandProvider()),
        ChangeNotifierProvider(create: (_) => CouponProvider())
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // Thay thế initialRoute, routes, và onGenerateRoute
      routerConfig: appRouter, 

      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
    );
  }
}