import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

const Color _primaryColor = Colors.blue; 
const Color _secondaryColor = Colors.orange;
const Color _searchBarBackground = Color(0xFFEEEEEE);
const Color _actionButtonColor = Color(0xFFFF5722);

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

class InteractiveGuestAvatar extends StatefulWidget {
  final String userName;
  final String? userId;

  const InteractiveGuestAvatar({super.key, required this.userName, this.userId});

  @override
  State<InteractiveGuestAvatar> createState() => _InteractiveGuestAvatarState();
}

class _InteractiveGuestAvatarState extends State<InteractiveGuestAvatar> {
  final GlobalKey _menuKey = GlobalKey();

  void _handleMenuAction(String action) {
    if (action == 'Home') {
      print('FE Action: Navigating to Home');
    } else if (action == 'Logout') {
      print('FE Action: Logging out Guest user');
    } else if (action == 'Cart') {
      print('FE Action: Navigating to Cart from Dropdown');
    }
  }

  void _showDropdown() {
    final List<Map<String, dynamic>> items = [
      {'text': 'Home', 'icon': Icons.home_outlined, 'value': 'Home'},
      {'text': 'Profile', 'icon': Icons.person, 'value': 'Profile'},
      {'text': "Cart", 'icon': Icons.shopping_cart, 'value': "Cart"},
      {'text': "Support", 'icon': Icons.support, 'value': "Support"},
      {'text': 'Logout', 'icon': Icons.logout, 'value': 'Logout'},
    ];

    final RenderBox renderBox = _menuKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + renderBox.size.height,
        offset.dx + renderBox.size.width,
        offset.dy + renderBox.size.height,
      ),
      items: items.map((item) {
        return PopupMenuItem<String>(
          value: item['value'],
          child: Row(
            children: [
              Icon(item['icon'] as IconData, color: _primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(item['text'] as String),
            ],
          ),
        );
      }).toList(),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ).then((value) {
      if (value != null) {
        _handleMenuAction(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _menuKey,
      onTap: _showDropdown,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: _primaryColor.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 15,
              backgroundColor: _secondaryColor,
              child: Text('G', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            Text(widget.userName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, color: Colors.black54, size: 20),
          ],
        ),
      ),
    );
  }
}

class _DesktopSearchAndCart extends StatelessWidget {
  const _DesktopSearchAndCart();

  void _handleSearch() {
    print('FE Action: Search Button clicked');
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            decoration: BoxDecoration(
              color: _searchBarBackground,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm sản phẩm, thương hiệu, và tên shop',
                      hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                    ),
                    onSubmitted: (_) => context.push('/search'),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: _actionButtonColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  height: 48, 
                  width: 60,
                  child: IconButton(
                    icon: const Icon(Icons.search, color: Colors.white, size: 24),
                    onPressed: _handleSearch,
                    tooltip: 'Tìm kiếm',
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(width: 30),
        IconButton(
          onPressed: () => context.push('/cart'),
          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87, size: 28),
          tooltip: 'Giỏ hàng',
        ),
      ],
    );
  }
}

// --- APP BAR CUSTOM ĐÃ CẬP NHẬT HOÀN TOÀN ---

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
          // LOGO Section
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
              : const _MockLocationWidget(), // Mobile: Hiển thị Vị trí
          
          // Thanh tìm kiếm lớn (Desktop)
          Responsive.isDesktop(context)
              ? const Expanded(
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: _DesktopSearchAndCart(), // Thanh tìm kiếm và Icon Cart
                  ),
                )
              : const SizedBox(),
        ],
      ),
      actions: [
        // CART ICON (CHỈ HIỂN THỊ KHI MOBILE)
        if (!Responsive.isDesktop(context))
          IconButton(
            onPressed: () => print('FE Action: Mobile Cart clicked'),
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
          ),
          
        // GUEST/AVATAR DROPDOWN
        Padding(
          padding: Responsive.isDesktop(context)
              ? const EdgeInsets.only(right: 32)
              : const EdgeInsets.only(right: 16),
          child: const InteractiveGuestAvatar(
            userName: defaultUserName,
            userId: null,
          ),
        ),
      ],
    );
  }
}