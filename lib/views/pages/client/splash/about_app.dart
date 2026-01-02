import 'package:flutter/material.dart';
import 'package:recomart/config/color.dart';

class AboutRecoMartScreen extends StatelessWidget {
  const AboutRecoMartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAnimatedWidget(
                    child: _buildSectionTitle('Revolutionizing Shopping'),
                  ),
                  const SizedBox(height: 12),
                  _buildAnimatedWidget(
                    delay: 100,
                    child: const Text(
                      'RecoMart is not just an e-commerce platform; it\'s your personal shopping companion powered by cutting-edge Artificial Intelligence.',
                      style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.6),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  _buildAnimatedWidget(delay: 200, child: _buildSectionTitle('Core Technologies')),
                  const SizedBox(height: 16),
                  _buildAnimatedWidget(delay: 300, child: _buildFeatureCard(Icons.psychology_outlined, 'AI-Powered Personalization', 'Deep learning algorithms analyze your preferences to curate a unique storefront.')),
                  _buildAnimatedWidget(delay: 400, child: _buildFeatureCard(Icons.auto_awesome_outlined, 'Smart Recommendations', 'Discover products you\'ll love before you even search for them.')),

                  const SizedBox(height: 40),
                  _buildAnimatedWidget(delay: 500, child: _buildSectionTitle('The Visionaries')),
                  const SizedBox(height: 16),
                  _buildVisionaryTeam(),

                  const SizedBox(height: 60),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedWidget({required Widget child, int delay = 0}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        title: const Text('ABOUT RECOMART', 
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.5, fontSize: 16)),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primary.withAlpha(150)],
            ),
          ),
          child: Center(
            child: Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.white.withOpacity(0.2)),
          ),
        ),
      ),
    );
  }

  Widget _buildVisionaryTeam() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          _buildAuthorRow("Huỳnh Hoàng Tiến Đạt", "52200023"),
          const Divider(height: 32),
          _buildAuthorRow("Đoàn Thống Lĩnh", "52200013"),
        ],
      ),
    );
  }

  Widget _buildAuthorRow(String name, String id) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(name[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("Student ID: $id", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ],
        ),
        const Spacer(),
        const Icon(Icons.verified_user, color: Colors.blue, size: 16),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5));
  }

  Widget _buildFeatureCard(IconData icon, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 30),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(desc, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          const Text('Version 1.0.2', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text('© 2026 RecoMart Visionaries', style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
        ],
      ),
    );
  }
}