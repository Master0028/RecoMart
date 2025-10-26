import 'package:recomart/views/pages/client/home/widgets/appBar_widget.dart';
import 'package:recomart/views/pages/client/home/widgets/home_body.dart';
import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarHomeCustom(),
      body: const HomeBody(),
    );
  }
}
