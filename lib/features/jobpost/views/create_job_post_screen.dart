// lib/features/jobpost/views/create_job_post_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_jobfind/features/jobpost/models/create_job_post_request.dart';
import 'package:app_jobfind/features/jobpost/models/job_post_model.dart';
import 'package:app_jobfind/features/jobpost/models/job_shift_request.dart';
import 'package:app_jobfind/features/jobpost/viewmodels/my_job_posts_provider.dart';

class CreateJobPostScreen extends ConsumerStatefulWidget {
  final JobPostModel? jobToEdit;
  const CreateJobPostScreen({super.key, this.jobToEdit});

  @override
  ConsumerState<CreateJobPostScreen> createState() =>
      _CreateJobPostScreenState();
}

class _CreateJobPostScreenState extends ConsumerState<CreateJobPostScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Controllers – Bước 1
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _positionsCtrl = TextEditingController();
  String? _workType = 'Part-time';
  String? _category;
  DateTime? _deadline;
  bool _isUrgent = false;

  // Controllers – Bước 2
  final _descCtrl = TextEditingController();
  final _reqCtrl = TextEditingController();
  final _benefitsCtrl = TextEditingController();

  // Controllers – Bước 3
  final _salaryMinCtrl = TextEditingController();
  final _salaryMaxCtrl = TextEditingController();
  String _salaryPeriod = 'Monthly';

  // Bước 4 – Kỹ năng & ca làm
  final List<String> _skills = [];
  final _skillInputCtrl = TextEditingController();
  final List<JobShiftRequest> _shifts = [];

  bool get _isEditing => widget.jobToEdit != null;

  static const _workTypes = [
    'Part-time',
    'Full-time',
    'Freelance',
    'Internship',
  ];
  static const _salaryPeriods = ['Hourly', 'Daily', 'Weekly', 'Monthly'];
  static const _salaryPeriodLabels = ['Giờ', 'Ngày', 'Tuần', 'Tháng'];
  static const _categories = [
    'Công nghệ thông tin',
    'Marketing',
    'Bán hàng',
    'Kế toán',
    'Nhà hàng / Khách sạn',
    'Kho vận / Giao vận',
    'Phục vụ',
    'Giáo dục',
    'Y tế',
    'Xây dựng',
    'Khác',
  ];
  static const _dayLabels = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];

  @override
  void initState() {
    super.initState();
    if (_isEditing) _populateFromEdit();
  }

  void _populateFromEdit() {
    final j = widget.jobToEdit!;
    _titleCtrl.text = j.title;
    _locationCtrl.text = j.location ?? '';
    _positionsCtrl.text = j.numberOfPositions?.toString() ?? '';
    _workType = j.workType ?? 'Part-time';
    _category = j.category;
    _deadline = j.applicationDeadline;
    _isUrgent = j.isUrgent;
    _descCtrl.text = j.description;
    _reqCtrl.text = j.requirements ?? '';
    _benefitsCtrl.text = j.benefits ?? '';
    _salaryMinCtrl.text = j.salaryMin?.toStringAsFixed(0) ?? '';
    _salaryMaxCtrl.text = j.salaryMax?.toStringAsFixed(0) ?? '';
    _salaryPeriod = j.salaryPeriod ?? 'Monthly';
    _skills.addAll(j.requiredSkills);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _positionsCtrl.dispose();
    _descCtrl.dispose();
    _reqCtrl.dispose();
    _benefitsCtrl.dispose();
    _salaryMinCtrl.dispose();
    _salaryMaxCtrl.dispose();
    _skillInputCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now.add(const Duration(days: 14)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF14003E),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  void _addSkill() {
    final skill = _skillInputCtrl.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillInputCtrl.clear();
      });
    }
  }

  void _removeSkill(String skill) => setState(() => _skills.remove(skill));

  void _addShift() {
    setState(
      () => _shifts.add(
        JobShiftRequest(dayOfWeek: 1, startTime: '08:00', endTime: '17:00'),
      ),
    );
  }

  void _removeShift(int i) => setState(() => _shifts.removeAt(i));

  CreateJobPostRequest _buildRequest() => CreateJobPostRequest(
    title: _titleCtrl.text.trim(),
    description: _descCtrl.text.trim(),
    requirements: _reqCtrl.text.trim().isEmpty ? null : _reqCtrl.text.trim(),
    benefits: _benefitsCtrl.text.trim().isEmpty
        ? null
        : _benefitsCtrl.text.trim(),
    salaryMin: double.tryParse(_salaryMinCtrl.text.trim()),
    salaryMax: double.tryParse(_salaryMaxCtrl.text.trim()),
    salaryPeriod: _salaryPeriod,
    location: _locationCtrl.text.trim().isEmpty
        ? null
        : _locationCtrl.text.trim(),
    workType: _workType,
    category: _category,
    numberOfPositions: int.tryParse(_positionsCtrl.text.trim()),
    applicationDeadline: _deadline,
    isUrgent: _isUrgent,
    requiredSkills: List.from(_skills),
    shifts: List.from(_shifts),
  );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ các trường bắt buộc'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    final req = _buildRequest();
    final notifier = ref.read(myJobPostsProvider.notifier);
    bool success;
    if (_isEditing) {
      success = await notifier.updateJob(widget.jobToEdit!.id, req);
    } else {
      success = await notifier.createJob(req);
    }
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? '✅ Cập nhật thành công!' : '✅ Đăng tin thành công!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        final err = ref.read(myJobPostsProvider).error ?? 'Đã có lỗi xảy ra';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ $err'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ───────────────────────── BUILD ─────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myJobPostsProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF14003E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _isEditing ? 'Chỉnh sửa tin tuyển dụng' : 'Tạo tin tuyển dụng',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: const Color(0xFF14003E)),
          ),
          child: Stepper(
            currentStep: _currentStep,
            onStepTapped: (i) => setState(() => _currentStep = i),
            onStepContinue: () {
              if (_currentStep < 3) {
                setState(() => _currentStep++);
              } else {
                _submit();
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() => _currentStep--);
              } else {
                Navigator.pop(context);
              }
            },
            controlsBuilder: (ctx, details) =>
                _buildStepControls(ctx, details, state.isSaving),
            steps: [
              Step(
                title: const Text(
                  'Thông tin cơ bản',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Tiêu đề, địa điểm, số lượng'),
                isActive: _currentStep >= 0,
                state: _currentStep > 0
                    ? StepState.complete
                    : StepState.indexed,
                content: _buildStep1(),
              ),
              Step(
                title: const Text(
                  'Mô tả công việc',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Nội dung, yêu cầu, phúc lợi'),
                isActive: _currentStep >= 1,
                state: _currentStep > 1
                    ? StepState.complete
                    : StepState.indexed,
                content: _buildStep2(),
              ),
              Step(
                title: const Text(
                  'Mức lương',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Lương tối thiểu – tối đa'),
                isActive: _currentStep >= 2,
                state: _currentStep > 2
                    ? StepState.complete
                    : StepState.indexed,
                content: _buildStep3(),
              ),
              Step(
                title: const Text(
                  'Kỹ năng & Ca làm việc',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Kỹ năng yêu cầu, lịch ca'),
                isActive: _currentStep >= 3,
                state: StepState.indexed,
                content: _buildStep4(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepControls(
    BuildContext ctx,
    ControlsDetails details,
    bool isSaving,
  ) {
    final isLast = _currentStep == 3;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: isSaving ? null : details.onStepContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14003E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isSaving && isLast
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      isLast
                          ? (_isEditing ? 'Lưu thay đổi' : 'Đăng tin')
                          : 'Tiếp theo',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: details.onStepCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF14003E),
              side: const BorderSide(color: Color(0xFF14003E)),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(_currentStep == 0 ? 'Hủy' : 'Quay lại'),
          ),
        ],
      ),
    );
  }

  // ── STEP 1 ──────────────────────────────────────────────

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Tiêu đề tin tuyển dụng *'),
        _field(
          _titleCtrl,
          hint: 'Ví dụ: Nhân viên phục vụ part-time',
          isRequired: true,
        ),
        const SizedBox(height: 16),

        _label('Ngành nghề / Danh mục'),
        _buildDropdown(
          _category,
          _categories,
          'Chọn ngành nghề',
          (v) => setState(() => _category = v),
        ),
        const SizedBox(height: 16),

        _label('Loại hình công việc'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _workTypes
              .map(
                (t) => ChoiceChip(
                  label: Text(t),
                  selected: _workType == t,
                  onSelected: (_) => setState(() => _workType = t),
                  selectedColor: const Color(0xFF14003E),
                  labelStyle: TextStyle(
                    color: _workType == t ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  backgroundColor: Colors.grey.shade100,
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),

        _label('Địa điểm làm việc'),
        _field(_locationCtrl, hint: 'Ví dụ: Hà Nội, Hồ Chí Minh...'),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Số lượng tuyển'),
                  _field(
                    _positionsCtrl,
                    hint: '1',
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Hạn nộp hồ sơ'),
                  GestureDetector(
                    onTap: _pickDeadline,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _deadline != null
                                ? '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'
                                : 'Chọn ngày',
                            style: TextStyle(
                              color: _deadline != null
                                  ? Colors.black87
                                  : Colors.grey.shade400,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Toggle tuyển gấp
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.local_fire_department_outlined,
                color: Color(0xFFFF6B35),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Tuyển gấp',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Switch(
                value: _isUrgent,
                onChanged: (v) => setState(() => _isUrgent = v),
                activeTrackColor: const Color(0xFF14003E),
                thumbColor: WidgetStateProperty.all(Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── STEP 2 ──────────────────────────────────────────────

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Mô tả công việc *'),
        _field(
          _descCtrl,
          hint: 'Mô tả chi tiết công việc, nhiệm vụ cần thực hiện...',
          maxLines: 5,
          isRequired: true,
        ),
        const SizedBox(height: 16),
        _label('Yêu cầu ứng viên'),
        _field(
          _reqCtrl,
          hint: 'Kinh nghiệm, bằng cấp, tố chất cần có...',
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        _label('Quyền lợi / Phúc lợi'),
        _field(
          _benefitsCtrl,
          hint: 'Lương thưởng, bảo hiểm, du lịch, đào tạo...',
          maxLines: 4,
        ),
      ],
    );
  }

  // ── STEP 3 ──────────────────────────────────────────────

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Đơn vị tính lương'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            _salaryPeriods.length,
            (i) => ChoiceChip(
              label: Text(_salaryPeriodLabels[i]),
              selected: _salaryPeriod == _salaryPeriods[i],
              onSelected: (_) =>
                  setState(() => _salaryPeriod = _salaryPeriods[i]),
              selectedColor: const Color(0xFF14003E),
              labelStyle: TextStyle(
                color: _salaryPeriod == _salaryPeriods[i]
                    ? Colors.white
                    : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              backgroundColor: Colors.grey.shade100,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Lương tối thiểu (VNĐ)'),
                  _field(
                    _salaryMinCtrl,
                    hint: '3000000',
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Lương tối đa (VNĐ)'),
                  _field(
                    _salaryMaxCtrl,
                    hint: '6000000',
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF14003E).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 16,
                color: Color(0xFF14003E),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Để trống nếu lương thỏa thuận',
                  style: TextStyle(fontSize: 12, color: Color(0xFF14003E)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── STEP 4 ──────────────────────────────────────────────

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Kỹ năng yêu cầu'),
        Row(
          children: [
            Expanded(
              child: _field(_skillInputCtrl, hint: 'Nhập kỹ năng rồi nhấn +'),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _addSkill,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF14003E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
        if (_skills.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _skills
                .map(
                  (s) => Chip(
                    label: Text(s, style: const TextStyle(fontSize: 12)),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () => _removeSkill(s),
                    backgroundColor: const Color(
                      0xFF14003E,
                    ).withValues(alpha: 0.08),
                    deleteIconColor: const Color(0xFF14003E),
                    labelStyle: const TextStyle(color: Color(0xFF14003E)),
                  ),
                )
                .toList(),
          ),
        ],
        const SizedBox(height: 20),
        Row(
          children: [
            const Text(
              'Ca làm việc',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF14003E),
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _addShift,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Thêm ca'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF14003E),
              ),
            ),
          ],
        ),
        ..._shifts.asMap().entries.map(
          (entry) => _buildShiftRow(entry.key, entry.value),
        ),
        if (_shifts.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '(Không bắt buộc)',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildShiftRow(int index, JobShiftRequest shift) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Thứ:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      7,
                      (d) => Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: ChoiceChip(
                          label: Text(
                            _dayLabels[d],
                            style: const TextStyle(fontSize: 11),
                          ),
                          selected: shift.dayOfWeek == d,
                          onSelected: (_) =>
                              setState(() => shift.dayOfWeek = d),
                          selectedColor: const Color(0xFF14003E),
                          labelStyle: TextStyle(
                            color: shift.dayOfWeek == d
                                ? Colors.white
                                : Colors.black87,
                          ),
                          backgroundColor: Colors.grey.shade100,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 20,
                ),
                onPressed: () => _removeShift(index),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTimePicker(
                  'Bắt đầu',
                  shift.startTime,
                  (v) => setState(() => shift.startTime = v),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('–', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: _buildTimePicker(
                  'Kết thúc',
                  shift.endTime,
                  (v) => setState(() => shift.endTime = v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker(
    String label,
    String value,
    Function(String) onChanged,
  ) {
    return GestureDetector(
      onTap: () async {
        final parts = value.split(':');
        final initialTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
        final picked = await showTimePicker(
          context: context,
          initialTime: initialTime,
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(primary: Color(0xFF14003E)),
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          onChanged(
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6FB),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(
                  Icons.access_time_outlined,
                  size: 14,
                  color: Color(0xFF14003E),
                ),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF14003E),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── HELPERS ─────────────────────────────────────────────

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 2),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 13,
        color: Color(0xFF14003E),
      ),
    ),
  );

  Widget _field(
    TextEditingController ctrl, {
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool isRequired = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8),
        ],
      ),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: maxLines > 1 ? 14 : 15,
          ),
        ),
        validator: isRequired
            ? (v) =>
                  (v == null || v.trim().isEmpty) ? 'Trường này bắt buộc' : null
            : null,
      ),
    );
  }

  Widget _buildDropdown(
    String? value,
    List<String> items,
    String hint,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.grey,
          ),
          items: items
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Text(s, style: const TextStyle(fontSize: 14)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
