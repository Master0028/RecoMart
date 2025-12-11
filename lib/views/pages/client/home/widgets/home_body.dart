import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recomart/utils/responsive.dart';
import 'package:recomart/utils/widget/footer.dart';
import 'package:recomart/views/pages/client/home/widgets/banner_widget.dart';
import 'package:recomart/views/pages/client/home/widgets/category_widget.dart' hide Responsive;
import 'package:recomart/views/pages/client/home/widgets/product_widget.dart';
import 'package:recomart/views/pages/client/home/widgets/recommendation_widget.dart';
import 'package:recomart/views/pages/client/home/widgets/search_widget.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  int aiModelUserId = 0;
  bool isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserId();
  }

  Future<void> _fetchCurrentUserId() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: currentUser.email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final userData = querySnapshot.docs.first.data();
          
          if (userData.containsKey('user_id')) {
            if (mounted) {
              setState(() {
                aiModelUserId = userData['user_id'];
                isLoadingUser = false;
              });
            }
            print("Found AI Model User ID: $aiModelUserId");
          } else {
            if (mounted) {
              setState(() {
                aiModelUserId = 0; 
                isLoadingUser = false;
              });
            }
            print("New User (No Model ID) -> Fallback to Popular Items");
          }
        } else {
          if (mounted) setState(() => isLoadingUser = false);
        }
      } catch (e) {
        print("Error fetching User ID: $e");
        if (mounted) setState(() => isLoadingUser = false);
      }
    } else {
      print("Guest User -> Fallback to Popular Items");
      if (mounted) setState(() => isLoadingUser = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        children: [
          Padding(
            padding: !Responsive.isMobile(context)
                ? const EdgeInsets.only(top: 16, left: 64, right: 64)
                : const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: Column(
              children: [
                Responsive.isTablet(context) || Responsive.isMobile(context)
                    ? const SearchWidget()
                    : const SizedBox(),               
                BannerWidget(),
                const CategoryWidget(),               
                const SizedBox(height: 16),
                isLoadingUser 
                    ? const Center(child: CircularProgressIndicator())
                    : RecommendationWidget(userId: aiModelUserId),

                const SizedBox(height: 16),               
                const FilterHomeProduct(),              
                const SizedBox(height: 16),             
                const ProductListViewWidget(),
              ],
            ),
          ),
          if (Responsive.isDesktop(context)) const FooterWidget(),
        ],
      ),
    );
  }
}