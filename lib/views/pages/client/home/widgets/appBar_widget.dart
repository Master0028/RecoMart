import 'package:recomart/provider/user_provider.dart';
import 'package:recomart/utils/responsive.dart';
import 'package:recomart/views/header/header_view.dart';
import 'package:recomart/views/pages/client/home/widgets/avatar_widget.dart';
import 'package:recomart/views/pages/client/home/widgets/location_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

const Color _primaryColor = Colors.blue; 
const Color _secondaryColor = Colors.orange;

class AppBarHomeCustom extends StatelessWidget implements PreferredSizeWidget {
  const AppBarHomeCustom({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      scrolledUnderElevation: 0,
      // Điều chỉnh chiều cao cho màn hình Desktop
      toolbarHeight: Responsive.isDesktop(context) ? 90 : preferredSize.height,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Responsive.isDesktop(context)
              ? Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/logo/logo.png',
                        width: 50,
                        height: 50,
                        colorFilter: const ColorFilter.mode(_primaryColor, BlendMode.srcIn),
                      ),
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
              : const LocationWidget(),
          Responsive.isDesktop(context)
              ? const Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      HeaderView(),
                    ],
                  ),
                )
              : const SizedBox(),
        ],
      ),
      actions: [
        Padding(
          padding: Responsive.isDesktop(context)
              ? const EdgeInsets.only(right: 32)
              : EdgeInsets.zero,
          child: AvatarWidget(
            userName: userProvider.userModel?.fullName ?? 'Guest', 
            userId: userProvider.userModel?.id,
          ),
        ),
      ],
    );
  }
}
