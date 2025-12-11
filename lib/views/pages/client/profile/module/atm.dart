import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppColors {
  static const Color primary = Color(0xFF4A90E2);
  static const Color black = Colors.black87;
  static const Color white = Colors.white;
}

class CustomAppBarMobile extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isBack;
  const CustomAppBarMobile({super.key, required this.title, this.isBack = false});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: const TextStyle(color: Colors.black87)),
      backgroundColor: Colors.white,
      elevation: 1,
      iconTheme: const IconThemeData(color: Colors.black87),
      leading: isBack ? IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: () => Navigator.of(context).pop(),
      ) : null,
    );
  }
}

class Responsive {
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1000;
  }
}

class _MockCard {
  final String id;
  String cardHolder;
  String cardNumber;
  String expiryDate;
  String cvv;
  String type;

  _MockCard({
    required this.id,
    required this.cardHolder,
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.type,
  });
}

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<_MockCard> _savedCards = [
    _MockCard(
      id: '1',
      cardHolder: 'NGUYEN VAN DAT',
      cardNumber: '**** **** **** 1234',
      expiryDate: '12/26',
      cvv: '123',
      type: 'visa',
    ),
    _MockCard(
      id: '2',
      cardHolder: 'RECOMART USER',
      cardNumber: '**** **** **** 5678',
      expiryDate: '09/25',
      cvv: '456',
      type: 'mastercard',
    ),
  ];

  void _showCardFormModal(BuildContext context, { _MockCard? cardToEdit }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _AddOrEditCardForm(
          card: cardToEdit,
          onSave: (newCard) {
            setState(() {
              if (cardToEdit != null) {
                final index = _savedCards.indexWhere((c) => c.id == newCard.id);
                if (index != -1) {
                  _savedCards[index] = newCard;
                }
              } else {
                _savedCards.add(newCard);
              }
            });
            Navigator.pop(context); 
          },
          onDelete: (cardId) {
            setState(() {
              _savedCards.removeWhere((c) => c.id == cardId);
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: const CustomAppBarMobile(
        title: 'Payment Methods',
        isBack: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              bool isDesktop = constraints.maxWidth > 700;
              int crossAxisCount = constraints.maxWidth > 1000 ? 3 : 2;

              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(24.0),
                    sliver: isDesktop
                        ? _buildDesktopGrid(crossAxisCount)
                        : _buildMobileList(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMobileList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == _savedCards.length) {
            return _AddCardTile(onTap: () => _showCardFormModal(context));
          }
          final card = _savedCards[index];
          return _CreditCardWidget(
            card: card,
            onEdit: () => _showCardFormModal(context, cardToEdit: card),
          );
        },
        childCount: _savedCards.length + 1,
      ),
    );
  }

  Widget _buildDesktopGrid(int crossAxisCount) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.6, // Tỉ lệ thẻ
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == _savedCards.length) {
            return _AddCardTile(onTap: () => _showCardFormModal(context));
          }
          final card = _savedCards[index];
          return _CreditCardWidget(
            card: card,
            onEdit: () => _showCardFormModal(context, cardToEdit: card),
          );
        },
        childCount: _savedCards.length + 1,
      ),
    );
  }
}

class _CreditCardWidget extends StatelessWidget {
  final _MockCard card;
  final VoidCallback onEdit;

  const _CreditCardWidget({required this.card, required this.onEdit});
  
  Widget _buildCardTypeLogo() {
    if (card.type == 'visa') {
      return SvgPicture.network(
        'https://upload.wikimedia.org/wikipedia/commons/5/5e/Visa_Inc._logo.svg',
        width: 60,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        placeholderBuilder: (_) => const SizedBox(width: 60, height: 20),
      );
    } else if (card.type == 'mastercard') {
      return SvgPicture.network(
        'https://upload.wikimedia.org/wikipedia/commons/2/2a/Mastercard-logo.svg',
        width: 50,
        placeholderBuilder: (_) => const SizedBox(width: 50, height: 30),
      );
    }
    return const SizedBox(width: 50, height: 30);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: card.type == 'visa'
                ? [const Color(0xFF1A2980), const Color(0xFF26D0CE)]
                : [const Color(0xFF2C3E50), const Color(0xFFFD746C)],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.contactless_outlined, color: Colors.white, size: 30),
                IconButton(
                  icon: const Icon(FeatherIcons.edit, color: Colors.white, size: 20),
                  onPressed: onEdit,
                  tooltip: 'Edit Card',
                ),
              ],
            ),
            
            Text(
              card.cardNumber,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: 3,
                fontFamily: 'monospace',
              ),
            ),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Card Holder',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        card.cardHolder,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Expires',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        card.expiryDate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildCardTypeLogo(),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// Thiết kế lại Tile Thêm Mới
class _AddCardTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddCardTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade400, width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FeatherIcons.plus, color: AppColors.primary, size: 40),
              const SizedBox(height: 12),
              Text(
                'Add New Card',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Form Thêm/Sửa Thẻ
class _AddOrEditCardForm extends StatefulWidget {
  final _MockCard? card;
  final Function(_MockCard) onSave;
  final Function(String) onDelete;

  const _AddOrEditCardForm({this.card, required this.onSave, required this.onDelete});

  @override
  State<_AddOrEditCardForm> createState() => _AddOrEditCardFormState();
}

class _AddOrEditCardFormState extends State<_AddOrEditCardForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _numberController;
  late TextEditingController _expiryController;
  late TextEditingController _cvvController;
  String _cardType = 'visa';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.card?.cardHolder ?? '');
    _numberController = TextEditingController(text: widget.card?.cardNumber ?? '');
    _expiryController = TextEditingController(text: widget.card?.expiryDate ?? '');
    _cvvController = TextEditingController(text: widget.card?.cvv ?? '');
    _cardType = widget.card?.type ?? 'visa';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }
  
  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final newCard = _MockCard(
        id: widget.card?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        cardHolder: _nameController.text,
        cardNumber: _numberController.text,
        expiryDate: _expiryController.text,
        cvv: _cvvController.text,
        type: _cardType,
      );
      widget.onSave(newCard);
    }
  }

  @override
  Widget build(BuildContext context) {
    // SỬA LỖI TRÀN: Bọc nội dung trong SingleChildScrollView
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.card == null ? 'Add New Card' : 'Edit Card',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                
                // Form Fields
                TextFormField(
                  controller: _nameController,
                  decoration: _buildInputDecoration('Cardholder Name', FeatherIcons.user),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _numberController,
                  decoration: _buildInputDecoration('Card Number', FeatherIcons.creditCard),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _expiryController,
                        decoration: _buildInputDecoration('Expiry (MM/YY)', FeatherIcons.calendar),
                        keyboardType: TextInputType.datetime,
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _cvvController,
                        decoration: _buildInputDecoration('CVV', FeatherIcons.lock),
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save Card', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                if (widget.card != null)
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => widget.onDelete(widget.card!.id),
                      child: const Text(
                        'Delete Card',
                        style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade600),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
      ),
    );
  }
}