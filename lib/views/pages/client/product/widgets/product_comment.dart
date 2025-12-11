import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:recomart/components/custom/pagination.dart';
import 'package:recomart/components/custom/skeleton.dart';
import 'package:recomart/components/custom/snackbar.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/views/pages/client/login/widgets/button.dart';

class CommentModel {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Anonymous',
      content: json['content'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt']) ?? DateTime.now(),
    );
  }
}

class CommentService {
  Future<List<CommentModel>> fetchComments(String productId) async {
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }

  Future<CommentModel> postComment({
    required String productId,
    required String content,
    required String userId,
    required String userName,
  }) async {
    // TODO: Thay bằng lệnh gọi API POST thực tế
    await Future.delayed(const Duration(seconds: 1)); 
    
    // Giả lập server trả về comment vừa tạo
    return CommentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      userName: userName,
      content: content,
      createdAt: DateTime.now(),
    );
  }
}

// --- 3. UI: Giao diện chính ---

String formatDate(DateTime date) {
  return DateFormat('yyyy-MM-dd HH:mm').format(date);
}

class ProductComment extends StatefulWidget {
  final String productId;

  const ProductComment({
    super.key,
    required this.productId,
  });

  @override
  State<ProductComment> createState() => _ProductCommentState();
}

class _ProductCommentState extends State<ProductComment> {
  final TextEditingController _commentController = TextEditingController();
  final CommentService _commentService = CommentService();
  
  List<CommentModel> _comments = [];
  bool _isLoadingList = true;
  bool _isSending = false;
  
  int currentPage = 1;
  int limit = 5;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    try {
      final data = await _commentService.fetchComments(widget.productId);
      if (mounted) {
        setState(() {
          _comments = data;
          _comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _isLoadingList = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingList = false);
    }
  }

  Future<void> _addComment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      showCustomSnackBar(context, 'You need to login to comment!', type: SnackBarType.error);
      return;
    }

    final content = _commentController.text.trim();
    if (content.isEmpty) {
      showCustomSnackBar(context, 'Please enter a comment', type: SnackBarType.error);
      return;
    }

    setState(() => _isSending = true);

    try {
      final newComment = await _commentService.postComment(
        productId: widget.productId,
        content: content,
        userId: user.uid,
        userName: user.displayName ?? user.email ?? 'User',
      );

      setState(() {
        _comments.insert(0, newComment);
        _commentController.clear();
      });

      showCustomSnackBar(context, 'Comment posted successfully!', type: SnackBarType.success);
    } catch (e) {
      showCustomSnackBar(context, 'Failed to post comment: $e', type: SnackBarType.error);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalPage = (_comments.length / limit).ceil();
    final int safeTotalPage = totalPage > 0 ? totalPage : 1;
    
    final paginatedComments = _comments
        .skip((currentPage - 1) * limit)
        .take(limit)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Reviews & Comments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${_comments.length} comments',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Input Field
        TextField(
          controller: _commentController,
          maxLines: 2,
          enabled: !_isSending,
          decoration: InputDecoration(
            hintText: 'Share your thoughts about this product...',
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // Send Button
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 120,
            child: MyButton(
              text: 'Post',
              isLoading: _isSending,
              onTap: (_) => _addComment(),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 10),

        // List Comments
        if (_isLoadingList)
           ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, __) => const SkeletonHorizontalProduct(), 
            )
        else if (_comments.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('No comments yet. Be the first to review!', style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          Column(
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: paginatedComments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final comment = paginatedComments[index];
                  return _buildCommentItem(comment);
                },
              ),
              const SizedBox(height: 20),
              
              // Pagination Control
              if (_comments.length > limit)
                PaginationWidget(
                  currentPage: currentPage,
                  totalPages: safeTotalPage,
                  onPageChanged: (page) {
                    setState(() => currentPage = page);
                  },
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildCommentItem(CommentModel comment) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  comment.userName.isNotEmpty ? comment.userName[0].toUpperCase() : 'A',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      formatDate(comment.createdAt),
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            comment.content,
            style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}