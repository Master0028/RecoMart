import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const Color _primaryColor = Colors.blue; 
const Color _secondaryColor = Colors.orange;

class Responsive {
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1000;
  }
}

class _MockLocationWidget extends StatelessWidget {
  const _MockLocationWidget();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Icon(Icons.location_on, color: _primaryColor, size: 20),
          SizedBox(width: 4),
          Text(
            'Phường A, Quận B, TP HCM',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

class _MockHeaderView extends StatelessWidget {
  const _MockHeaderView();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Text('Desktop Nav: Search | Cart | Noti', style: TextStyle(color: Colors.black54)),
    );
  }
}

class _MockAvatarWidget extends StatelessWidget {
  final String userName;
  final String? userId;

  const _MockAvatarWidget({required this.userName, this.userId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 15,
            backgroundColor: _secondaryColor,
            child: Text('G', style: TextStyle(color: Colors.white, fontSize: 14)),
          ),
          const SizedBox(width: 8),
          Text(userName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}


class AppBarHomeCustom extends StatelessWidget implements PreferredSizeWidget {
  const AppBarHomeCustom({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    const String defaultUserName = 'Guest'; 

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: Responsive.isDesktop(context) ? 90 : preferredSize.height,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Responsive.isDesktop(context)
              ? Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/logo/logo.png'),
                      const Icon(Icons.shopping_bag_outlined, color: _primaryColor, size: 30), 
                      const SizedBox(width: 5),
                      const Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Reco',
                              style: TextStyle(color: _primaryColor),
                            ),
                            TextSpan(
                              text: 'Mart',
                              style: TextStyle(color: _secondaryColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : const _MockLocationWidget(), // LocationWidget cũ
          
          Responsive.isDesktop(context)
              ? const Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _MockHeaderView(), // HeaderView cũ
                    ],
                  ),
                )
              : const SizedBox(),
        ],
      ),
      actions: [
        // Logic FE: Hiển thị Avatar
        Padding(
          padding: Responsive.isDesktop(context)
              ? const EdgeInsets.only(right: 32)
              : EdgeInsets.zero,
          child: const _MockAvatarWidget(
            userName: defaultUserName, // Dùng giá trị tĩnh thay vì userProvider
            userId: null,
          ),
        ),
      ],
    );
  }
}
