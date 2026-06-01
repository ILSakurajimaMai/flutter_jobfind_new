import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_jobfind/features/cv/models/cv_dto.dart';
import 'package:app_jobfind/features/cv/viewmodels/cv_provider.dart';
import 'package:app_jobfind/features/cv/views/widgets/cv_template_impression.dart';
import 'package:app_jobfind/features/cv/views/widgets/cv_template_modern.dart';
import 'package:app_jobfind/features/cv/views/widgets/cv_template_basic.dart';
import 'package:app_jobfind/features/cv/models/cv_dummy_data.dart';

class CvEditScreen extends ConsumerStatefulWidget {
  final String templateType; // 'impression' | 'modern' | 'basic'
  final CvDto? existingCv; // null = tạo mới, non-null = chỉnh sửa
  const CvEditScreen({super.key, required this.templateType, this.existingCv});

  @override
  ConsumerState<CvEditScreen> createState() => _CvEditScreenState();
}

class _CvEditScreenState extends ConsumerState<CvEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // --- Controllers cơ bản ---
  final _titleCtrl = TextEditingController();
  final _targetPosCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _linkedInCtrl = TextEditingController();
  final _gitHubCtrl = TextEditingController();
  // Học vấn sinh viên
  final _studentIdCtrl = TextEditingController();
  final _universityCtrl = TextEditingController();
  final _majorCtrl = TextEditingController();
  final _gpaCtrl = TextEditingController();
  final _yearStudyCtrl = TextEditingController();

  int? _gender; // 0=Nam,1=Nữ,2=Khác
  DateTime? _dateOfBirth;
  DateTime? _expectedGradDate;

  // --- Danh sách động ---
  final List<_SkillEntry> _skills = [];
  final List<_ExpEntry> _experiences = [];
  final List<_EduEntry> _educations = [];
  final List<_CertEntry> _certificates = [];

  @override
  void initState() {
    super.initState();
    final cv = widget.existingCv ?? defaultDummyCv;

    _titleCtrl.text = cv.title ?? '';
    _targetPosCtrl.text = cv.targetPosition ?? '';
    _fullNameCtrl.text = cv.fullName ?? '';
    _emailCtrl.text = cv.email ?? '';
    _phoneCtrl.text = cv.phoneNumber ?? '';
    _addressCtrl.text = cv.address ?? '';
    _bioCtrl.text = cv.bio ?? '';
    _linkedInCtrl.text = cv.linkedInUrl ?? '';
    _gitHubCtrl.text = cv.gitHubUrl ?? '';
    _studentIdCtrl.text = cv.studentId ?? '';
    _universityCtrl.text = cv.university ?? '';
    _majorCtrl.text = cv.major ?? '';
    _gpaCtrl.text = cv.gpa?.toString() ?? '';
    _yearStudyCtrl.text = cv.yearOfStudy?.toString() ?? '';
    _gender = cv.gender;
    _dateOfBirth = cv.dateOfBirth != null
        ? DateTime.tryParse(cv.dateOfBirth!)
        : null;
    _expectedGradDate = cv.expectedGraduationDate != null
        ? DateTime.tryParse(cv.expectedGraduationDate!)
        : null;
    // Pre-fill danh sách kỹ năng
    for (final s in cv.skills ?? []) {
      final entry = _SkillEntry();
      entry.nameCtrl.text = s.skillName;
      entry.yearsCtrl.text = s.yearsOfExperience?.toString() ?? '';
      entry.level = s.proficiencyLevel ?? 3;
      _skills.add(entry);
    }
    // Pre-fill kinh nghiệm
    for (final e in cv.experiences ?? []) {
      final entry = _ExpEntry();
      entry.companyCtrl.text = e.companyName;
      entry.positionCtrl.text = e.position;
      entry.descCtrl.text = e.description ?? '';
      entry.startDate = DateTime.tryParse(e.startDate);
      entry.endDate = e.endDate != null ? DateTime.tryParse(e.endDate!) : null;
      entry.isCurrent = e.isCurrentlyWorking;
      _experiences.add(entry);
    }
    // Pre-fill học vấn
    for (final e in cv.educations ?? []) {
      final entry = _EduEntry();
      entry.institutionCtrl.text = e.institutionName;
      entry.degreeCtrl.text = e.degree;
      entry.fieldCtrl.text = e.fieldOfStudy ?? '';
      entry.gpaCtrl.text = e.gpa?.toString() ?? '';
      entry.descCtrl.text = e.description ?? '';
      entry.startDate = DateTime.tryParse(e.startDate);
      entry.endDate = e.endDate != null ? DateTime.tryParse(e.endDate!) : null;
      _educations.add(entry);
    }
    // Pre-fill chứng chỉ
    for (final c in cv.certificates ?? []) {
      final entry = _CertEntry();
      entry.nameCtrl.text = c.name;
      entry.orgCtrl.text = c.issuingOrganization ?? '';
      entry.credIdCtrl.text = c.credentialId ?? '';
      entry.credUrlCtrl.text = c.credentialUrl ?? '';
      entry.issueDate = c.issueDate != null
          ? DateTime.tryParse(c.issueDate!)
          : null;
      entry.expiryDate = c.expiryDate != null
          ? DateTime.tryParse(c.expiryDate!)
          : null;
      _certificates.add(entry);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _targetPosCtrl.dispose();
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _bioCtrl.dispose();
    _linkedInCtrl.dispose();
    _gitHubCtrl.dispose();
    _studentIdCtrl.dispose();
    _universityCtrl.dispose();
    _majorCtrl.dispose();
    _gpaCtrl.dispose();
    _yearStudyCtrl.dispose();
    super.dispose();
  }

  CvDto _buildDto() => CvDto(
    title: _titleCtrl.text.trim().isEmpty ? null : _titleCtrl.text.trim(),
    targetPosition: _targetPosCtrl.text.trim().isEmpty
        ? null
        : _targetPosCtrl.text.trim(),
    fullName: _fullNameCtrl.text.trim().isEmpty
        ? null
        : _fullNameCtrl.text.trim(),
    email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
    phoneNumber: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
    address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
    bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
    linkedInUrl: _linkedInCtrl.text.trim().isEmpty
        ? null
        : _linkedInCtrl.text.trim(),
    gitHubUrl: _gitHubCtrl.text.trim().isEmpty ? null : _gitHubCtrl.text.trim(),
    studentId: _studentIdCtrl.text.trim().isEmpty
        ? null
        : _studentIdCtrl.text.trim(),
    university: _universityCtrl.text.trim().isEmpty
        ? null
        : _universityCtrl.text.trim(),
    major: _majorCtrl.text.trim().isEmpty ? null : _majorCtrl.text.trim(),
    gpa: double.tryParse(_gpaCtrl.text),
    yearOfStudy: int.tryParse(_yearStudyCtrl.text),
    gender: _gender,
    dateOfBirth: _dateOfBirth?.toIso8601String(),
    expectedGraduationDate: _expectedGradDate?.toIso8601String(),
    skills: _skills
        .map(
          (s) => CvSkillDto(
            skillName: s.nameCtrl.text.trim(),
            proficiencyLevel: s.level,
            yearsOfExperience: int.tryParse(s.yearsCtrl.text),
          ),
        )
        .where((s) => s.skillName.isNotEmpty)
        .toList(),
    experiences: _experiences
        .map(
          (e) => CvExperienceDto(
            companyName: e.companyCtrl.text.trim(),
            position: e.positionCtrl.text.trim(),
            description: e.descCtrl.text.trim().isEmpty
                ? null
                : e.descCtrl.text.trim(),
            startDate:
                e.startDate?.toIso8601String() ??
                DateTime.now().toIso8601String(),
            endDate: e.isCurrent ? null : e.endDate?.toIso8601String(),
            isCurrentlyWorking: e.isCurrent,
          ),
        )
        .where((e) => e.companyName.isNotEmpty && e.position.isNotEmpty)
        .toList(),
    educations: _educations
        .map(
          (e) => CvEducationDto(
            institutionName: e.institutionCtrl.text.trim(),
            degree: e.degreeCtrl.text.trim(),
            fieldOfStudy: e.fieldCtrl.text.trim().isEmpty
                ? null
                : e.fieldCtrl.text.trim(),
            startDate:
                e.startDate?.toIso8601String() ??
                DateTime.now().toIso8601String(),
            endDate: e.endDate?.toIso8601String(),
            gpa: double.tryParse(e.gpaCtrl.text),
            description: e.descCtrl.text.trim().isEmpty
                ? null
                : e.descCtrl.text.trim(),
          ),
        )
        .where((e) => e.institutionName.isNotEmpty && e.degree.isNotEmpty)
        .toList(),
    certificates: _certificates
        .map(
          (c) => CvCertificateDto(
            name: c.nameCtrl.text.trim(),
            issuingOrganization: c.orgCtrl.text.trim().isEmpty
                ? null
                : c.orgCtrl.text.trim(),
            issueDate: c.issueDate?.toIso8601String(),
            expiryDate: c.expiryDate?.toIso8601String(),
            credentialId: c.credIdCtrl.text.trim().isEmpty
                ? null
                : c.credIdCtrl.text.trim(),
            credentialUrl: c.credUrlCtrl.text.trim().isEmpty
                ? null
                : c.credUrlCtrl.text.trim(),
          ),
        )
        .where((c) => c.name.isNotEmpty)
        .toList(),
  );

  Widget _buildPreview(CvDto dto) {
    Widget tpl;
    switch (widget.templateType) {
      case 'modern':
        tpl = CvTemplateModern(cvData: dto);
        break;
      case 'basic':
        tpl = CvTemplateBasic(cvData: dto);
        break;
      default:
        tpl = CvTemplateImpression(cvData: dto);
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320, maxHeight: 453),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: AbsorbPointer(
            child: FittedBox(
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              child: tpl,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final dto = _buildDto();
      final existingId = widget.existingCv?.id;
      if (existingId != null) {
        await ref.read(cvProvider.notifier).updateCv(existingId, dto);
      } else {
        await ref.read(cvProvider.notifier).createCvFromDto(dto);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Lưu CV thành công!'),
            backgroundColor: Color(0xFF0D9D58),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        title: Text(
          widget.existingCv != null ? 'Chỉnh sửa CV' : 'Tạo CV mới',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF0D9D58),
                    ),
                  )
                : const Text(
                    'Lưu',
                    style: TextStyle(
                      color: Color(0xFF0D9D58),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        onChanged: () => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Preview
            Center(child: _buildPreview(_buildDto())),
            const SizedBox(height: 24),

            // Section 1: Thông tin cơ bản
            _sectionHeader('Thông tin cơ bản', Icons.person_outline),
            _field(
              _titleCtrl,
              'Tiêu đề CV',
              hint: 'Ví dụ: CV Lập trình viên Flutter',
            ),
            _field(_targetPosCtrl, 'Vị trí ứng tuyển'),
            _field(_fullNameCtrl, 'Họ và tên'),
            _field(_emailCtrl, 'Email', keyboard: TextInputType.emailAddress),
            _field(_phoneCtrl, 'Số điện thoại', keyboard: TextInputType.phone),
            _field(_addressCtrl, 'Địa chỉ'),
            _field(_bioCtrl, 'Giới thiệu bản thân', maxLines: 4),
            _genderDropdown(),
            _datePicker(
              'Ngày sinh',
              _dateOfBirth,
              (d) => setState(() => _dateOfBirth = d),
            ),
            const SizedBox(height: 16),

            // Section 2: Học vấn sinh viên
            _sectionHeader('Thông tin học vấn', Icons.school_outlined),
            _field(_studentIdCtrl, 'Mã sinh viên'),
            _field(_universityCtrl, 'Trường đại học'),
            _field(_majorCtrl, 'Ngành học'),
            _field(_gpaCtrl, 'GPA', keyboard: TextInputType.number),
            _field(
              _yearStudyCtrl,
              'Năm học hiện tại',
              keyboard: TextInputType.number,
            ),
            _datePicker(
              'Ngày dự kiến tốt nghiệp',
              _expectedGradDate,
              (d) => setState(() => _expectedGradDate = d),
            ),
            const SizedBox(height: 16),

            // Section 3: Mạng xã hội
            _sectionHeader('Mạng xã hội', Icons.link),
            _field(_linkedInCtrl, 'LinkedIn URL'),
            _field(_gitHubCtrl, 'GitHub URL'),
            const SizedBox(height: 16),

            // Section 4: Kỹ năng
            _sectionHeader('Kỹ năng', Icons.bolt_outlined),
            ..._skills.asMap().entries.map((e) => _skillCard(e.key, e.value)),
            _addButton(
              'Thêm kỹ năng',
              () => setState(() => _skills.add(_SkillEntry())),
            ),
            const SizedBox(height: 16),

            // Section 5: Kinh nghiệm
            _sectionHeader('Kinh nghiệm làm việc', Icons.work_outline),
            ..._experiences.asMap().entries.map(
              (e) => _expCard(e.key, e.value),
            ),
            _addButton(
              'Thêm kinh nghiệm',
              () => setState(() => _experiences.add(_ExpEntry())),
            ),
            const SizedBox(height: 16),

            // Section 6: Học vấn
            _sectionHeader('Học vấn', Icons.menu_book_outlined),
            ..._educations.asMap().entries.map((e) => _eduCard(e.key, e.value)),
            _addButton(
              'Thêm học vấn',
              () => setState(() => _educations.add(_EduEntry())),
            ),
            const SizedBox(height: 16),

            // Section 7: Chứng chỉ
            _sectionHeader('Chứng chỉ', Icons.card_membership_outlined),
            ..._certificates.asMap().entries.map(
              (e) => _certCard(e.key, e.value),
            ),
            _addButton(
              'Thêm chứng chỉ',
              () => setState(() => _certificates.add(_CertEntry())),
            ),
            const SizedBox(height: 32),

            // Save button bottom
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9D58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : const Text(
                        'Lưu CV',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ---- Helper Widgets ----

  Widget _sectionHeader(String title, IconData icon) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Icon(icon, color: const Color(0xFF0D9D58), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF14003E),
          ),
        ),
      ],
    ),
  );

  Widget _field(
    TextEditingController ctrl,
    String label, {
    int maxLines = 1,
    TextInputType? keyboard,
    String? hint,
    TextInputAction? textInputAction,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboard,
      textInputAction:
          textInputAction ??
          (maxLines > 1 ? TextInputAction.newline : TextInputAction.next),
      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0D9D58)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    ),
  );

  Widget _genderDropdown() => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DropdownButtonFormField<int>(
      initialValue: _gender,
      decoration: InputDecoration(
        labelText: 'Giới tính',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0D9D58)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      items: const [
        DropdownMenuItem(value: 0, child: Text('Nam')),
        DropdownMenuItem(value: 1, child: Text('Nữ')),
        DropdownMenuItem(value: 2, child: Text('Khác')),
      ],
      onChanged: (v) => setState(() => _gender = v),
    ),
  );

  Widget _datePicker(
    String label,
    DateTime? value,
    void Function(DateTime) onPicked,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime(2000),
          firstDate: DateTime(1950),
          lastDate: DateTime(2100),
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value == null
                  ? label
                  : '$label: ${value.day}/${value.month}/${value.year}',
              style: TextStyle(
                color: value == null ? Colors.grey : Colors.black87,
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    ),
  );

  Widget _addButton(String label, VoidCallback onTap) => OutlinedButton.icon(
    style: OutlinedButton.styleFrom(
      side: const BorderSide(color: Color(0xFF0D9D58)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(vertical: 12),
    ),
    icon: const Icon(Icons.add, color: Color(0xFF0D9D58)),
    label: Text(label, style: const TextStyle(color: Color(0xFF0D9D58))),
    onPressed: onTap,
  );

  Widget _card({required Widget child, required VoidCallback onDelete}) =>
      Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Stack(
          children: [
            child,
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.close, size: 18, color: Colors.grey),
              ),
            ),
          ],
        ),
      );

  Widget _skillCard(int i, _SkillEntry s) => _card(
    onDelete: () => setState(() => _skills.removeAt(i)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field(s.nameCtrl, 'Tên kỹ năng'),
        Row(
          children: [
            const Text('Thành thạo:', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 8),
            Expanded(
              child: Slider(
                value: (s.level ?? 3).toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                activeColor: const Color(0xFF0D9D58),
                label: '${s.level ?? 3}/5',
                onChanged: (v) => setState(() => s.level = v.round()),
              ),
            ),
            Text('${s.level ?? 3}/5', style: const TextStyle(fontSize: 13)),
          ],
        ),
        _field(
          s.yearsCtrl,
          'Số năm kinh nghiệm',
          keyboard: TextInputType.number,
        ),
      ],
    ),
  );

  Widget _expCard(int i, _ExpEntry e) => _card(
    onDelete: () => setState(() => _experiences.removeAt(i)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field(e.companyCtrl, 'Tên công ty'),
        _field(e.positionCtrl, 'Chức vụ'),
        _field(e.descCtrl, 'Mô tả công việc', maxLines: 3),
        _datePicker(
          'Ngày bắt đầu',
          e.startDate,
          (d) => setState(() => e.startDate = d),
        ),
        CheckboxListTile(
          value: e.isCurrent,
          contentPadding: EdgeInsets.zero,
          activeColor: const Color(0xFF0D9D58),
          title: const Text(
            'Đang làm việc tại đây',
            style: TextStyle(fontSize: 14),
          ),
          onChanged: (v) => setState(() => e.isCurrent = v ?? false),
        ),
        if (!e.isCurrent)
          _datePicker(
            'Ngày kết thúc',
            e.endDate,
            (d) => setState(() => e.endDate = d),
          ),
      ],
    ),
  );

  Widget _eduCard(int i, _EduEntry e) => _card(
    onDelete: () => setState(() => _educations.removeAt(i)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field(e.institutionCtrl, 'Tên trường'),
        _field(e.degreeCtrl, 'Bằng cấp'),
        _field(e.fieldCtrl, 'Lĩnh vực học'),
        _field(e.gpaCtrl, 'GPA', keyboard: TextInputType.number),
        _field(e.descCtrl, 'Mô tả', maxLines: 2),
        _datePicker(
          'Ngày bắt đầu',
          e.startDate,
          (d) => setState(() => e.startDate = d),
        ),
        _datePicker(
          'Ngày kết thúc',
          e.endDate,
          (d) => setState(() => e.endDate = d),
        ),
      ],
    ),
  );

  Widget _certCard(int i, _CertEntry c) => _card(
    onDelete: () => setState(() => _certificates.removeAt(i)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field(c.nameCtrl, 'Tên chứng chỉ'),
        _field(c.orgCtrl, 'Tổ chức cấp'),
        _field(c.credIdCtrl, 'Mã chứng chỉ'),
        _field(c.credUrlCtrl, 'URL xác minh'),
        _datePicker(
          'Ngày cấp',
          c.issueDate,
          (d) => setState(() => c.issueDate = d),
        ),
        _datePicker(
          'Ngày hết hạn',
          c.expiryDate,
          (d) => setState(() => c.expiryDate = d),
        ),
      ],
    ),
  );
}

// ---- Entry models ----
class _SkillEntry {
  final nameCtrl = TextEditingController();
  final yearsCtrl = TextEditingController();
  int? level = 3;
}

class _ExpEntry {
  final companyCtrl = TextEditingController();
  final positionCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  bool isCurrent = false;
}

class _EduEntry {
  final institutionCtrl = TextEditingController();
  final degreeCtrl = TextEditingController();
  final fieldCtrl = TextEditingController();
  final gpaCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
}

class _CertEntry {
  final nameCtrl = TextEditingController();
  final orgCtrl = TextEditingController();
  final credIdCtrl = TextEditingController();
  final credUrlCtrl = TextEditingController();
  DateTime? issueDate;
  DateTime? expiryDate;
}
