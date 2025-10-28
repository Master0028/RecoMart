import 'package:flutter/material.dart';

class InformationProduct extends StatelessWidget {
  InformationProduct({
    super.key,
    this.scrollController,
  });

  final ScrollController? scrollController;
  final ScrollController _scrollController = ScrollController(); 

  Widget _buildPlaceholder(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.blueGrey.shade700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController ?? _scrollController, 
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      children: [
        const SizedBox(height: 15),
        
        _buildPlaceholder('Product Title Section'), 
        
        const SizedBox(height: 15),
        const SizedBox(height: 15),
        
        _buildPlaceholder('Version and Price: Surface Pro 7 | 14,900,000đ'), 

        const SizedBox(height: 15),
      ],
    );
  }
}