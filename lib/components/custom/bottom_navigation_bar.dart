import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';

import 'package:recomart/config/color.dart';
import 'package:recomart/utils/widget/CustomAppBarMobile.dart';
import 'package:recomart/views/pages/client/Chat/widgets/chat_body.dart';
import 'package:recomart/views/pages/client/home/widgets/home_body.dart';
import 'package:recomart/views/pages/client/home/widgets/appBar_widget.dart';
import 'package:recomart/views/pages/client/product/product_page_body.dart' hide AppColors;
import 'package:recomart/views/pages/client/profile/widgets/profile_body.dart';

class Responsive {
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1000;
  }
}

class BottomNavigationBarCustom extends StatefulWidget {
  const BottomNavigationBarCustom({super.key});

  @override
  State<BottomNavigationBarCustom> createState() => _BottomNavigationBarCustomState();
}

class _BottomNavigationBarCustomState extends State<BottomNavigationBarCustom> {
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);

  final GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) runAddToCartAnimation;

  late final List<Map<String, dynamic>> _pages;

  final List<Map<String, dynamic>> icons = [
    {'icon': CupertinoIcons.square_grid_2x2, 'label': 'Home'},
    {'icon': CupertinoIcons.cube, 'label': 'Product'},
    {'icon': FeatherIcons.messageCircle, 'label': 'Message'},
    {'icon': CupertinoIcons.person, 'label': 'Profile'},
  ];

  @override
  void initState() {
    super.initState();
    _pages = [
      {
        'page': const HomeBody(),
        'appBar': AppBarHomeCustom(cartKey: cartKey),
      },
      {
        'page': const ProductPageBody(),
        'appBar': const CustomAppBarMobile(title: 'Product'),
      },
      {
        'page': const ChatBody(),
        'appBar': const CustomAppBarMobile(title: 'Message'),
      },
      {
        'page': const ProfileBody(),
        'appBar': const CustomAppBarMobile(title: 'Profile'),
      },
    ];
  }

  Widget customItemNavBar(IconData iconData, String label, int index, int currentIndex) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: currentIndex == index ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: Icon(iconData, size: 26),
        color: currentIndex == index ? AppColors.white : Colors.black,
        onPressed: () {
          _currentPage.value = index;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AddToCartAnimation(
      cartKey: cartKey,
      height: 30,
      width: 30,
      opacity: 0.85,
      dragAnimation: const DragToCartAnimationOptions(rotation: true),
      jumpAnimation: const JumpAnimationOptions(),
      createAddToCartAnimation: (runAddToCartAnimation) {
        this.runAddToCartAnimation = runAddToCartAnimation;
      },
      child: ValueListenableBuilder<int>(
        valueListenable: _currentPage,
        builder: (context, currentIndex, child) {
          bool isDesktop = Responsive.isDesktop(context);
          
          return Scaffold(
            appBar: _pages[currentIndex]['appBar'] as PreferredSizeWidget,
            body: currentIndex == 2 // Tab Chat
                ? DefaultTabController(
                    length: 3,
                    child: _pages[currentIndex]['page'] as Widget,
                  )
                : _pages[currentIndex]['page'] as Widget,
            
            bottomNavigationBar: !isDesktop
                ? Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: BottomAppBar(
                      color: Colors.white,
                      elevation: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(
                          icons.length,
                          (index) => customItemNavBar(
                            icons[index]['icon'] as IconData,
                            icons[index]['label'] as String,
                            index,
                            currentIndex,
                          ),
                        ).toList(),
                      ),
                    ),
                  )
                : const SizedBox(),
          );
        },
      ),
    );
  }
}