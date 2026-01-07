import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:recomart/components/custom/my_text_field.dart';
import 'package:recomart/components/custom/snackbar.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/services/api_service.dart';
import 'package:recomart/utils/widget/CustomAppBarMobile.dart';
import 'package:recomart/views/pages/client/login/widgets/button.dart';
import '../../../../../provider/user_provider.dart';

class PersonelInformationPage extends StatefulWidget {
  const PersonelInformationPage({super.key});

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
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _initializeDataFromFirebase();
  }

  Future<void> _initializeDataFromFirebase() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.id) // 👈 userId hiện tại
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;

    setState(() {
      _fullNameController.text = data['fullName'] ?? '';
      _phoneNumberController.text = data['phone'] ?? '';
      _addressController.text = data['address'] ?? '';
      _emailController.text = data['email'] ?? user.email;
    });
  }


  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> handleChangeInfomation() async {
    final fullName = _fullNameController.text.trim();
    if (fullName.isEmpty) {
      if (!mounted) return;
      showCustomSnackBar(context, 'Full Name is required', type: SnackBarType.error);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;
      if (user == null) throw Exception("User not logged in");

      String? avatarUrl = user.avatar;
      if (_selectedImage != null) {
        final uri = Uri.parse(
          '${ApiService.baseUrl}/api/users/${user.id}/avatar',
        );

        final request = http.MultipartRequest('POST', uri);

        if (kIsWeb) {
          // ✅ FLUTTER WEB
          final bytes = await _selectedImage!.readAsBytes();

          request.files.add(
            http.MultipartFile.fromBytes(
              'file',
              bytes,
              filename: _selectedImage!.name,
            ),
          );
        } else {
          // ✅ ANDROID / IOS
          request.files.add(
            await http.MultipartFile.fromPath(
              'file',
              _selectedImage!.path,
            ),
          );
        }

        final response = await request.send();

        if (response.statusCode != 200) {
          throw Exception("Failed to upload avatar");
        }

        final respStr = await response.stream.bytesToString();
        final respJson = jsonDecode(respStr);

        avatarUrl = respJson['avatar']; // Cloudinary URL
      }

      final updatedUser = user.copyWith(
        fullName: fullName,
        phone: _phoneNumberController.text.trim(),
        address: _addressController.text.trim(),
        avatar: avatarUrl,
      );

      await ApiService.updateUser(updatedUser);

      userProvider.setUser(updatedUser);

      if (!mounted) return;
      showCustomSnackBar(context, 'Information updated successfully', type: SnackBarType.success);
      context.pop();
    } catch (e) {
      if (!mounted) return;
      showCustomSnackBar(context, 'Update failed: $e', type: SnackBarType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final avatarUrl = user?.avatar;

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
                    children: [
                      // Avatar Section
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
                              backgroundImage: _selectedImage != null
                                  ? NetworkImage(_selectedImage!.path) // Web preview OK
                                  : (avatarUrl != null && avatarUrl.isNotEmpty
                                  ? NetworkImage(avatarUrl)
                                  : const AssetImage('assets/logo/logo.png')) as ImageProvider,
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
                                  if (_selectedImage != null) {
                                    _removeImage();
                                  } else {
                                    _pickImage();
                                  }
                                },
                                icon: Icon(
                                  _selectedImage != null ? CupertinoIcons.xmark : CupertinoIcons.camera,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 30),
                      // Fields Section
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              _buildLabeledTextField(
                                label: 'Full Name',
                                controller: _fullNameController,
                                focusNode: _fullNameFocusNode,
                                hint: 'Enter your full name',
                                icon: CupertinoIcons.person,
                              ),
                              _buildLabeledTextField(
                                label: 'Phone Number',
                                controller: _phoneNumberController,
                                focusNode: _phoneNumberFocusNode,
                                hint: 'Enter your phone number',
                                icon: CupertinoIcons.phone,
                                fieldType: TextInputType.phone,
                              ),
                              _buildLabeledTextField(
                                label: 'Email Address',
                                controller: _emailController,
                                focusNode: _emailFocusNode,
                                hint: 'Email cannot be changed',
                                icon: CupertinoIcons.envelope,
                                disable: true,
                              ),
                              _buildLabeledTextField(
                                label: 'Address',
                                controller: _addressController,
                                focusNode: _addressFocusNode,
                                hint: 'Enter your address',
                                icon: CupertinoIcons.location,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Buttons Section
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 350),
                        child: Column(
                          children: [
                            MyButton(
                              text: 'Save Changes',
                              isLoading: _isLoading,
                              onTap: (_) => handleChangeInfomation(),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton(
                              onPressed: () => context.pop(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(color: AppColors.primary, width: 2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                minimumSize: const Size(double.infinity, 0),
                              ),
                              child: const Text(
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
