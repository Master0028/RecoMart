import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recomart/utils/responsive.dart';
import '../../../../../models/category.model.dart';
import 'category_form.dart';

class CategoryTable extends StatefulWidget {
  final List<dynamic> categories; 

  const CategoryTable({super.key, required this.categories});

  @override
  State<CategoryTable> createState() => _CategoryTableState();
}

class _CategoryTableState extends State<CategoryTable> {
  final TextEditingController _searchController = TextEditingController();

  List<CategoryModel> get filteredCategories {
    final List<CategoryModel> allCategories = widget.categories.map<CategoryModel>((item) {
      if (item is CategoryModel) {
        return item;
      } else if (item is Map<String, dynamic>) {
        final dynamic rawId = item['id'];
        final int parsedId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '') ?? 0;

        return CategoryModel(
          id: parsedId,
          name: item['name'] ?? 'Unknown',
          description: item['description'],
          isActive: item['isActive'],
          imageUrl: item['imageUrl'] ?? (item['image']?['url'] ?? ''),
        );
      } else {
        return CategoryModel(
          id: 0,
          name: 'Unknown',
          description: null,
          isActive: false,
          imageUrl: '',
        );
      }
    }).toList();

    allCategories.sort((a, b) => a.id.compareTo(b.id));

    if (_searchController.text.isEmpty) {
      return allCategories;
    }
    final kw = _searchController.text.toLowerCase();
    return allCategories.where((c) => c.name.toLowerCase().contains(kw)).toList();
  }

  void _confirmDeleteCategory(CategoryModel category) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete "${category.name}"?\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);

              // TODO: gọi API / Provider xóa category
              // await context.read<CategoryProvider>().deleteCategory(category.id);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Category "${category.name}" deleted'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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

  void _showCategoryForm(CategoryModel category) {
    print('showCategoryForm: Category data = ${category.toJson()} (FE Action)');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            category.name,
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
            child: CategoryForm(
              buttonLabel: 'Save',
              initialCategory: category,
              onSubmit: (updatedCategoryData) async {
                print('Submit category update: $updatedCategoryData (FE Action)');
                await Future.delayed(const Duration(milliseconds: 300));
                context.pop();
              },
              onDelete: () async {
                print('Delete category: ${category.id} (FE Action)');
                await Future.delayed(const Duration(milliseconds: 300));
                context.pop();
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

  TableRow buildCategoryRow(CategoryModel category, List<double> colWidths) {
    final isMobile = Responsive.isMobile(context);

    String getShortId(String id) {
      return id.length > 5 ? id.substring(0, 5) : id;
    }

    return TableRow(
      children: [
        InkWell(
          onTap: () => _showCategoryForm(category),
          child: cellText(getShortId(category.id.toString()), colWidths[0]),
        ),
        InkWell(
          onTap: () => _showCategoryForm(category),
          child: categoryCell(category, colWidths[1]),
        ),
        Container(
          width: colWidths[2],
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✏️ EDIT
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange),
                tooltip: 'Edit Category',
                onPressed: () => _showCategoryForm(category),
              ),

              // 🗑️ DELETE
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Delete Category',
                onPressed: () => _confirmDeleteCategory(category),
              ),
            ],
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

  Widget categoryCell(CategoryModel category, double width) {
    String getShortId(String id) {
      return id.length > 5 ? id.substring(0, 5) : id;
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
            child: category.imageUrl != null && category.imageUrl.isNotEmpty
                ? Image.network(
              category.imageUrl,
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
                  category.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                Text(
                  'ID: ${getShortId(category.id.toString())}',
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

        final List<double> colWidths = Responsive.isMobile(context)
            ? [tableWidth * 0.20, tableWidth * 0.55, tableWidth * 0.25]
            : [
          tableWidth * 0.15,
          tableWidth * 0.65,
          tableWidth * 0.15,
        ];

        final headers = Responsive.isMobile(context)
            ? ['ID', 'Category', 'Actions']
            : ['ID', 'Category', 'Actions'];

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
                    'Category List',
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
                      ...filteredCategories
                          .map((category) => buildCategoryRow(category, colWidths)),
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