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
  int aiModelUserId = 0;
  bool isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserId();
  }

  Future<void> _fetchCurrentUserId() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (!userProvider.isLoggedIn) {
        if (mounted) setState(() => isLoadingUser = false);
        return;
    }

    final String uidStr = userProvider.userId;
    
    aiModelUserId = 0; 

    if (mounted) setState(() => isLoadingUser = false);
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
                
                const cat_widget.CategoryWidget(),               
                
                const SizedBox(height: 16),
                
                isLoadingUser 
                    ? const Center(child: CircularProgressIndicator())
                    : RecommendationWidget(userId: aiModelUserId),

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