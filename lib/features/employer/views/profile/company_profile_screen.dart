import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_jobfind/features/employer/models/company_dto.dart';
import 'package:app_jobfind/features/employer/viewmodels/company_provider.dart';

class CompanyProfileScreen extends ConsumerStatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  ConsumerState<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends ConsumerState<CompanyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _industryController = TextEditingController();
  final _employeeCountController = TextEditingController();
  final _taxCodeController = TextEditingController();
  final _websiteController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _foundedYear;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(companyProvider.notifier).fetchMyCompany();
    });
  }

  void _populateData() {
    final state = ref.read(companyProvider);
    if (state.company != null) {
      final c = state.company!;
      _nameController.text = c.name;
      _industryController.text = c.industry ?? '';
      _employeeCountController.text = c.employeeCount?.toString() ?? '';
      _taxCodeController.text = c.taxCode ?? '';
      _websiteController.text = c.website ?? '';
      _addressController.text = c.address ?? '';
      _descriptionController.text = c.description ?? '';
      _foundedYear = c.foundedYear;
    }
  }

  Future<void> _selectYear() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF14003E),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _foundedYear = picked.toIso8601String();
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Kiểm tra nếu đang chờ duyệt thì không cho lưu
    final currentState = ref.read(companyProvider);
    if (currentState.isPendingApproval) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hồ sơ đang chờ Admin phê duyệt, không thể chỉnh sửa lúc này'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final dto = CompanyDto(
      name: _nameController.text.trim(),
      industry: _industryController.text.trim(),
      employeeCount: int.tryParse(_employeeCountController.text.trim()),
      taxCode: _taxCodeController.text.trim(),
      website: _websiteController.text.trim(),
      address: _addressController.text.trim(),
      description: _descriptionController.text.trim(),
      foundedYear: _foundedYear,
    );

    final wasNewRequest = !currentState.isPendingApproval && (currentState.company?.isVerified != true);

    final success = await ref.read(companyProvider.notifier).saveCompany(dto);
    if (mounted) {
      if (success) {
        // Nếu vừa gửi yêu cầu mới (chưa phải công ty được duyệt)
        final newState = ref.read(companyProvider);
        if (wasNewRequest && newState.isPendingApproval) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Yêu cầu đăng ký công ty đã được gửi! Vui lòng chờ Admin phê duyệt.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );
          // Không pop vì cần user thấy trạng thái pending
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật thông tin công ty thành công'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ref.read(companyProvider).error ?? 'Lỗi cập nhật'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CompanyState>(companyProvider, (prev, next) {
      if (prev?.isLoading == true && next.isLoading == false && next.company != null) {
        _populateData();
      }
    });

    final state = ref.watch(companyProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        title: const Text('Hồ sơ Công ty', style: TextStyle(color: Color(0xFF14003E), fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black54),
        centerTitle: true,
      ),
      body: state.isLoading && state.company == null
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF14003E)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.isPendingApproval)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Hồ sơ công ty của bạn đang chờ Admin phê duyệt. Bạn sẽ không thể cập nhật thông tin lúc này.',
                                style: TextStyle(color: Colors.deepOrange, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade300),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
                            ),
                            child: const Icon(Icons.business, size: 50, color: Colors.grey),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: Color(0xFFFDAE5C), shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    _buildLabel('Tên công ty *'),
                    _buildTextField(_nameController, hint: 'Tên hiển thị trên tin tuyển dụng', isRequired: true),
                    const SizedBox(height: 16),
                    
                    _buildLabel('Ngành nghề'),
                    _buildTextField(_industryController, hint: 'IT, Marketing, v.v.'),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Quy mô (NV)'),
                              _buildTextField(_employeeCountController, hint: '100', keyboardType: TextInputType.number),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Năm thành lập'),
                              GestureDetector(
                                onTap: _selectYear,
                                child: AbsorbPointer(
                                  child: _buildTextField(
                                    TextEditingController(text: _foundedYear != null ? DateTime.parse(_foundedYear!).year.toString() : ''),
                                    hint: 'YYYY',
                                    suffixIcon: Icons.calendar_today,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    _buildLabel('Mã số thuế'),
                    _buildTextField(_taxCodeController, hint: 'Nhập mã số thuế doanh nghiệp'),
                    const SizedBox(height: 16),
                    
                    _buildLabel('Website'),
                    _buildTextField(_websiteController, hint: 'https://...', keyboardType: TextInputType.url),
                    const SizedBox(height: 16),
                    
                    _buildLabel('Địa chỉ'),
                    _buildTextField(_addressController, hint: 'Địa chỉ trụ sở'),
                    const SizedBox(height: 16),
                    
                    _buildLabel('Mô tả công ty'),
                    _buildTextField(_descriptionController, hint: 'Giới thiệu ngắn gọn về văn hóa, môi trường làm việc...', maxLines: 4),
                    const SizedBox(height: 32),

                    if (!state.isPendingApproval)
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: state.isLoading ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF14003E),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: state.isLoading
                              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('LƯU THÔNG TIN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
                        ),
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF14003E))),
    );
  }

  Widget _buildTextField(TextEditingController controller, {String? hint, IconData? suffixIcon, TextInputType? keyboardType, bool isRequired = false, int maxLines = 1}) {
    final state = ref.watch(companyProvider);
    return Container(
      decoration: BoxDecoration(
        color: state.isPendingApproval ? Colors.grey.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: state.isPendingApproval,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: maxLines > 1 ? 16 : 15),
          suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.grey, size: 20) : null,
        ),
        validator: isRequired ? (val) => (val == null || val.isEmpty) ? 'Trường này bắt buộc' : null : null,
      ),
    );
  }
}
