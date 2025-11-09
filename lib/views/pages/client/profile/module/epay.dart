import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/utils/widget/CustomAppBarMobile.dart';
import 'package:recomart/components/custom/snackbar.dart';

class EWallet {
  final String id;
  final String type;
  final String accountName;
  final String accountNumber;
  bool isDefault;

  EWallet({
    required this.id,
    required this.type,
    required this.accountName,
    required this.accountNumber,
    this.isDefault = false,
  });
}

final List<EWallet> _mockWallets = [
  EWallet(
    id: '1',
    type: 'MOMO',
    accountName: 'Nguyễn Văn Đạt',
    accountNumber: '0901234567',
    isDefault: true,
  ),
  EWallet(
    id: '2',
    type: 'ZALOPAY',
    accountName: 'Nguyễn Văn Đạt',
    accountNumber: '0901234567',
  ),
];

class EWalletPage extends StatefulWidget {
  const EWalletPage({super.key});

  @override
  State<EWalletPage> createState() => _EWalletPageState();
}

class _EWalletPageState extends State<EWalletPage> {
  late List<EWallet> _wallets;

  @override
  void initState() {
    super.initState();
    _wallets = List.from(_mockWallets);
  }

  void _handleSetDefault(int index) {
    setState(() {
      for (var wallet in _wallets) {
        wallet.isDefault = false;
      }
      _wallets[index].isDefault = true;
    });
    showCustomSnackBar(context, 'Đã đặt ${_wallets[index].type} làm mặc định',
        type: SnackBarType.success);
  }

  void _handleDelete(int index) {
    final removedWallet = _wallets[index];
    setState(() {
      _wallets.removeAt(index);
    });
    showCustomSnackBar(context, 'Đã xóa ví ${removedWallet.type}',
        type: SnackBarType.error);
  }

  void _handleSaveWallet(EWallet? wallet, String type, String name, String phone) {
  if (name.isEmpty || phone.isEmpty) {
    showCustomSnackBar(context, 'Vui lòng nhập đầy đủ thông tin',
        type: SnackBarType.error);
    return;
  }

  setState(() {
    if (wallet == null) {
      _wallets.add(EWallet(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: type,
        accountName: name,
        accountNumber: phone,
      ));
    } else {
      final updatedWallet = EWallet(
        id: wallet.id,
        type: type,
        accountName: name,
        accountNumber: phone,
        isDefault: wallet.isDefault,
      );
      
      final index = _wallets.indexWhere((w) => w.id == wallet.id);
      if (index != -1) {
        _wallets[index] = updatedWallet;
      }
    }
  });

  Navigator.of(context).pop();
}

  void _showWalletFormDialog({EWallet? initialWallet}) {
    final isEditing = initialWallet != null;
    String _selectedType = initialWallet?.type ?? 'MOMO';
    final _nameController = TextEditingController(text: initialWallet?.accountName ?? '');
    final _phoneController = TextEditingController(text: initialWallet?.accountNumber ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          title: Center(
            child: Text(
              isEditing ? 'Chỉnh Sửa Ví' : 'Liên Kết Ví Mới',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Chọn loại ví
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: _buildInputDecoration(label: 'Loại ví'),
                    items: ['MOMO', 'ZALOPAY', 'VNPAY']
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setStateDialog(() {
                          _selectedType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // 2. Tên chủ ví
                  TextFormField(
                    controller: _nameController,
                    decoration: _buildInputDecoration(label: 'Tên chủ ví', icon: FeatherIcons.user),
                  ),
                  const SizedBox(height: 16),
                  
                  // 3. Số điện thoại
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _buildInputDecoration(label: 'Số điện thoại', icon: FeatherIcons.phone),
                  ),
                ],
              );
            },
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          actions: [
            // Nút Hủy
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Hủy Bỏ',
                style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            // Nút Lưu
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                _handleSaveWallet(
                  initialWallet,
                  _selectedType,
                  _nameController.text,
                  _phoneController.text,
                );
              },
              child: const Text(
                'Lưu',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper cho InputDecoration
  InputDecoration _buildInputDecoration({required String label, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: AppColors.primary, size: 20) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: const CustomAppBarMobile(
        title: 'Ví Điện Tử Của Tôi',
        isBack: true,
      ),
      body: Center( // ⬅️ Đảm bảo Responsive
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800), // Giới hạn chiều rộng
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- DANH SÁCH VÍ ---
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _wallets.length,
                  itemBuilder: (context, index) {
                    final wallet = _wallets[index];
                    return _WalletCard(
                      wallet: wallet,
                      onSetDefault: () => _handleSetDefault(index),
                      onEdit: () => _showWalletFormDialog(initialWallet: wallet),
                      onDelete: () => _handleDelete(index),
                    );
                  },
                ),
                
                const SizedBox(height: 20),

                // --- NÚT THÊM MỚI ---
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(FeatherIcons.plus, size: 20),
                    label: const Text(
                      'Liên Kết Ví Mới',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      _showWalletFormDialog();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 🎨 WIDGET THẺ VÍ (HIỆN ĐẠI)
class _WalletCard extends StatelessWidget {
  final EWallet wallet;
  final VoidCallback onSetDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _WalletCard({
    required this.wallet,
    required this.onSetDefault,
    required this.onEdit,
    required this.onDelete,
  });

  // Helper để lấy màu và logo
  Map<String, dynamic> _getWalletVisuals(String type) {
    switch (type) {
      case 'MOMO':
        return {'color': const Color(0xFFAE2070), 'icon': Icons.payment}; // (Thay bằng logo MoMo)
      case 'ZALOPAY':
        return {'color': const Color(0xFF0056C0), 'icon': Icons.account_balance_wallet};
      case 'VNPAY':
        return {'color': const Color(0xFF003D7C), 'icon': Icons.qr_code};
      default:
        return {'color': Colors.grey, 'icon': Icons.wallet};
    }
  }

  // Helper che số điện thoại
  String _maskPhone(String phone) {
    if (phone.length > 6) {
      return '${phone.substring(0, 3)}***${phone.substring(phone.length - 3)}';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    final visuals = _getWalletVisuals(wallet.type);
    
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: visuals['color'].withOpacity(0.3),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              visuals['color'].withOpacity(0.85),
              visuals['color'],
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hàng Header: Tên ví và Menu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(visuals['icon'] as IconData, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        wallet.type,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // Nút 3 chấm (Menu)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'delete') onDelete();
                      if (value == 'default') onSetDefault();
                    },
                    icon: const Icon(FeatherIcons.moreVertical, color: Colors.white),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(children: [Icon(FeatherIcons.edit, size: 18, color: Colors.black87), SizedBox(width: 10), Text('Chỉnh Sửa')]),
                      ),
                      if (!wallet.isDefault)
                        const PopupMenuItem<String>(
                          value: 'default',
                          child: Row(children: [Icon(FeatherIcons.checkCircle, size: 18, color: Colors.black87), SizedBox(width: 10), Text('Đặt làm mặc định')]),
                        ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(children: [Icon(FeatherIcons.trash2, size: 18, color: Colors.red), SizedBox(width: 10), Text('Xóa liên kết', style: TextStyle(color: Colors.red))]),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Tên Chủ Ví
              const Text(
                'Chủ ví',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Text(
                wallet.accountName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                'Số điện thoại',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Text(
                _maskPhone(wallet.accountNumber),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              
              if (wallet.isDefault)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'MẶC ĐỊNH',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}