import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:go_router/go_router.dart';
import 'package:recomart/components/custom/my_text_field.dart';
import 'package:recomart/components/custom/snackbar.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/models/user.model.dart';
import 'package:recomart/provider/user_provider.dart';
import 'package:recomart/services/app_exceptions.dart';
import 'package:recomart/services/user.service.dart';
import 'package:recomart/utils/responsive.dart';
import 'package:recomart/utils/widget/CustomAppBarMobile.dart';
import 'package:recomart/views/pages/client/login/widgets/button.dart';
import 'package:recomart/views/pages/client/login/widgets/otp_input.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  List<Map<String, dynamic>> myAccountItems = [
    {'title': 'Personal Information', 'icon': CupertinoIcons.person, 'type': 'auth'},
    {'title': 'My Utilities', 'icon': CupertinoIcons.square_grid_2x2, 'type': 'general'},
    {'title': 'Change Password', 'icon': CupertinoIcons.lock, 'type': 'auth'},
    {'title': 'Address', 'icon': CupertinoIcons.location_north, 'type': 'general'},
    {'title': 'Switch Account/Logout', 'icon': CupertinoIcons.arrow_right_square, 'type': 'auth'},
  ];

  Future<void> fetchUserInfo() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadUserData();
  }
  
  // Hàm xử lý Đăng xuất
  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); 
    if (!mounted) return;
    Provider.of<UserProvider>(context, listen: false).clearUserData(); 
    showCustomSnackBar(context, 'Logged out successfully!', type: SnackBarType.success);
    context.go('/login');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        fetchUserInfo();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, value, child) {
        final isExistUser = value.userModel != null;
        final userInfo = value.userModel;

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
                          MaterialPageRoute(builder: (context) => ChangePassword()),
                        );
                        break;
                      case 'Address':
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddressPage()),
                        );
                        break;
                      case 'Switch Account/Logout':
                        if (isExistUser) {
                          _handleLogout();
                        } else {
                          showCustomSnackBar(context, 'Chuyển đến màn hình Đăng nhập', type: SnackBarType.info);
                          context.push('/login');
                        }
                        break;
                    }
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}

class PersonelInformation extends StatefulWidget {
  const PersonelInformation({super.key, required this.userInfo});
  final UserModel? userInfo;

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

  UserService userService = UserService();

  bool _isLoading = false;
  File? _selectedFile;
  Uint8List? _selectedImageBytes;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        if (!mounted) return; 
        setState(() {
          _selectedImageBytes = bytes;
          _selectedFile = null;
        });
      } else {
        if (!mounted) return; 
        setState(() {
          _selectedFile = File(pickedFile.path);
          _selectedImageBytes = null;
        });
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedFile = null;
      _selectedImageBytes = null;
    });
  }

  Future<void> handleChangeInfomation() async {
    final fullName = _fullNameController.text.trim();
    final phone = _phoneNumberController.text.trim();
    final address = _addressController.text.trim();

    if (fullName.isEmpty || address.isEmpty) {
      if (!mounted) return; 
      showCustomSnackBar(context, 'Please fill in all required fields',
          type: SnackBarType.error);
      return;
    }

    if (!mounted) return; 
    setState(() => _isLoading = true);

    try {
      dynamic uploadedAvatar;
        if (_selectedFile != null) {
        uploadedAvatar = await userService.uploadAvatar(file: _selectedFile!);
      } else if (_selectedImageBytes != null) {
        uploadedAvatar = await userService.uploadAvatar(
            bytes: _selectedImageBytes, filename: 'avatar.jpg');
      }

      await userService.updateUserInfo(
        fullName: fullName,
        phone: phone,
        address: address,
        avatar: uploadedAvatar,
      );

      if (!mounted) return; 
      await Provider.of<UserProvider>(context, listen: false).loadUserData();

      if (!mounted) return; 
      showCustomSnackBar(context, 'Information updated successfully',
          type: SnackBarType.success);
    } on FetchDataException catch (e) {
      debugPrint('Failed to update info: ${e.message}');
      if (!mounted) return; 
      showCustomSnackBar(context, 'Failed to update information',
          type: SnackBarType.error);
    } finally {
      if (!mounted) return; 
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.userInfo != null) {
      _fullNameController.text = widget.userInfo!.fullName;
      _phoneNumberController.text = widget.userInfo!.phone ?? '';
      _addressController.text = widget.userInfo!.address ?? '';
      _emailController.text = widget.userInfo!.email;
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
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomAppBarMobile(
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
                                : (widget.userInfo != null &&
                                        widget.userInfo!.avatar.url.isNotEmpty
                                    ? NetworkImage(widget.userInfo!.avatar.url)
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

            // Form Fields
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

            // Nút Save
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 200, maxWidth: 350),
              child: MyButton(
                text: 'Update Information',
                isLoading: _isLoading,
                onTap: (_) => {handleChangeInfomation()},
              ),
            ),
            const SizedBox(height: 16),
            
            // Nút Change Password (Đã bổ sung)
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 200, maxWidth: 350),
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChangePassword()),
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

// ========================================================================
// CHANGE PASSWORD (SỬA LỖI OVERFLOW VÀ CHUYỂN LOGIC NHẬP MẬT KHẨU MỚI)
// ChangePassword giờ đây là màn hình nhập OTP/Yêu cầu đổi mật khẩu
// ========================================================================
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
  
  // Hành động giả định: Gửi OTP thành công và chuyển sang màn hình nhập mật khẩu mới
  void _verifyOtpAndNavigate() {
    String otp = otp1Controller.text + otp2Controller.text + otp3Controller.text + otp4Controller.text;
    if (otp.length == 4) {
      if (!mounted) return;
      showCustomSnackBar(context, 'Verification successful! Please enter new password.', type: SnackBarType.success);
      context.push('/change-password');
    } else {
      if (!mounted) return;
      showCustomSnackBar(context, 'Please enter the full 4-digit code.', type: SnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBarMobile(
        title: 'Verify Code',
        isBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Center( // Thêm Center để căn giữa nội dung trên màn hình lớn
          child: SizedBox(
            width: Responsive.isMobile(context) ? double.infinity : 400, // Giới hạn chiều rộng
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

                // OTP Inputs
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround, // Dùng spaceAround thay vì spaceBetween để tránh căng quá mức trên màn hình nhỏ
                  children: [
                    OtpInput(controller: otp1Controller, autoFocus: true),
                    OtpInput(controller: otp2Controller),
                    OtpInput(controller: otp3Controller),
                    OtpInput(controller: otp4Controller),
                  ],
                ),
                const SizedBox(height: 30),

                // Nút Get Code (Kiểm tra OTP)
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

// ========================================================================
// ADDRESS PAGE (GIỮ NGUYÊN)
// ========================================================================
class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  List<dynamic> provinces = [];
  List<dynamic> districts = [];
  List<dynamic> wards = [];
  String? selectedProvinceCode;
  String? selectedDistrictCode;
  String? selectedWardCode;
  String currentAddress = '';
  String _addressOption = 'saved';
  bool _addNewAddress = false;
  List<String> savedAddresses = [];

  @override
  void initState() {
    super.initState();
    loadSavedLocation();
    fetchProvinces();
    getSavedAddresses();
  }

  Future<void> loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return; 
    setState(() {
      currentAddress = prefs.getString('location_current') ?? 'No address set';
    });
  }

  Future<void> getSavedAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> checkSavedAddresses =
        prefs.getStringList('manual_location') ?? [];
    if (currentAddress != 'No address set' && !checkSavedAddresses.contains(currentAddress)) {
      checkSavedAddresses.add(currentAddress);
      await prefs.setStringList('manual_location', checkSavedAddresses);
    }
    if (!mounted) return; 
    setState(() {
      savedAddresses = checkSavedAddresses;
    });
  }

  Future<void> fetchProvinces() async {
    try {
      final res = await http
          .get(Uri.parse('https://provinces.open-api.vn/api/?depth=1'));
      if (res.statusCode == 200) {
        if (!mounted) return; 
        setState(() {
          provinces = jsonDecode(utf8.decode(res.bodyBytes));
        });
      } else {
        throw Exception('Failed to load provinces');
      }
    } catch (e) {
      debugPrint('Error loading provinces: $e');
    }
  }

  Future<void> fetchDistricts(String provinceCode) async {
    try {
      final res = await http.get(Uri.parse(
          'https://provinces.open-api.vn/api/p/$provinceCode?depth=2'));
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        if (!mounted) return; 
        setState(() {
          districts = data['districts'];
        });
      } else {
        throw Exception('Failed to load districts');
      }
    } catch (e) {
      debugPrint('Error loading districts: $e');
    }
  }

  Future<void> fetchWards(String districtCode) async {
    try {
      final res = await http.get(Uri.parse(
          'https://provinces.open-api.vn/api/d/$districtCode?depth=2'));
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        if (!mounted) return; 
        setState(() {
          wards = data['wards'];
        });
      } else {
        throw Exception('Failed to load wards');
      }
    } catch (e) {
      debugPrint('Error loading wards: $e');
    }
  }

  Future<void> saveLocationToPreferences(String newAddress) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedAddresses = prefs.getStringList('manual_location') ?? [];
    if (!savedAddresses.contains(newAddress)) {
      savedAddresses.add(newAddress);
      await prefs.setStringList('manual_location', savedAddresses);
    }
  }
  
  // Helper Widget cho Dropdown
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
        labelText: label,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomAppBarMobile(
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

                  // Saved Addresses
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
                          onChanged: (value) async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString('location_current', value!);
                            if (!mounted) return;
                            setState(() {
                              currentAddress = value;
                              _addressOption = 'saved';
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                      ),
                    );
                  }).toList(), 

                  // Add New Address Toggle
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

                  // Dropdowns (nếu mở)
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
                                districts = [];
                                wards = [];
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
                                wards = [];
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
                              onTap: (_) async {
                                if (selectedWardCode == null || selectedDistrictCode == null || selectedProvinceCode == null) {
                                  showCustomSnackBar(context, 'Please select a complete address', type: SnackBarType.error);
                                  return;
                                }

                                String getNameByCode(List<dynamic> list, String? code) {
                                  return list.firstWhere(
                                    (item) => item['code'].toString() == code,
                                    orElse: () => {'name': 'Unknown'},
                                  )['name'];
                                }

                                String newAddress =
                                    '${getNameByCode(wards, selectedWardCode)}, ${getNameByCode(districts, selectedDistrictCode)}, ${getNameByCode(provinces, selectedProvinceCode)}';

                                await saveLocationToPreferences(newAddress);
                                await getSavedAddresses();
                                showCustomSnackBar(context, 'New address added', type: SnackBarType.success);

                                if (!mounted) return;
                                setState(() {
                                  _addNewAddress = false;
                                  selectedProvinceCode = null;
                                  selectedDistrictCode = null;
                                  selectedWardCode = null;
                                  districts = [];
                                  wards = [];
                                });
                              },
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