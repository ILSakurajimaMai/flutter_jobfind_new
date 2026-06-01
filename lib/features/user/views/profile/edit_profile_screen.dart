import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:app_jobfind/features/user/models/profile_dto.dart';
import 'package:app_jobfind/features/auth/viewmodels/auth_provider.dart';
import 'package:app_jobfind/features/user/viewmodels/profile_provider.dart';

/// Màn hình Chỉnh sửa Hồ Sơ (Edit Profile Screen)
/// Cho phép người dùng chỉnh sửa thông tin cá nhân (Tên, ngày sinh, giới tính, địa điểm)
/// và tương tác lưu dữ liệu lên hệ thống qua API.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();

  int _selectedGender = 1; // 1: Male, 2: Female
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _populateData(); // Tự động điền dữ liệu ngay lập tức từ bộ nhớ đệm
      ref.read(profileProvider.notifier).fetchProfile();
    });
  }

  /// Hàm tự động bóc tách thông tin từ hệ thống (profileProvider) và điền sẵn vào Form
  /// Giúp người dùng khi ấn vào Edit thấy thông tin cũ của mình thay vì một form trắng.
  void _populateData() {
    final profileState = ref.read(profileProvider);
    final authState = ref.read(authProvider);

    if (profileState.profile != null) {
      final p = profileState.profile!;
      _nameController.text = p.fullName ?? '';
      _locationController.text = p.address ?? '';
      _phoneController.text = p.phoneNumber ?? '';
      _selectedGender = 1; // Gender is moved to CV

      if (p.dateOfBirth != null) {
        _selectedDate = DateTime.tryParse(p.dateOfBirth!);
        if (_selectedDate != null) {
          _dobController.text = DateFormat(
            'dd MMMM yyyy',
          ).format(_selectedDate!);
        }
      }
    } else if (authState.user != null) {
      // Dành cho tài khoản Employer cũ chưa có profile trong DB, lấy FullName từ thông tin đăng nhập
      _nameController.text = authState.user!.fullName ?? '';
    }

    if (authState.user != null) {
      _emailController.text = authState.user!.email;
    }
  }

  /// Gọi Dialog Lịch chuẩn của hệ điều hành (DatePicker) cho phép cuộn chọn ngày sinh.
  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF14003E), // Màu tiêu đề picker
              onPrimary: Colors.white, // Màu chữ ngày tháng
              onSurface: Colors.black, // Màu lịch
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
        _dobController.text = DateFormat('dd MMMM yyyy').format(date);
      });
    }
  }

  /// Hàm kiểm tra và lưu dữ liệu bằng cách khởi tạo Model và gọi lên Provider
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final fullName = _nameController.text.trim();

    final dto = ProfileDto(
      fullName: fullName,
      address: _locationController.text.trim(),
      dateOfBirth: _selectedDate?.toIso8601String(),
      phoneNumber: _phoneController.text.trim(),
    );

    final success = await ref.read(profileProvider.notifier).updateProfile(dto);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ref.read(profileProvider).error ?? 'Error updating'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Xây dựng bố cục chứa vô số `TextFormField` nhập liệu dọc theo màn hình.
  @override
  Widget build(BuildContext context) {
    ref.listen<ProfileState>(profileProvider, (prev, next) {
      if (prev?.isLoading == true && next.isLoading == false) {
        _populateData();
      }
    });

    final profileState = ref.watch(profileProvider);
    final user = ref.watch(authProvider).user;
    final userName = profileState.profile?.fullName ?? user?.fullName ?? 'User';

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Stack(
              children: [
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF331D61), Color(0xFF14003E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: 16),
                                const Text(
                                  'My Profile',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.white,
                              // Replace with actual image url if exists
                              child: Text(
                                userName.isNotEmpty
                                    ? userName.substring(0, 1).toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontSize: 30,
                                  color: Color(0xFF14003E),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    profileState.profile?.address ?? '',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Change image',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (profileState.isLoading && profileState.profile == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 50.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Fullname'),
                      _buildTextField(
                        _nameController,
                        hint: 'John Doe',
                        textInputAction: TextInputAction.next,
                      ),

                      const SizedBox(height: 16),
                      _buildLabel('Date of birth'),
                      GestureDetector(
                        onTap: _selectDate,
                        child: AbsorbPointer(
                          child: _buildTextField(
                            _dobController,
                            hint: '04 September 2004',
                            suffixIcon: Icons.calendar_today_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      _buildLabel('Gender'),
                      Row(
                        children: [
                          Expanded(child: _buildRadio(1, 'Male')),
                          const SizedBox(width: 16),
                          Expanded(child: _buildRadio(2, 'Female')),
                        ],
                      ),

                      const SizedBox(height: 16),
                      _buildLabel('Email address'),
                      _buildTextField(
                        _emailController,
                        hint: 'email@gmail.com',
                        readOnly: true,
                      ),

                      const SizedBox(height: 16),
                      _buildLabel('Phone number'),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 15,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: const [
                                Text(
                                  '+84',
                                  style: TextStyle(color: Colors.black87),
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildTextField(
                              _phoneController,
                              hint: '123456789',
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      _buildLabel('Location'),
                      _buildTextField(
                        _locationController,
                        hint: 'Hanoi, Vietnam',
                        textInputAction: TextInputAction.done,
                      ),

                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: profileState.isLoading ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF14003E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: profileState.isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'SAVE',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Color(0xFF14003E),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    String? hint,
    IconData? suffixIcon,
    bool readOnly = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
        style: TextStyle(color: readOnly ? Colors.grey : Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          suffixIcon: suffixIcon != null
              ? Icon(suffixIcon, color: const Color(0xFF14003E))
              : null,
        ),
        validator: (val) {
          if (!readOnly && (val == null || val.isEmpty)) {
            return 'Required field';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildRadio(int value, String label) {
    final isSelected = _selectedGender == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: const Color(0xFFFDAE5C), width: 1.5)
              : Border.all(color: Colors.transparent, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFFFDAE5C) : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
