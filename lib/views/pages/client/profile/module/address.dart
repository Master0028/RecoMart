import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recomart/components/custom/snackbar.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/utils/widget/CustomAppBarMobile.dart';
import 'package:recomart/views/pages/client/login/widgets/button.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  // Mock Data (Translated)
  final List<dynamic> provinces = [
    {'code': 1, 'name': 'Ho Chi Minh City'},
    {'code': 2, 'name': 'Hanoi'}
  ];
  final List<dynamic> districts = [
    {'code': 101, 'name': 'District 1'},
    {'code': 102, 'name': 'Ba Dinh District'}
  ];
  final List<dynamic> wards = [
    {'code': 1001, 'name': 'Ben Nghe Ward'},
    {'code': 1002, 'name': 'Cong Vi Ward'}
  ];
  
  String? selectedProvinceCode;
  String? selectedDistrictCode;
  String? selectedWardCode;
  String currentAddress = '123 Nguyen Hue Street, Ben Nghe Ward, District 1, HCMC';
  bool _addNewAddress = false;
  
  List<String> savedAddresses = [
    '123 Nguyen Hue Street, Ben Nghe Ward, District 1, HCMC',
    '456 Le Loi Street, Cong Vi Ward, Ba Dinh District, Hanoi'
  ]; 

  @override
  void initState() {
    super.initState();
    if (savedAddresses.isNotEmpty) {
      currentAddress = savedAddresses[0];
    }
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
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
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
          child: Text(item['name'], style: const TextStyle(color: Colors.black87, fontSize: 15)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
  
  Future<void> _handleSaveLocation() async {
      if (selectedWardCode == null || selectedDistrictCode == null || selectedProvinceCode == null) {
        showCustomSnackBar(context, 'Please fill in all address fields', type: SnackBarType.error);
        return;
      }

      String getSelectedName(List list, String? code) {
          if (code == null) return '';
          return list.firstWhere((item) => item['code'].toString() == code, orElse: () => {'name': ''})['name'];
      }

      String newAddress = '${getSelectedName(wards, selectedWardCode)}, ${getSelectedName(districts, selectedDistrictCode)}, ${getSelectedName(provinces, selectedProvinceCode)}';
      
      showCustomSnackBar(context, 'New address added successfully', type: SnackBarType.success);

      if (!mounted) return;
      setState(() {
          savedAddresses.add(newAddress);
          currentAddress = newAddress;
          _addNewAddress = false;
          selectedProvinceCode = null;
          selectedDistrictCode = null;
          selectedWardCode = null;
      });
  }
  
  void _handleCancelAddNew() {
    setState(() {
      _addNewAddress = false;
      selectedProvinceCode = null;
      selectedDistrictCode = null;
      selectedWardCode = null;
    });
  }


  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black87
        ),
      ),
    );
  }

  Widget _buildSavedAddressCard(String address) {
    bool isSelected = (currentAddress == address);
    
    return GestureDetector(
      onTap: () {
        if (!mounted) return;
        setState(() {
          currentAddress = address;
        });
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            width: isSelected ? 2.0 : 1.0,
          )
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Icon(
              isSelected ? CupertinoIcons.house_fill : CupertinoIcons.house,
              color: AppColors.primary,
              size: 28,
            ),
            title: Text(
              address.split(',')[0], 
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              address, 
              style: const TextStyle(color: Colors.black54, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Radio<String>(
              value: address,
              groupValue: currentAddress,
              onChanged: (value) {
                if (!mounted) return;
                setState(() {
                  currentAddress = value!;
                });
              },
              activeColor: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const CustomAppBarMobile(
        title: 'Address Management',
        isBack: true,
      ),
      body: Center( 
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Saved Addresses'),
                
                ...savedAddresses.map((address) {
                  return _buildSavedAddressCard(address);
                }).toList(), 

                ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  title: Text(
                    _addNewAddress ? 'Close' : 'Add New Address',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16),
                  ),
                  trailing: Icon(
                    _addNewAddress ? CupertinoIcons.minus_circle_fill : CupertinoIcons.add_circled_solid,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  onTap: () {
                    setState(() {
                      _addNewAddress = !_addNewAddress;
                    });
                  },
                ),

                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Visibility(
                    visible: _addNewAddress,
                    child: Card(
                      elevation: 2,
                      shadowColor: Colors.black.withOpacity(0.1),
                      margin: const EdgeInsets.only(top: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            _buildAddressDropdown(
                              label: 'Province/City',
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
                              label: 'Ward/Commune',
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
                                text: 'Save Address',
                                onTap: (_) => _handleSaveLocation(),
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                onPressed: _handleCancelAddNew,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ),                                    
                          ],
                        ),
                      ),
                    ),
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