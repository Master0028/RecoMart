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
      if (mounted) {
        aiModelUserId = null;
        isLoadingUser = false;
        setState(() {});
      }
      return;
    }

    // map UID Firebase -> userId cho AI
    // aiModelUserId = await userService.getAiUserId(userProvider.userId);

    aiModelUserId = int.tryParse(userProvider.userId);

    if (mounted) {
      isLoadingUser = false;
      setState(() {});
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
    );
  }
}
