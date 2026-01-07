import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recomart/provider/user_provider.dart';
import 'package:recomart/utils/responsive.dart';
import 'package:recomart/utils/widget/footer.dart';
import 'package:recomart/views/pages/client/home/widgets/banner_widget.dart';
import 'package:recomart/views/pages/client/home/widgets/recommendation_widget.dart';
import 'package:recomart/views/pages/client/home/widgets/search_widget.dart';
import 'package:recomart/views/pages/client/home/widgets/category_widget.dart' as cat_widget;
import 'package:recomart/views/pages/client/product/product_page_body.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  int? aiModelUserId;
  bool isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserId();
  }

  Future<void> _fetchCurrentUserId() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!userProvider.isLoggedIn) {
      setState(() {
        aiModelUserId = null;
        isLoadingUser = false;
      });
      return;
    }

    var bytes = utf8.encode(userProvider.userId);
    var digest = md5.convert(bytes);
    String hex = digest.toString();
    int hashedId = int.parse(hex.substring(hex.length - 8), radix: 16);

    setState(() {
      aiModelUserId = hashedId;
      isLoadingUser = false;
    });

    print("DEBUG: Firebase UID: ${userProvider.userId} -> AI ID: $aiModelUserId");
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
      },
      child: Container(
        color: Colors.white,
        child: ListView(
          children: [
            Padding(
              padding: !Responsive.isMobile(context)
                  ? const EdgeInsets.only(top: 16, left: 64, right: 64)
                  : const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: Column(
                children: [
                  if (Responsive.isTablet(context) || Responsive.isMobile(context))
                    const SearchWidget(),
                  BannerWidget(),
                  const cat_widget.CategoryWidget(),
                  const SizedBox(height: 16),
                  if (!isLoadingUser && aiModelUserId != null)
                    RecommendationWidget(userId: aiModelUserId!),
                  const SizedBox(height: 16),
                  const ShowListProductWidget(categoryId: null),
                ],
              ),
            ),
            if (Responsive.isDesktop(context)) const FooterWidget(),
          ],
        ),
      ),
    );
  }
}