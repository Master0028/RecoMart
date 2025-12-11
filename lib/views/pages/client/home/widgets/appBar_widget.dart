import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';

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
      padding: EdgeInsets.only(left: 16.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on, color: _primaryColor, size: 18),
          SizedBox(width: 4),
          Flexible(
            child: Text(
              'Ward A, Ho Chi Minh City', // Translated
              style: TextStyle(fontSize: 13, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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
    this.avatarUrl
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
      if (isLoggedIn) {'text': 'Profile', 'icon': Icons.person, 'value': 'Profile'},
      {'text': "Cart", 'icon': Icons.shopping_cart, 'value': "Cart"},
      {'text': "Support", 'icon': Icons.support, 'value': "Support"},
      // Toggle Logout/Login text based on state
      {'text': isLoggedIn ? 'Logout' : 'Login', 'icon': isLoggedIn ? Icons.logout : Icons.login, 'value': isLoggedIn ? 'Logout' : 'Login'},
    ];

    final RenderBox renderBox = _menuKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx - 100,
        offset.dy + renderBox.size.height,
        offset.dx + renderBox.size.width,
        offset.dy + renderBox.size.height,
      ),
      items: items.map((item) {
        return PopupMenuItem<String>(
          value: item['value'],
          child: Row(children: [Icon(item['icon'], color: _primaryColor, size: 20), const SizedBox(width: 8), Text(item['text'])]),
        );
      }).toList(),
    ).then((val) async {
      if (val == null) return;
      if (val == 'Home') context.go('/home');
      if (val == 'Profile') context.push('/profile');
      if (val == 'Cart') context.push('/cart');
      if (val == 'Support') context.push('/chat');
      if (val == 'Login') context.go('/login');
      if (val == 'Logout') {
        await FirebaseAuth.instance.signOut();
        if (mounted) context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget avatarCircle;
    if (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty) {
       avatarCircle = CircleAvatar(
         radius: Responsive.isDesktop(context) ? 15 : 18,
         backgroundImage: NetworkImage(widget.avatarUrl!),
         backgroundColor: Colors.grey[200],
       );
    } else {
       avatarCircle = CircleAvatar(
         radius: Responsive.isDesktop(context) ? 15 : 18,
         backgroundColor: _secondaryColor,
         child: Text(
           widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'G',
           style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
         ),
       );
    }

    if (!Responsive.isDesktop(context)) {
      return GestureDetector(
        key: _menuKey,
        onTap: _showDropdown,
        child: avatarCircle,
      );
    }

    return GestureDetector(
      key: _menuKey,
      onTap: _showDropdown,
      child: Container(
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
            Text(widget.userName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, color: Colors.black54, size: 18),
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
            decoration: BoxDecoration(color: _searchBarBackground, borderRadius: BorderRadius.circular(5)),
            child: Row(children: [
              Expanded(child: TextField(
                decoration: const InputDecoration(hintText: 'Search products...', border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12)),
                onSubmitted: (_) => context.push('/search'),
              )),
              Container(
                decoration: BoxDecoration(color: _actionButtonColor, borderRadius: BorderRadius.circular(5)),
                width: 50, height: 48,
                child: IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () => print('Search')),
              ),
            ]),
          ),
        ),
        const SizedBox(width: 20),
        AddToCartIcon(
          key: cartKey,
          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87, size: 28),
          badgeOptions: const BadgeOptions(active: true, backgroundColor: Colors.red),
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

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Responsive.isDesktop(context);

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      elevation: 0,
      toolbarHeight: isDesktop ? 80 : 60,

      title: isDesktop
          ? Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Row(
                children: [
                  SvgPicture.asset('assets/logo/logo.png', height: 30, width: 30),
                  const SizedBox(width: 8),
                  const Text.rich(TextSpan(children: [
                    TextSpan(text: 'Reco', style: TextStyle(color: _primaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
                    TextSpan(text: 'Mart', style: TextStyle(color: _secondaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
                  ])),
                  Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 40), child: _DesktopSearchAndCart(cartKey: cartKey))),
                ],
              ),
            )
          : const _MockLocationWidget(),

      actions: [
        if (!isDesktop) ...[
          IconButton(
            onPressed: () => context.push('/search'),
            icon: const Icon(Icons.search, color: Colors.black87),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: AddToCartIcon(
              key: cartKey,
              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
              badgeOptions: const BadgeOptions(active: true, backgroundColor: Colors.red),
            ),
          ),
        ],

        Padding(
          padding: EdgeInsets.only(right: isDesktop ? 32 : 16),
          child: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.userChanges(),
            builder: (context, snapshot) {
              final user = snapshot.data;
              final isLoggedIn = user != null;

              String displayName = 'Guest';
              String? photoUrl;
              String? uid;

              if (isLoggedIn) {
                displayName = user.displayName ?? user.email?.split('@')[0] ?? 'User';
                photoUrl = user.photoURL;
                uid = user.uid;
              }

              return InteractiveGuestAvatar(
                userName: displayName,
                userId: uid,
                avatarUrl: photoUrl,
              );
            },
          ),
        ),
      ],
    );
  }
}