import 'package:flutter/material.dart';
import 'routes/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // File được tạo bởi flutterfire configure

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'RecoMart App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'RobotoMono',
      ),
      routerConfig: appRouter, // sử dụng GoRouter
    );
  }
}