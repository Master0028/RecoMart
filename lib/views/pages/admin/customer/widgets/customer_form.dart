import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../../provider/user_provider.dart';
import '../../../../../models/user.model.dart';

class CustomerForm extends StatefulWidget {
  final UserModel customer;
  final bool canEditStatus;

  const CustomerForm({
    super.key,
    required this.customer,
    this.canEditStatus = true,
  });

  @override
  State<CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  late bool isActive;
  bool isProcessing = false;
  bool isEditing = false;
  File? imageFile;
  String? uploadedImageUrl;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;
  Uint8List? imageBytes;
  String? imageUrl;

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  @override
  void initState() {
    super.initState();
    final user = widget.customer;
    isActive = user.isActive;
    uploadedImageUrl = user.avatar; // ban đầu là ảnh cũ

    nameController = TextEditingController(text: user.fullName);
    emailController = TextEditingController(text: user.email);
    phoneController = TextEditingController(text: user.phone ?? '');
    addressController = TextEditingController(text: user.address ?? '');
  }

  /// 🔹 Upload ảnh mới lên Cloudinary
  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => isLoading = true);

    try {
      final bytes = await picked.readAsBytes();
      final uri = Uri.parse("https://api.cloudinary.com/v1_1/dqiclelb9/image/upload");
      final uploadPreset = "dacntt";

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: picked.name,
        ));

      final response = await request.send();
      final resBody = await response.stream.bytesToString();
      final data = jsonDecode(resBody);

      if (response.statusCode == 200 && data['secure_url'] != null) {
        setState(() {
          imageBytes = bytes;
          imageUrl = data['secure_url'];
          imageFile = null;
          isLoading = false;
        });
      } else {
        throw Exception("Upload failed: ${data['error']}");
      }
    } catch (e) {
      debugPrint("❌ Upload Cloudinary failed: $e");
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Upload ảnh thất bại')));
      }
    }
  }

  /// 🔹 Cấm / Mở khóa khách hàng
  Future<void> _toggleStatus() async {
    setState(() => isProcessing = true);
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.toggleUserStatus(widget.customer.id, !isActive);
      setState(() => isActive = !isActive);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isActive
              ? 'Đã mở khóa tài khoản khách hàng'
              : 'Đã cấm khách hàng này'),
          backgroundColor: isActive ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi cập nhật trạng thái: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isProcessing = false);
    }
  }

  /// Lưu thay đổi
  Future<void> _saveChanges() async {
    setState(() => isProcessing = true);
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Ưu tiên ảnh mới, nếu có
      final String finalAvatar = imageUrl ?? uploadedImageUrl ?? '';

      final updatedUser = widget.customer.copyWith(
        fullName: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        isActive: isActive,
        avatar: finalAvatar, // ảnh mới sẽ được lưu
      );

      await userProvider.updateUser(updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thông tin khách hàng thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      // cập nhật lại biến để UI hiển thị đúng
      setState(() {
        isEditing = false;
        uploadedImageUrl = finalAvatar;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi lưu thông tin: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isProcessing = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 800,
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🖼️ Avatar
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 300,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Container(
                              width: double.infinity,
                              height: 300,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Builder(
                                  builder: (_) {
                                    // Ưu tiên ảnh URL
                                    if (uploadedImageUrl != null && uploadedImageUrl!.isNotEmpty) {
                                      return Image.network(
                                        uploadedImageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                        const Center(child: Text('Invalid Image URL')),
                                      );
                                    }

                                    // Nếu có bytes — kiểm tra định dạng (PNG/JPEG/SVG)
                                    if (imageBytes != null && imageBytes!.isNotEmpty) {
                                      final header = imageBytes!.take(8).toList();
                                      final isXml = header.length >= 5 &&
                                          header[0] == 0x3c &&
                                          header[1] == 0x3f &&
                                          header[2] == 0x78 &&
                                          header[3] == 0x6d &&
                                          header[4] == 0x6c;

                                      if (isXml) {
                                        return SvgPicture.memory(
                                          imageBytes!,
                                          fit: BoxFit.cover,
                                          placeholderBuilder: (_) =>
                                          const Center(child: CircularProgressIndicator()),
                                        );
                                      }

                                      try {
                                        return Image.memory(
                                          imageBytes!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                          const Center(child: Text('Invalid image data')),
                                        );
                                      } catch (_) {
                                        return const Center(child: Text('Invalid image data'));
                                      }
                                    }

                                    // Nếu có file cục bộ
                                    if (imageFile != null) {
                                      return Image.file(
                                        imageFile!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                        const Center(child: Text('Invalid local file')),
                                      );
                                    }

                                    // Nếu không có ảnh
                                    return const Center(child: Text('No Image'));
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (isEditing)
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.upload),
                              label: const Text("Đổi ảnh"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                              onPressed: _pickImage,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (widget.canEditStatus)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Switch(
                            value: isActive,
                            onChanged:
                            isProcessing ? null : (_) => _toggleStatus(),
                            activeColor: Colors.green,
                            inactiveThumbColor: Colors.red,
                          ),
                          Text(
                            isActive ? 'Đang hoạt động' : 'Đã bị cấm',
                            style: TextStyle(
                              color: isActive ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // 🧾 Thông tin
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputField("Họ và tên", nameController),
                      _buildInputField("Email", emailController),
                      _buildInputField("Số điện thoại", phoneController),
                      _buildInputField("Địa chỉ", addressController),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            icon: Icon(isEditing ? Icons.close : Icons.edit),
                            label:
                            Text(isEditing ? "Hủy chỉnh sửa" : "Chỉnh sửa"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              isEditing ? Colors.grey : Colors.orange,
                              minimumSize: const Size(150, 48),
                            ),
                            onPressed: () {
                              setState(() => isEditing = !isEditing);
                            },
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.save),
                            label: const Text("Lưu thay đổi"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              minimumSize: const Size(180, 48),
                            ),
                            onPressed:
                            isEditing && !isProcessing ? _saveChanges : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (isProcessing)
            const Positioned.fill(
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        enabled: isEditing,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
