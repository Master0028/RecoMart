import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:recomart/components/custom/bottom_navigation_bar.dart';
import 'package:recomart/components/custom/dropdown.dart';
import 'package:recomart/components/custom/pagination.dart';
import 'package:recomart/components/custom/radio.dart';
import 'package:recomart/components/custom/range_slider.dart';
import 'package:recomart/components/custom/skeleton.dart';
import 'package:recomart/components/custom/snackbar.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/consts/index.dart';
import 'package:recomart/utils/responsive.dart';
import 'package:recomart/views/pages/client/home/widgets/product_widget.dart';
import 'package:recomart/views/pages/client/login/widgets/button.dart';

import '../../../../provider/product_provider.dart';

class CategoryModelFE { final String id; final String name; CategoryModelFE({required this.id, required this.name}); }
class BrandModelFE { final String id; final String name; BrandModelFE({required this.id, required this.name}); }
const List<CategoryModelFE> FE_CATEGORIES = []; 
const List<BrandModelFE> FE_BRANDS = []; 
const List<String> FE_CURRENT_FILTERS = ['Category: PC', 'Price: > 5M'];
final List<dynamic> FE_PRODUCTS = List.generate(8, (index) => {
    'id': 'fe_prod_$index',
    'categoryId': 'fe_cat',
    'variantName': 'FE Product $index',
    'images': [],
    'price': 1000000.0,
    'variantDescription': 'FE description $index',
    'averageRating': 4.5,
});


class ProductPageBody extends StatelessWidget {
  const ProductPageBody({
    super.key,
    this.categoryId,
  });
  final String? categoryId;

  @override
  Widget build(BuildContext context) {
    bool isMobile = Responsive.isMobile(context);
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final showBackButton = arguments?['showBackButton'] ?? false;
    
    void _handleGoBack() {
        context.pop();
        print('FE: Navigated back to Home/Previous screen');
    }

    return SafeArea(
      child: ListView(
        children: [
          if (isMobile && showBackButton)
            Container(
              padding: const EdgeInsets.only(top: 16, left: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: _handleGoBack,
                  ),
                  const Text(
                    'Home',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => const FilterWidget(),
                          );
                        },
                        icon: const Icon(
                          Icons.filter_list,
                          color: Colors.black,
                          size: 16,
                        ),
                        label: const Text(
                          'Filter',
                          style: TextStyle(color: Colors.black, fontSize: 14),
                        ),
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.resolveWith<Color?>(
                            (states) {
                              if (states.contains(WidgetState.hovered)) {
                                return Colors.grey[100];
                              }
                              return Colors.white;
                            },
                          ),
                          elevation: WidgetStateProperty.all(0),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              side: const BorderSide(
                                color: Colors.black45,
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ShowListProductWidget(
                        categoryId: categoryId,
                      ),
                    ],
                  )
                : Column(
                    children: [
                      if (Responsive.isTablet(context) && showBackButton)
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                      Icons.arrow_back_ios_new_rounded),
                                  onPressed: _handleGoBack,
                                ),
                                const Text(
                                  'Home',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: 200,
                              maxWidth: 300,
                            ),
                            child: FilterWidget(),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ShowListProductWidget(
                              categoryId: categoryId,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class FilterWidget extends StatefulWidget {
  const FilterWidget({super.key});

  @override
  State<FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  late double minPrice;
  late double maxPrice;
  late RangeValues _rangeValues;
  late RatingFilterValue _selectedRatingValue;

  List<dynamic> categories = FE_CATEGORIES;
  List<dynamic> brands = FE_BRANDS;

  Future<void> fetchData() async {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    await Future.wait([
      provider.fetchCategories(),
      provider.fetchBrands(),
    ]);

    setState(() {
      categories = provider.categoriesMap.entries
          .map((entry) => CategoryModelFE(id: entry.key, name: entry.value))
          .toList();

      brands = provider.brandsMap.entries
          .map((entry) => BrandModelFE(id: entry.key, name: entry.value))
          .toList();
    });

    print('✅ Filter data fetched from Firebase (categories + brands)');
  }

  Map<String, bool> isExpanded = {
    'Category': false,
    'Brand': false,
  };

  Map<String, Set<String>> selectedItems = {
    'Category': {},
    'Brand': {},
  };

  @override
  void initState() {
    super.initState();
    minPrice = 100000;
    maxPrice = 100000000;
    _rangeValues = RangeValues(minPrice, maxPrice);
    _selectedRatingValue = RatingFilterValue.all;
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (Responsive.isMobile(context))
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
              ),
              buildFilterSection('Product Category', categories, 'Category'),
              buildFilterSection('Brand', brands, 'Brand'),
              const SizedBox(height: 16),
              RangeSliderCustom(
                title: 'Price',
                divisions: 50,
                minValue: minPrice,
                maxValue: maxPrice,
                rangeValues: _rangeValues,
                onChanged: (RangeValues values) {
                  setState(() {
                    _rangeValues = values;
                  });
                },
              ),
              const SizedBox(height: 16),
              RatingFilter(
                  selectedRatingValue: _selectedRatingValue,
                  onChanged: (value) {
                    setState(() {
                      _selectedRatingValue = value;
                    });
                  }),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: MyButton(
                      text: 'Reset',
                      variantIsOutline: true,
                      onTap: (_) {
                        final provider = Provider.of<ProductProvider>(context, listen: false);
                        provider.resetFilters();

                        setState(() {
                          selectedItems = {'Category': {}, 'Brand': {}};
                          _rangeValues = RangeValues(minPrice, maxPrice);
                          _selectedRatingValue = RatingFilterValue.all;
                        });
                        if (Responsive.isMobile(context)) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: MyButton(
                      text: 'Apply',
                      onTap: (_) {
                        final provider = Provider.of<ProductProvider>(context, listen: false);

                        // Lấy ID danh mục / thương hiệu đầu tiên được chọn
                        final selectedCategory = selectedItems['Category']?.isNotEmpty == true
                            ? selectedItems['Category']!.first
                            : null;
                        final selectedBrand = selectedItems['Brand']?.isNotEmpty == true
                            ? selectedItems['Brand']!.first
                            : null;

                        double minRating = 0;
                        if (_selectedRatingValue == RatingFilterValue.fiveStar) minRating = 5;
                        else if (_selectedRatingValue == RatingFilterValue.fourStar) minRating = 4;
                        else if (_selectedRatingValue == RatingFilterValue.threeStar) minRating = 3;
                        else if (_selectedRatingValue == RatingFilterValue.twoStar) minRating = 2;
                        else if (_selectedRatingValue == RatingFilterValue.oneStar) minRating = 1;

                        provider.updateFilters(
                          categoryId: selectedCategory,
                          brandId: selectedBrand,
                          minPrice: _rangeValues.start,
                          maxPrice: _rangeValues.end,
                          minRating: minRating,
                        );

                        if (Responsive.isMobile(context)) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFilterSection(String title, List<dynamic> items, String key) {
    bool expanded = isExpanded[key] ?? false;
    int displayCount = expanded ? items.length : 0;

    const Color primaryColor = Color.fromARGB(255, 33, 150, 243);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: primaryColor.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white, 
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    isExpanded[key] = !expanded;
                  });
                },
                icon: Icon(
                  expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.white, 
                ),
              ),
            ],
          ),
        ),
        if (expanded)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayCount,
            itemBuilder: (context, index) {
              final item = items[index];
              final itemId = item.id; 
              final itemName = item.name;
              final isSelected = selectedItems[key]?.contains(itemId) ?? false;

              return CheckboxListTile(
                activeColor: primaryColor,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  itemName,
                  style: const TextStyle(fontSize: 14),
                ),
                value: isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedItems[key]?.add(itemId);
                    } else {
                      selectedItems[key]?.remove(itemId);
                    }
                  });
                },
              );
            },
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class RatingFilter extends StatefulWidget {
  RatingFilter({
    super.key,
    required this.selectedRatingValue,
    required this.onChanged,
  });

  late RatingFilterValue selectedRatingValue;
  final Function(RatingFilterValue) onChanged;

  @override
  State<RatingFilter> createState() => _RatingFilterState();
}

class _RatingFilterState extends State<RatingFilter> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Rating',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: Responsive.isMobile(context) ? 100 : 200,
          child: ListView.separated(
            shrinkWrap: true,
            itemBuilder: (context, index) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    5 - index,
                    (index) {
                      return const Icon(
                        Icons.star,
                        color: Colors.amber,
                      );
                    },
                  ),
                ),
                RadioCustom<RatingFilterValue>(
                  value: RatingFilterValue
                      .values[RatingFilterValue.values.length - index - 1],
                  groupValue: widget.selectedRatingValue,
                  onChanged: (value) {
                    widget.onChanged(value!);
                  },
                )
              ],
            ),
            separatorBuilder: (context, _) => const SizedBox(height: 5),
            itemCount: 5,
          ),
        ),
      ],
    );
  }
}

class ShowListProductWidget extends StatefulWidget {
  const ShowListProductWidget({super.key, this.categoryId});
  final String? categoryId;

  @override
  State<ShowListProductWidget> createState() => _ShowListProductWidgetState();
}

class _ShowListProductWidgetState extends State<ShowListProductWidget> {

  final List<String> sortOptions = [
    'All Products',
    'Name: A to Z',
    'Name: Z to A',
    'Price: Low to High',
    'Price: High to Low',
  ];
  
  void _handleSortChangeFE(String value) {
      print('FE: Sorting by $value');
  }
  
  void _handleRemoveFilterFE(String removedFilter) {
      print('FE: Filter $removedFilter removed');
      showCustomSnackBar(context, '$removedFilter removed');
  }


  @override
  Widget build(BuildContext context) {
    final filters = FE_CURRENT_FILTERS;
    final bool isMobile = Responsive.isMobile(context);
    return Container(
      padding: !isMobile ? const EdgeInsets.all(16) : null,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: !isMobile
            ? const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            runSpacing: 10,
            spacing: 20,
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (!isMobile)
                const Text(
                  'Product List',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Sort by: ',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black45, width: 0.5),
                    ),
                    child: DropdownCustom(
                      items: sortOptions,
                      onChanged: (value) {
                        _handleSortChangeFE(value);
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          //List filter
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: List.generate(filters.length, (index) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      filters[index],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () {
                        final removedFilter = filters[index];
                        _handleRemoveFilterFE(removedFilter);
                      },
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.primary,
                      ),
                      iconSize: 16,
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          ProductList(
            categoryId: widget.categoryId,
          ),
        ],
      ),
    );
  }
}

class ProductList extends StatefulWidget {
  const ProductList({super.key, this.categoryId});
  final String? categoryId;

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProductsFilter(reset: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    final isMobile = Responsive.isMobile(context);

    if (provider.loading && provider.products.isEmpty) {
      return GridView.builder(
        itemCount: 10,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: Responsive.isDesktop(context) ? 4 : 2,
          childAspectRatio: 0.55,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          mainAxisExtent: 350,
        ),
        itemBuilder: (context, index) => const Skeleton(),
      );
    }

    if (provider.products.isEmpty) {
      return const Center(
        child: Text(
          'No products found!',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      );
    }

    final products = provider.products;

    return Column(
      children: [
        GridView.builder(
          itemCount: products.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: Responsive.isDesktop(context) ? 4 : 2,
            childAspectRatio: 0.55,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            mainAxisExtent: 350,
          ),
          itemBuilder: (context, index) {
            final p = products[index];
            return ProductView(
              id: p.id,
              categoryId: p.categoryId,
              name: p.name,
              image: p.imageUrl,
              price: p.price,
              averageRating: p.averageRating.toString(),
            );
          },
        ),
        const SizedBox(height: 20),
        PaginationWidget(
          currentPage: provider.currentPage,
          totalPages: 999, // tạm đặt cao, vì mình kiểm tra hasMore
          onPageChanged: (page) async {
            if (provider.hasMore) {
              await provider.nextPage();
            } else {
              showCustomSnackBar(context, "No more products!");
            }
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
