import 'package:recomart/models/product.model.dart';
import 'package:recomart/test/mockdatatest.dart';
import 'package:recomart/utils/responsive.dart';
import 'package:recomart/utils/widget/footer.dart';
import 'package:recomart/views/pages/client/home/widgets/banner_widget.dart';
import 'package:recomart/views/pages/client/home/widgets/category_widget.dart';
import 'package:recomart/views/pages/client/home/widgets/product_widget.dart';
import 'package:recomart/views/pages/client/home/widgets/search_widget.dart';

import 'package:flutter/material.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  List<ProductModel> _products = [];
  @override
  void initState() {
    super.initState();
    _products = mockupProducts;
  }
  
  @override
  Widget build(BuildContext context) {
    // Get the user data from provider

    return Container(
      color: Colors.white,
      child: ListView(
        children: [
          Padding(
            padding: !Responsive.isMobile(context)
                ? EdgeInsets.only(top: 16, left: 64, right: 64)
                : EdgeInsets.only(top: 16, left: 16, right: 16),
            child: Column(
              children: [
                Responsive.isTablet(context) || Responsive.isMobile(context)
                    ? SearchWidget()
                    : SizedBox(),
                BannerWidget(),
                CategoryWidget(),
                SizedBox(
                  height: 16,
                ),
                FilterHomeProduct(),
                SizedBox(
                  height: 16,
                ),
                ProductListViewWidget(),
              ],
            ),
          ),
          if (Responsive.isDesktop(context)) FooterWidget(),
        ],
      ),
    );
  }

// @override
  // Widget build(BuildContext context) {
  //   // Get the user data from provider

  //   return Container(
  //     color: Colors.white,
  //     child: ListView(
  //       children: [
  //         Padding(
  //           padding: !Responsive.isMobile(context)
  //               ? const EdgeInsets.only(top: 16, left: 64, right: 64)
  //               : const EdgeInsets.only(top: 16, left: 16, right: 16),
  //           child: Column(
  //             children: [
  //               Responsive.isTablet(context) || Responsive.isMobile(context)
  //                   ? const SearchWidget()
  //                   : const SizedBox(),
  //               BannerWidget(),
  //               //CategoryWidget(categories: _categories), 
  //               const CategoryWidget(),
  //               const SizedBox(
  //                 height: 16,
  //               ),
  //               const FilterHomeProduct(),
  //               const SizedBox(
  //                 height: 16,
  //               ),
  //               // 4. TRUYỀN DỮ LIỆU SANG WIDGET CON (Cần cập nhật constructor của ProductListViewWidget)
  //               ProductListViewWidget(products: _products),
  //             ],
  //           ),
  //         ),
  //         if (Responsive.isDesktop(context)) const FooterWidget(),
  //       ],
  //     ),
  //   );
  // }
}
