import 'package:flutter/material.dart';
import 'package:recomart/config/color.dart';

class RemoveCartWidget extends StatefulWidget {
  const RemoveCartWidget({
    super.key,
    required this.cartItems,
    required this.itemToRemove,
    required this.cancelRemoveItem, 
    required this.quantityToRemove,
    required this.removeItem,
  });

  final List<dynamic> cartItems; 
  final int? itemToRemove;
  
  final VoidCallback cancelRemoveItem;
  final VoidCallback removeItem;

  final int quantityToRemove;

  @override
  State<RemoveCartWidget> createState() => _RemoveCartWidgetState();
}

class _RemoveCartWidgetState extends State<RemoveCartWidget> {
  double _bottomOffset = -200.0; 
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _bottomOffset = 0.0; 
      });
    });
  }

  void _startDismissAnimation() {
    setState(() {
      _bottomOffset = -200.0;
    });
    Future.delayed(const Duration(milliseconds: 300), widget.cancelRemoveItem);
  }
  
  void _startRemoveAnimation() {
      setState(() {
        _bottomOffset = -200.0;
      });
      Future.delayed(const Duration(milliseconds: 300), widget.removeItem);
  }


  @override
  Widget build(BuildContext context) {
    final productName = widget.itemToRemove != null && widget.itemToRemove! < widget.cartItems.length
        ? widget.cartItems[widget.itemToRemove!].name 
        : 'Product';

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300), 
      curve: Curves.easeInOutCubic, 
      bottom: _bottomOffset,
      left: 0.0,
      right: 0.0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), 
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dòng thông báo hiện đại
            Text(
              'Remove ${widget.quantityToRemove}x "$productName"?',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton( 
                        onPressed: _startDismissAnimation,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _startRemoveAnimation,
                        icon: const Icon(Icons.delete_outline, color: Colors.white),
                        label: const Text(
                          'Remove',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700, 
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8, 
                          shadowColor: Colors.red.shade900.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}