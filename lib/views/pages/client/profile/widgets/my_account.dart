import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recomart/components/custom/my_text_field.dart';
import 'package:recomart/components/custom/snackbar.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/utils/responsive.dart';
import 'package:recomart/utils/widget/CustomAppBarMobile.dart';
import 'package:recomart/views/pages/client/login/widgets/button.dart';
import 'package:recomart/views/pages/client/login/widgets/otp_input.dart';

final Map<String, dynamic> FE_USER_INFO = {
  'fullName': 'FE User Name',
  'email': 'fe.user@email.com',
  'phone': '0123456789',
  'address': 'District 1, HCM City',
  'avatar': {'url': 'https://picsum.photos/200'},
};


class ModernAccountListTile extends StatelessWidget {
  const ModernAccountListTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        trailing: Icon(
          CupertinoIcons.chevron_forward,
          color: Colors.grey.shade400,
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }
}

class MyAccountView extends StatefulWidget {
  const MyAccountView({super.key});

  @override
  State<MyAccountView> createState() => _MyAccountView();
}

class _MyAccountView extends State<MyAccountView> {
  final bool isExistUser = true; 
  final Map<String, dynamic>? userInfo = FE_USER_INFO;
  
  List<Map<String, dynamic>> myAccountItems = [
    {'title': 'Personal Information', 'icon': CupertinoIcons.person, 'type': 'auth'},
    {'title': 'My Utilities', 'icon': CupertinoIcons.square_grid_2x2, 'type': 'general'},
    {'title': 'Change Password', 'icon': CupertinoIcons.lock, 'type': 'auth'},
    {'title': 'Address', 'icon': CupertinoIcons.location_north, 'type': 'general'},
    {'title': 'Switch Account/Logout', 'icon': CupertinoIcons.arrow_right_square, 'type': 'auth'},
  ];
  
  Future<void> _handleLogout() async {
    showCustomSnackBar(context, 'Logged out successfully! (FE Action)', type: SnackBarType.success);
    context.go('/login');
    debugPrint('FE: Navigated to /login');
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    final visibleItems = List<Map<String, dynamic>>.from(myAccountItems).where((item) {
      if (item['title'] == 'Personal Information' || item['title'] == 'Change Password') {
        return isExistUser;
      }
      if (item['title'] == 'Switch Account/Logout') {
        return true;
      }
      return true;
    }).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...visibleItems.map((item) {
            return ModernAccountListTile(
              icon: item['icon'],
              title: item['title'] == 'Switch Account/Logout' 
                  ? (isExistUser ? 'Đăng Xuất' : 'Switch Account/Logout') 
                  : item['title'],
              onTap: () {
                switch (item['title']) {
                  case 'Personal Information':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PersonelInformation(userInfo: userInfo),
                      ),
                    );
                    break;
                  case 'My Utilities':
                    showCustomSnackBar(context, 'Chuyển đến trang Tiện ích của tôi', type: SnackBarType.info);
                    break;
                  case 'Change Password':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChangePassword()),
                    );
                    break;
                  case 'Address':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddressPage()),
                    );
                    break;
                  case 'Switch Account/Logout':
                    if (isExistUser) {
                      _handleLogout();
                    } else {
                      showCustomSnackBar(context, 'Chuyển đến màn hình Đăng nhập', type: SnackBarType.info);
                      context.push('/login');
                      debugPrint('FE: Navigated to /login');
                    }
                    break;
                }
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}

class PersonelInformation extends StatefulWidget {
  const PersonelInformation({super.key, required this.userInfo});
  final Map<String, dynamic>? userInfo; 

  @override
  State<PersonelInformation> createState() => _PersonelInformationState();
}

class _PersonelInformationState extends State<PersonelInformation> {
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

  Future<void> _pickImage() async {
    showCustomSnackBar(context, 'Image Picker disabled', type: SnackBarType.info);
  }

  void _removeImage() {
    setState(() {
      _selectedFile = null;
      _selectedImageBytes = null;
    });
  }

  Future<void> handleChangeInfomation() async {
    final fullName = _fullNameController.text.trim();
    final address = _addressController.text.trim();

    if (fullName.isEmpty || address.isEmpty) {
      if (!mounted) return; 
      showCustomSnackBar(context, 'Please fill in all required fields (FE Check)',
          type: SnackBarType.error);
      return;
    }

    if (!mounted) return; 
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return; 
    showCustomSnackBar(context, 'Information updated successfully (FE Success)',
        type: SnackBarType.success);
    
    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    if (widget.userInfo != null) {
      // Dùng cú pháp Map access
      _fullNameController.text = widget.userInfo!['fullName'] ?? '';
      _phoneNumberController.text = widget.userInfo!['phone'] ?? '';
      _addressController.text = widget.userInfo!['address'] ?? '';
      _emailController.text = widget.userInfo!['email'] ?? '';
    }
  }
  
  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _fullNameFocusNode.dispose();
    _phoneNumberFocusNode.dispose();
    _addressFocusNode.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = widget.userInfo?['avatar']?['url'];
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const CustomAppBarMobile(
        title: 'Personal Information',
        isBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
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
                    border: Border.all(
                      color: AppColors.primary,
                      width: 4,
                    ),
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
                        if (_selectedFile != null ||
                            _selectedImageBytes != null) {
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

            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
                      label: 'Email',
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
            const SizedBox(height: 24),

            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 200, maxWidth: 350),
              child: MyButton(
                text: 'Update Information',
                isLoading: _isLoading,
                onTap: (_) => {handleChangeInfomation()},
              ),
            ),
            const SizedBox(height: 16),
            
            // Nút Change Password 
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 200, maxWidth: 350),
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChangePassword()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.primary, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Change Password',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
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
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
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

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController otp1Controller = TextEditingController();
  final TextEditingController otp2Controller = TextEditingController();
  final TextEditingController otp3Controller = TextEditingController();
  final TextEditingController otp4Controller = TextEditingController();
  
  void _verifyOtpAndNavigate() {
    String otp = otp1Controller.text + otp2Controller.text + otp3Controller.text + otp4Controller.text;
    if (otp.length == 4) {
      if (!mounted) return;
      showCustomSnackBar(context, 'Verification successful! (FE Action)', type: SnackBarType.success);
      context.push('/change-password');
      debugPrint('FE: Navigated to New Password Screen');
    } else {
      if (!mounted) return;
      showCustomSnackBar(context, 'Please enter the full 4-digit code. (FE Check)', type: SnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBarMobile(
        title: 'Verify Code',
        isBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Center( 
          child: SizedBox(
            width: Responsive.isMobile(context) ? double.infinity : 400, 
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter your verification code!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please enter the code sent to your email address.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround, 
                  children: [
                    OtpInput(controller: otp1Controller, autoFocus: true),
                    OtpInput(controller: otp2Controller),
                    OtpInput(controller: otp3Controller),
                    OtpInput(controller: otp4Controller),
                  ],
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: MyButton(
                    text: 'Verify Code',
                    isLoading: false,
                    onTap: (_) => {_verifyOtpAndNavigate()},
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
}

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  // Dữ liệu tỉnh thành giả lập (FE Stub)
  final List<dynamic> provinces = [{'code': 1, 'name': 'Province A'}, {'code': 2, 'name': 'Province B'}];
  final List<dynamic> districts = [{'code': 101, 'name': 'District X'}, {'code': 102, 'name': 'District Y'}];
  final List<dynamic> wards = [{'code': 1001, 'name': 'Ward M'}, {'code': 1002, 'name': 'Ward N'}];
  
  String? selectedProvinceCode;
  String? selectedDistrictCode;
  String? selectedWardCode;
  String currentAddress = 'No address set';
  String _addressOption = 'saved';
  bool _addNewAddress = false;
  
  List<String> savedAddresses = ['FE Saved Address 1', 'FE Saved Address 2']; 

  @override
  void initState() {
    super.initState();
  }
  
  Future<void> fetchProvinces() async { debugPrint('FE: Fetched provinces stub'); }
  Future<void> fetchDistricts(String provinceCode) async { debugPrint('FE: Fetched districts stub for $provinceCode'); }
  Future<void> fetchWards(String districtCode) async { debugPrint('FE: Fetched wards stub for $districtCode'); }


  Widget _buildAddressDropdown({
    required String label,
    required String? value,
    required List<dynamic> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      dropdownColor: Colors.white,
      value: value,
      decoration: InputDecoration(
        labelText: '$label',
        labelStyle: const TextStyle(color: Colors.black54),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.5), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      items: items.map<DropdownMenuItem<String>>((item) {
        return DropdownMenuItem<String>(
          value: item['code'].toString(),
          child: Text(item['name'], style: const TextStyle(color: Colors.black87)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
  
  Future<void> _handleSaveLocation() async {
      if (selectedWardCode == null || selectedDistrictCode == null || selectedProvinceCode == null) {
        showCustomSnackBar(context, 'Please select a complete address (FE Check)', type: SnackBarType.error);
        return;
      }

      String getNameByCode(List<dynamic> list, String? code) {
          return 'Selected Name';
      }

      String newAddress = 'FE New Address: Ward/Dist/Prov';
      
      showCustomSnackBar(context, 'New address added (FE Success)', type: SnackBarType.success);

      if (!mounted) return;
      setState(() {
          savedAddresses.add(newAddress);
          _addNewAddress = false;
          selectedProvinceCode = null;
          selectedDistrictCode = null;
          selectedWardCode = null;
      });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const CustomAppBarMobile(
        title: 'Address',
        isBack: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  kToolbarHeight, 
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Location
                  const Text(
                    'Current Location',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withOpacity(0.1),
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      title: const Text('Device Location', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(currentAddress, style: TextStyle(color: Colors.black54)),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Saved Addresses',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 8),

                  ...savedAddresses.map((address) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        leading: Icon(CupertinoIcons.house_alt, color: AppColors.primary),
                        title: const Text('Location', style: TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(address, style: TextStyle(color: Colors.black54)),
                        trailing: Radio<String>(
                          value: address,
                          groupValue: currentAddress,
                          onChanged: (value) {
                            // LOẠI BỎ: Logic SharedPreferences
                            if (!mounted) return;
                            setState(() {
                              currentAddress = value!;
                              _addressOption = 'saved';
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                      ),
                    );
                  }).toList(), 

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Add New Address',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    trailing: Icon(
                      _addNewAddress ? CupertinoIcons.minus : CupertinoIcons.add_circled_solid,
                      color: AppColors.primary,
                    ),
                    onTap: () {
                      setState(() {
                        _addNewAddress = !_addNewAddress;
                      });
                    },
                  ),

                  if (_addNewAddress)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        children: [
                          _buildAddressDropdown(
                            label: 'Province',
                            value: selectedProvinceCode,
                            items: provinces,
                            onChanged: (value) {
                              if (!mounted) return;
                              setState(() {
                                selectedProvinceCode = value;
                                selectedDistrictCode = null;
                                selectedWardCode = null;
                              });
                              if (value != null) fetchDistricts(value);
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildAddressDropdown(
                            label: 'District',
                            value: selectedDistrictCode,
                            items: districts,
                            onChanged: (value) {
                              if (!mounted) return;
                              setState(() {
                                selectedDistrictCode = value;
                                selectedWardCode = null;
                              });
                              if (value != null) fetchWards(value);
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildAddressDropdown(
                            label: 'Ward',
                            value: selectedWardCode,
                            items: wards,
                            onChanged: (value) {
                              setState(() {
                                selectedWardCode = value;
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: MyButton(
                              text: 'Save Location',
                              onTap: (_) => _handleSaveLocation(),
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
      ),
    );
  }
}