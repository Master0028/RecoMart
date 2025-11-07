import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recomart/models/coupon.model.dart';
import 'package:recomart/utils/responsive.dart';
import 'package:intl/intl.dart';
import 'coupon_form.dart';

class CouponTable extends StatefulWidget {
  final List<CouponModel> coupons;

  const CouponTable({super.key, required this.coupons});

  @override
  State<CouponTable> createState() => _CouponTableState();
}

class _CouponTableState extends State<CouponTable> {
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> get filteredCoupons {
    if (_searchController.text.isEmpty) {
      return widget.coupons;
    } else {
      return widget.coupons.where((coupon) {
        return (coupon.code ?? '').toLowerCase().contains(_searchController.text.toLowerCase());
      }).toList();
    }
  }

  void _showCouponForm(CouponModel coupon) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            coupon.code ?? 'N/A',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: const InputDecorationTheme(
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange, width: 2),
                ),
                labelStyle: TextStyle(color: Colors.black),
                floatingLabelStyle: TextStyle(color: Colors.orange),
              ),
            ),
            child: CouponForm(
              buttonLabel: "Save",
              initialCoupon: coupon,
              onSubmit: (updatedCouponData) async {
                await Future.delayed(const Duration(milliseconds: 300));
                context.pop();

                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coupon updated successfully')),
                );
              },
            ),
          ),
        );
      },
    );
  }
  
  TableRow buildHeaderRow(List<String> headers, List<double> colWidths) {
    return TableRow(
      decoration: const BoxDecoration(color: Color.fromARGB(255, 240, 240, 240)),
      children: List.generate(headers.length, (index) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          width: colWidths[index],
          child: Text(
            headers[index],
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }),
    );
  }

  TableRow buildCouponRow(CouponModel coupon, List<double> colWidths) {
    final isMobile = Responsive.isMobile(context);
    DateTime? createdAt = coupon.createdAt.toDate();

    return TableRow(
      children: isMobile
          ? [
        InkWell(
          onTap: () => _showCouponForm(coupon),
          child: cellText(coupon.code as String? ?? 'N/A', colWidths[0]),
        ),
        InkWell(
          onTap: () => _showCouponForm(coupon),
          child: cellText(
            createdAt != null
                ? DateFormat('dd/MM/yyyy').format(createdAt)
                : 'N/A',
            colWidths[1],
          ),
        ),
        InkWell(
          onTap: () => _showCouponForm(coupon),
          child: cellText("${coupon.discountValue as num? ?? 0}đ", colWidths[2]),
        ),
      ]
          : [
        InkWell(
          onTap: () => _showCouponForm(coupon),
          child: cellText(coupon.code as String? ?? 'N/A', colWidths[0]),
        ),
        InkWell(
          onTap: () => _showCouponForm(coupon),
          child: cellText(
            createdAt != null
                ? DateFormat('dd/MM/yyyy').format(createdAt)
                : 'N/A',
            colWidths[1],
          ),
        ),
        InkWell(
          onTap: () => _showCouponForm(coupon),
          child: cellText("${coupon.discountValue as num? ?? 0}đ", colWidths[2]),
        ),
        InkWell(
          onTap: () => _showCouponForm(coupon),
          child: cellText((coupon.maxUsage as num? ?? 0).toString(), colWidths[3]),
        ),
        InkWell(
          onTap: () => _showCouponForm(coupon),
          child: cellText((coupon.usedCount as num? ?? 0).toString(), colWidths[4]),
        ),
      ],
    );
  }

  Widget cellText(String text, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        softWrap: false,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = Responsive.isMobile(context);
        final tableWidth = constraints.maxWidth;

        final List<double> colWidths = isMobile
            ? [tableWidth * 0.3, tableWidth * 0.3, tableWidth * 0.3]
            : [
          tableWidth * 0.15, 
          tableWidth * 0.25, 
          tableWidth * 0.15, 
          tableWidth * 0.2,  
          tableWidth * 0.25, 
        ];

        final headers = isMobile
            ? ["Code", "Created At", "Discount Value"]
            : [
          "Code",
          "Created At",
          "Discount Value",
          "Usage Count",
          "Max Usage",
        ];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(50),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Coupon List",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 200,
                    height: 36,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        hintText: "Search by code",
                        prefixIcon: const Icon(Icons.search, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.orange),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: {
                      for (int i = 0; i < colWidths.length; i++)
                        i: FixedColumnWidth(colWidths[i]),
                    },
                    border: TableBorder.all(color: Colors.grey.shade300),
                    children: [
                      buildHeaderRow(headers, colWidths),
                      ...filteredCoupons
                          .map((coupon) => buildCouponRow(coupon, colWidths)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}