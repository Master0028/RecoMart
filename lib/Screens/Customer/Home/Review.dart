import 'package:flutter/material.dart';
import 'package:recomart/widgets/Footer/mobile_navigation_bar.dart';

final List<Map<String, dynamic>> reviewsData = List.generate(
  6,
  (index) => {
    'name': 'Veronika',
    'avatarUrl': 'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=200',
    'rating': 4,
    'comment': 'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum',
  },
);

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _bottomNavIndex = 4;

  void _onItemTapped(int index) {
    setState(() {
      _bottomNavIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemBuilder: (context, index) {
            if (index == 0) {
              return const Text(
                'Reviews',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              );
            }
            final review = reviewsData[index - 1];
            return ReviewCard(
              name: review['name'],
              avatarUrl: review['avatarUrl'],
              rating: review['rating'],
              comment: review['comment'],
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 24),
          itemCount: reviewsData.length + 1,
        ),
      ),
      bottomNavigationBar: MobileNavigationBar(
        selectedIndex: _bottomNavIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

// --- WIDGET CHO MỘT THẺ REVIEW ---
class ReviewCard extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final int rating;
  final String comment;

  const ReviewCard({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.rating,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Avatar người dùng
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(avatarUrl),
            ),
            const SizedBox(width: 12),
            // Tên và sao đánh giá
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Nội dung bình luận
        Text(
          comment,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}