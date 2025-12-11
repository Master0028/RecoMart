import 'package:flutter/material.dart';
import 'package:recomart/utils/responsive.dart';
import '../../../../../models/brand.model.dart';
import 'brand_form.dart';

class BrandTable extends StatefulWidget {
  final List<BrandModel> brands;

  const BrandTable({super.key, required this.brands});

  @override
  State<BrandTable> createState() => _BrandTableState();
}

class _BrandTableState extends State<BrandTable> {
  final TextEditingController _searchController = TextEditingController();

  List<BrandModel> get filteredBrands {
    var allBrands = widget.brands;
    
    if (_searchController.text.isEmpty) {
      return allBrands;
    } else {
      return allBrands.where((brand) { 
        return brand.name
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
      }).toList();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Inactive':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showBrandForm(BrandModel brand) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            brand.name.isNotEmpty ? 'Edit Brand' : 'Add Brand',
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
            child: BrandForm(initialBrand: brand),
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

  TableRow buildBrandRow(int index, BrandModel brand, List<double> colWidths) {
    String getShortId(String id) {
      return brand.id.length > 5 ? brand.id.substring(0, 5) : brand.id; 
    }

    return TableRow(
      children: [
        InkWell(
          onTap: () => _showBrandForm(brand),
          child: cellText(index.toString(), colWidths[0]),
        ),
        InkWell(
          onTap: () => _showBrandForm(brand),
          child: brandCell(brand, colWidths[1]),
        ),
        InkWell(
          onTap: () => _showBrandForm(brand),
          child: Container(
            width: colWidths[2],
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Chip(
              label: Text(
                brand.isActive ? 'Active' : 'Inactive',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor:
              _getStatusColor(brand.isActive ? 'Active' : 'Inactive'),
            ),
          ),
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
      ),
    );
  }

  Widget brandCell(BrandModel brand, double width) {
    String getShortId(String id) {
      return brand.id.length > 5 ? brand.id.substring(0, 5) : brand.id;
    }

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: brand.imageUrl != null && brand.imageUrl.isNotEmpty
                ? Image.network(
              brand.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Center(child: Text("No Image")),
                );
              },
            )
                : Container(
              color: Colors.grey[300],
              child: const Center(child: Text("No Image")),
            ),
          ),
          const SizedBox(width: 8),
          Expanded( 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brand.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                Text(
                  'ID: ${getShortId(brand.id)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = Responsive.isMobile(context);
        final tableWidth = constraints.maxWidth;

        final List<double> colWidths = isMobile
            ? [tableWidth * 0.20, tableWidth * 0.55, tableWidth * 0.25]
            : [
          tableWidth * 0.15,
          tableWidth * 0.65,
          tableWidth * 0.15,
        ];

        final headers = isMobile
            ? ['ID', 'Brand', 'Status']
            : ['ID', 'Brand', 'Status'];

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
                    'Brand List',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 200,
                    height: 36,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12),
                        hintText: 'Search by name',
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
                      ...filteredBrands.asMap().entries.map((entry) {
                        final index = entry.key + 1;
                        final brand = entry.value;
                        return buildBrandRow(index, brand, colWidths);
                      }),
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