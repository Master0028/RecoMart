import 'package:go_router/go_router.dart';

import '../Screens/Customer/Login/Login.dart';
import '../Screens/Customer/Login/Intro.dart';
import '../Screens/Customer/Login/CreateAccountScreen.dart';
// import '../Screens/Customer/Login/Login.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'intro',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const CreateAccountScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
  ],
);