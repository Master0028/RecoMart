import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LiveStreamScreen extends StatefulWidget {
  const LiveStreamScreen({super.key});

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWebApp = constraints.maxWidth > 600;
        double containerWidth = isWebApp ? 600 : constraints.maxWidth;

        return Scaffold(
          body: Center(
            child: SizedBox(
              width: containerWidth,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://i.imgur.com/example-image.png',
                    fit: BoxFit.cover,
                  ),

                  _buildInfoOverlay(),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _buildBottomNav(isWebApp, containerWidth),
        );
      },
    );
  }

  Widget _buildInfoOverlay() {
    return Positioned(
      bottom: 80,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              const Icon(Icons.visibility, color: Colors.white, size: 18),
              const SizedBox(width: 4),
              const Text(
                '2,530',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Live',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.play_arrow, color: Colors.white, size: 24),
            ],
          ),

          ElevatedButton(
            onPressed: () {
              context.push('/shopping-cloth');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Shop', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(bool isWebApp, double containerWidth) {
    return SizedBox(
      width: isWebApp ? containerWidth : double.infinity,
      child: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard_outlined), label: 'Vouchers'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
        showSelectedLabels: false,
        type: BottomNavigationBarType.fixed,
        elevation: 8.0,
      ),
    );
  }
}