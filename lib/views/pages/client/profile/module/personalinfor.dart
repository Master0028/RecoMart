import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:recomart/components/custom/my_text_field.dart';
import 'package:recomart/components/custom/snackbar.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/utils/widget/CustomAppBarMobile.dart';
import 'package:recomart/views/pages/client/login/widgets/button.dart';
import '../../../../../provider/user_provider.dart';

class PersonelInformationPage extends StatefulWidget {
  const PersonelInformationPage({super.key, this.userInfo});
  final Map<String, dynamic>? userInfo;

  @override
  State<PersonelInformationPage> createState() => _PersonelInformationPageState();
}

class _PersonelInformationPageState extends State<PersonelInformationPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final FocusNode _fullNameFocusNode = FocusNode();
  final FocusNode _phoneNumberFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();

  bool _isLoading = false;
  File? _selectedFile;
  Uint8List? _selectedImageBytes;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.fetchUserInfo();
      final user = userProvider.userInfo; // ✅ Lấy từ Firestore model

      if (user != null) {
        _fullNameController.text = user.fullName;
        _emailController.text = user.email;
        _phoneNumberController.text = user.phone ?? '';
        _addressController.text = user.address ?? '';
      }
    });
  }

  Future<void> handleChangeInfomation() async {
    final fullName = _fullNameController.text.trim();
    if (fullName.isEmpty) {
      if (!mounted) return;
      showCustomSnackBar(context, 'Please fill in Full Name', type: SnackBarType.error);
      return;
    }

    setState(() => _isLoading = true);

    // 🔹 Cập nhật Firestore qua Provider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.updateUserInfo(
      name: _fullNameController.text,
      phone: _phoneNumberController.text,
      address: _addressController.text,
    );

    if (!mounted) return;
    showCustomSnackBar(context, 'Information updated successfully', type: SnackBarType.success);
    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    showCustomSnackBar(context, 'Image Picker disabled', type: SnackBarType.info);
  }

  void _removeImage() {
    setState(() {
      _selectedFile = null;
      _selectedImageBytes = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.userInfo; 
    final avatarUrl = user?.avatar ?? widget.userInfo?['avatar']?['url'];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const CustomAppBarMobile(
        title: 'Personal Information',
        isBack: true,
      ),
      body: userProvider.loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: _selectedFile != null
                            ? FileImage(_selectedFile!)
                            : (_selectedImageBytes != null
                            ? MemoryImage(_selectedImageBytes!)
                            : (avatarUrl != null && avatarUrl.isNotEmpty
                            ? NetworkImage(avatarUrl)
                            : const AssetImage('assets/logo/logo.png')))
                        as ImageProvider,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: IconButton(
                          padding: const EdgeInsets.all(8),
                          onPressed: () {
                            if (_selectedFile != null || _selectedImageBytes != null) {
                              _removeImage();
                            } else {
                              _pickImage();
                            }
                          },
                          icon: Icon(
                            (_selectedFile != null || _selectedImageBytes != null)
                                ? CupertinoIcons.xmark
                                : CupertinoIcons.camera,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 30),

                // Form
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        _buildLabeledTextField(
                          label: 'Full Name',
                          controller: _fullNameController,
                          focusNode: _fullNameFocusNode,
                          hint: 'Seibon',
                          icon: CupertinoIcons.person,
                        ),
                        _buildLabeledTextField(
                          label: 'Phone Number',
                          controller: _phoneNumberController,
                          focusNode: _phoneNumberFocusNode,
                          hint: 'Phone Number',
                          icon: CupertinoIcons.phone,
                          fieldType: TextInputType.phone,
                        ),
                        _buildLabeledTextField(
                          label: 'Email (Disabled)',
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          hint: 'example@gmail.com',
                          icon: CupertinoIcons.envelope,
                          disable: true,
                        ),
                        _buildLabeledTextField(
                          label: 'Address',
                          controller: _addressController,
                          focusNode: _addressFocusNode,
                          hint: 'District 1, HCM City',
                          icon: CupertinoIcons.location,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 350),
                  child: Column(
                    children: [
                      MyButton(
                        text: 'Update Information',
                        isLoading: _isLoading,
                        onTap: (_) => {handleChangeInfomation()},
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () {
                          context.pop();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: AppColors.primary, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size(double.infinity, 0),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabeledTextField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    TextInputType? fieldType,
    bool disable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          MyTextField(
            hintText: hint,
            prefixIcon: icon,
            controller: controller,
            focusNode: focusNode,
            obscureText: false,
            disable: disable,
            fieldType: fieldType ?? TextInputType.text,
          ),
        ],
      ),
    );
  }
}
