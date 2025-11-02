import 'package:flutter/material.dart';
import 'package:recomart/components/custom/pagination.dart';
import 'package:recomart/components/custom/skeleton.dart';
import 'package:recomart/components/custom/snackbar.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/helpers/formatMoney.dart'; 
import 'package:recomart/views/pages/client/login/widgets/button.dart';

String formatDate(String date) {
  return '2 hours ago';
}

class ReviewModelFE {
  final String content;
  final String createdAt;
  final String userName;

  ReviewModelFE({required this.content, required this.createdAt, required this.userName});
}

final List<ReviewModelFE> FE_MOCK_COMMENTS = [
];

class ProductComment extends StatefulWidget {
  const ProductComment({
    super.key,
    this.isLoading = false,
  });
  
  final dynamic socketService = null; 
  final String productId = '';
  final List<dynamic> comments = const [];
  final bool isLoading;

  @override
  State<ProductComment> createState() => _ProductCommentState();
}

class _ProductCommentState extends State<ProductComment> {
  final TextEditingController _commentController = TextEditingController();
  bool isSending = false;
  int currentPage = 1;
  int limit = 3;

  void _addComment() {
    setState(() {
      isSending = true;
    });
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      showCustomSnackBar(context, 'Please enter a comment');
      setState(() {
        isSending = false;
      });
      return;
    }

    try {      
      showCustomSnackBar(
          context,
          'Comment sent (FE Action)',
          type: SnackBarType.success
      );
      
      setState(() {
        _commentController.clear();
      });
    } catch (e) {
      showCustomSnackBar(context, 'Failed to add comment. Please try again.');
    }
    setState(() {
      isSending = false;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> allComments = FE_MOCK_COMMENTS; 

    final int totalPage = allComments.length > limit ? (allComments.length / limit).ceil() : 1;

    final commentPagination =
        allComments.skip((currentPage - 1) * limit).take(limit).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comments',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          cursorColor: Colors.black,
          controller: _commentController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Leave a comment',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 12),
        MyButton(
          text: 'Send',
          isLoading: isSending,
          onTap: (_) {
            _addComment();
          },
        ),
        const SizedBox(height: 12),
        widget.isLoading
            ? ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) => const SkeletonHorizontalProduct(),
              )
            : commentPagination.isEmpty
                ? const Center(
                    child: Text('No comments yet'),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: commentPagination.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final comment = commentPagination[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          tileColor: Colors.grey[100],
                          leading: const CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.black12,
                            child: Icon(Icons.person, color: Colors.black),
                          ),
                          title: Text(comment.userName ?? 'Anonymous'), 
                          subtitle: Text(comment.content ?? 'Comment content'),
                          trailing: Text(
                            formatDate(comment.createdAt.toString()),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  ),
        const SizedBox(height: 10),
        PaginationWidget(
          currentPage: currentPage,
          totalPages: totalPage,
          onPageChanged: (page) {
            setState(() {
              currentPage = page;
            });
          },
        ),
      ],
    );
  }
}