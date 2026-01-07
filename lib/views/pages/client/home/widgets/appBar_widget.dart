import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:provider/provider.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/provider/user_provider.dart';
import 'package:recomart/provider/cart_provider.dart';

const Color _primaryColor = Colors.blue;
const Color _secondaryColor = Colors.orange;
const Color _searchBarBackground = Color(0xFFEEEEEE);
const Color _actionButtonColor = Color(0xFFFF5722);

class Responsive {
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1000;
}

class _MockLocationWidget extends StatelessWidget {
  final VoidCallback? onLongPress;
  const _MockLocationWidget({this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/address'),
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(20),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on, color: AppColors.primary, size: 18),
            SizedBox(width: 4),
            Flexible(
              child: Text(
                'Ward A, Ho Chi Minh City',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }
}

class InteractiveGuestAvatar extends StatefulWidget {
  final String userName;
  final String? userId;
  final String? avatarUrl;

  const InteractiveGuestAvatar({
    super.key,
    required this.userName,
    this.userId,
    this.avatarUrl,
  });

  @override
  State<InteractiveGuestAvatar> createState() => _InteractiveGuestAvatarState();
}

class _InteractiveGuestAvatarState extends State<InteractiveGuestAvatar> {
  final GlobalKey _menuKey = GlobalKey();

  void _showDropdown() {
    final bool isLoggedIn = widget.userId != null;
    final List<Map<String, dynamic>> items = [
      {'text': 'Home', 'icon': Icons.home_outlined, 'value': 'Home'},
      if (isLoggedIn)
        {'text': 'Profile', 'icon': Icons.person_outline, 'value': 'Profile'},
      {'text': "Cart", 'icon': Icons.shopping_cart_outlined, 'value': "Cart"},
      {'text': "Support", 'icon': Icons.help_outline, 'value': "Support"},
      {
        'text': isLoggedIn ? 'Logout' : 'Login',
        'icon': isLoggedIn ? Icons.logout : Icons.login,
        'value': isLoggedIn ? 'Logout' : 'Login'
      },
    ];

    final RenderBox renderBox =
        _menuKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    showMenu<String>(
      context: context,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      constraints: BoxConstraints(
          minWidth: renderBox.size.width > 150 ? renderBox.size.width : 150),
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + renderBox.size.height + 6,
        offset.dx + renderBox.size.width,
        offset.dy + renderBox.size.height + 100,
      ),
      items: items.map((item) {
        return PopupMenuItem<String>(
          value: item['value'],
          height: 40,
          child: Row(children: [
            Icon(item['icon'], color: _primaryColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
                child: Text(
              item['text'],
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ))
          ]),
        );
      }).toList(),
    ).then((val) async {
      if (val == null) return;
      if (val == 'Home') context.go('/home');
      if (val == 'Profile') context.push('/profile');
      if (val == 'Cart') context.push('/cart');
      if (val == 'Support') context.push('/help-center');
      if (val == 'Login') context.go('/login');
      if (val == 'Logout') {
        await Provider.of<UserProvider>(context, listen: false).signOut();
        if (mounted) context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget avatarCircle = CircleAvatar(
      radius: Responsive.isDesktop(context) ? 15 : 18,
      backgroundImage: (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty)
          ? NetworkImage(widget.avatarUrl!)
          : null,
      backgroundColor:
          (widget.avatarUrl == null) ? _secondaryColor : Colors.grey[200],
      child: (widget.avatarUrl == null)
          ? Text(
              widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'G',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold))
          : null,
    );

    return GestureDetector(
      key: _menuKey,
      onTap: _showDropdown,
      child: !Responsive.isDesktop(context)
          ? avatarCircle
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: _primaryColor.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  avatarCircle,
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      widget.userName,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down,
                      color: Colors.black54, size: 18),
                ],
              ),
            ),
    );
  }
}

class _DesktopSearchAndCart extends StatelessWidget {
  final GlobalKey<CartIconKey> cartKey;
  const _DesktopSearchAndCart({required this.cartKey});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            decoration: BoxDecoration(
                color: _searchBarBackground,
                borderRadius: BorderRadius.circular(5)),
            child: Row(children: [
              Expanded(
                child: TextField(
                  readOnly: true,
                  onTap: () => context.push('/search'),
                  decoration: const InputDecoration(
                      hintText: 'Search products...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 15)),
                  onSubmitted: (_) => context.push('/search'),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    color: _actionButtonColor,
                    borderRadius: BorderRadius.circular(5)),
                width: 50,
                height: 48,
                child: IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () => context.push('/search')),
              ),
            ]),
          ),
        ),
        const SizedBox(width: 20),
        Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            final int count = cartProvider.totalItems;

            return Badge(
              label: Text('$count'),
              isLabelVisible: count > 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  context.push('/cart');
                },
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: AddToCartIcon(
                    key: cartKey,
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      size: 26,
                      color: Colors.black87,
                    ),
                    badgeOptions: const BadgeOptions(active: false),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class AppBarHomeCustom extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<CartIconKey> cartKey;
  const AppBarHomeCustom({super.key, required this.cartKey});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  void _showAppInfo(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'RecoMart',
      applicationVersion: '1.0.2+build.20260101',
      applicationIcon: Image.asset('assets/logo/logo.png', width: 50, height: 50),
      applicationLegalese: '© 2026 RecoMart Visionaries. All rights reserved.',
      children: const [
        SizedBox(height: 16),
        Text('Developed by: Visionaries Team'),
        Text('AI-Powered Personalized Shopping Experience.'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Responsive.isDesktop(context);

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: isDesktop ? 80 : 60,
      title: isDesktop
          ? Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Row(
                children: [
                  GestureDetector(
                    onDoubleTap: () => _showAppInfo(context),
                    child: Row(
                      children: [
                        Image.asset('assets/logo/logo.png', height: 30, width: 30),
                        const SizedBox(width: 8),
                        const Text.rich(TextSpan(children: [
                          TextSpan(text: 'Reco', style: TextStyle(color: _primaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
                          TextSpan(text: 'Mart', style: TextStyle(color: _secondaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
                        ])),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: _DesktopSearchAndCart(cartKey: cartKey),
                    ),
                  ),
                ],
              ),
            )
          : _MockLocationWidget(onLongPress: () => _showAppInfo(context)),
      actions: [
        if (!isDesktop)
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return IconButton(
                onPressed: () => context.push('/cart'),
                icon: Badge(
                  label: Text('${cartProvider.totalItems}'),
                  isLabelVisible: cartProvider.totalItems > 0,
                  child: AddToCartIcon(
                    key: cartKey,
                    icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87, size: 28),
                    badgeOptions: const BadgeOptions(active: false),
                  ),
                ),
              );
            },
          ),
        Padding(
          padding: EdgeInsets.only(right: isDesktop ? 32 : 10, left: 8),
          child: Consumer<UserProvider>(
            builder: (context, userProvider, _) => InteractiveGuestAvatar(
              userName: userProvider.isLoggedIn ? userProvider.userName : 'Guest',
              userId: userProvider.isLoggedIn ? userProvider.userId : null,
              avatarUrl: userProvider.userInfo?.avatar,
            ),
          ),
        ),
      ],
    );
  }
}