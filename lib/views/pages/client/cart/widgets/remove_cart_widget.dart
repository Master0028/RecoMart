import 'package:recomart/config/color.dart';
import 'package:recomart/models/cart.model.dart';
import 'package:flutter/material.dart';

class RemoveCartWidget extends StatefulWidget {
  const RemoveCartWidget({
    super.key,
    required this.cartItems,
    required this.itemToRemove,
    required this.cancelRemoveItem,
    required this.quantityToRemove,
    required this.removeItem,
  });

  final List<ProductForCartModel> cartItems;
  final int? itemToRemove;
  final VoidCallback cancelRemoveItem;
  final int quantityToRemove;
  final VoidCallback removeItem;

  @override
  State<RemoveCartWidget> createState() => _RemoveCartWidgetState();
}

class _RemoveCartWidgetState extends State<RemoveCartWidget> {
  // Biến để điều khiển vị trí trượt (cho animation)
  double _bottomOffset = -200.0; // Khởi tạo ngoài màn hình (ẩn)

  @override
  void initState() {
    super.initState();
    // Bắt đầu animation trượt lên sau khi widget được xây dựng
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _bottomOffset = 0.0; // Trượt vào vị trí 0
      });
    });
  }

  // Hàm tạo hiệu ứng trượt xuống (biến mất)
  void _startDismissAnimation() {
    setState(() {
      _bottomOffset = -200.0;
    });
    // Gọi hàm cancel/remove sau khi animation kết thúc (khoảng 300ms)
    Future.delayed(const Duration(milliseconds: 300), widget.cancelRemoveItem);
  }

  @override
  Widget build(BuildContext context) {
    // SỬA LỖI: Thay thế .variantName bằng .name (hoặc tên trường chính xác của bạn)
    final productName = widget.itemToRemove != null && widget.itemToRemove! < widget.cartItems.length
        ? widget.cartItems[widget.itemToRemove!].name // <-- ĐÃ SỬA LỖI
        : 'Product';

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300), // Thời gian animation
      curve: Curves.easeInOutCubic, // Hiệu ứng mượt mà, công nghệ
      bottom: _bottomOffset,
      left: 0.0,
      right: 0.0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), // Tăng padding dưới
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
            // Hàng nút bấm
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Nút Cancel (màu xanh dương chủ đạo)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton( // Dùng OutlinedButton cho nút phụ
                        onPressed: _startDismissAnimation, // Gọi hàm trượt xuống
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
                // Nút Remove (màu đỏ nổi bật)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Gọi hàm trượt xuống trước khi xóa
                          _startDismissAnimation();
                          widget.removeItem(); // Logic xóa sản phẩm
                        },
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
                          backgroundColor: Colors.red.shade700, // Đỏ đậm hơn
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8, // Tăng shadow
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