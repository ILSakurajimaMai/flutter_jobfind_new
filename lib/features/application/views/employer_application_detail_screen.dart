// lib/features/application/views/employer_application_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_jobfind/features/application/models/application_dto.dart';
import 'package:app_jobfind/features/application/viewmodels/employer_applications_provider.dart';
import 'package:app_jobfind/features/cv/viewmodels/cv_provider.dart';
import 'package:app_jobfind/features/cv/models/cv_dto.dart';
import 'package:app_jobfind/features/chat/views/chat_room_screen.dart';
import 'package:app_jobfind/features/chat/viewmodels/chat_list_viewmodel.dart';

class EmployerApplicationDetailScreen extends ConsumerStatefulWidget {
  final ApplicationDto application;
  const EmployerApplicationDetailScreen({super.key, required this.application});

  @override
  ConsumerState<EmployerApplicationDetailScreen> createState() => _EmployerApplicationDetailScreenState();
}

class _EmployerApplicationDetailScreenState extends ConsumerState<EmployerApplicationDetailScreen> {
  late Future<CvDto> _cvFuture;
  bool _isActioning = false;

  @override
  void initState() {
    super.initState();
    final cvService = ref.read(cvServiceProvider);
    _cvFuture = cvService.getCvById(widget.application.profileId);
  }

  String _getStatusLabel(String statusName) {
    switch (statusName) {
      case 'Pending':      return 'Chờ xét duyệt';
      case 'Reviewing':    return 'Đang xem xét';
      case 'Shortlisted':  return 'Đã lọc hồ sơ';
      case 'Interviewing': return 'Đang phỏng vấn';
      case 'Offered':      return 'Đã được offer';
      case 'Accepted':     return 'Đã chấp nhận';
      case 'Rejected':     return 'Bị từ chối';
      case 'Withdrawn':    return 'Đã rút đơn';
      case 'Expired':      return 'Hết hạn';
      default:             return statusName;
    }
  }

  Color _getStatusColor(int statusId) {
    switch (statusId) {
      case 1: return Colors.orange; // Pending
      case 2: return Colors.blue; // Reviewing
      case 3:
      case 4: return Colors.purple; // Shortlisted / Interviewing
      case 5:
      case 6: return Colors.green; // Offered / Accepted
      case 7: return Colors.red; // Rejected
      default: return Colors.grey;
    }
  }

  Future<void> _updateStatus(int statusId, String label) async {
    String? notes;
    if (statusId == 6 || statusId == 7) {
      // Phê duyệt hoặc Từ chối cần mở hội thoại nhập lưu ý
      final controller = TextEditingController();
      final isConfirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(statusId == 6 ? 'Chấp nhận ứng viên' : 'Từ chối ứng viên'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                statusId == 6
                    ? 'Nhập thông tin phản hồi hoặc lịch hẹn gặp mặt:'
                    : 'Nhập lý do từ chối hồ sơ:',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Nhập nội dung lưu ý...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.all(10),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: statusId == 6 ? Colors.green : Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Xác nhận'),
            ),
          ],
        ),
      );

      if (isConfirm != true) return;
      notes = controller.text;
    } else {
      // Đang xem xét chỉ cần xác nhận đơn giản
      final isConfirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Đánh dấu đang xem xét'),
          content: const Text('Bạn muốn chuyển trạng thái hồ sơ này thành "Đang xem xét"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Xác nhận'),
            ),
          ],
        ),
      );
      if (isConfirm != true) return;
    }

    setState(() {
      _isActioning = true;
    });

    try {
      await ref.read(employerApplicationsProvider.notifier).updateStatus(
            widget.application.id,
            statusId,
            notes: notes,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Đã chuyển trạng thái sang: $label'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Quay về trang danh sách
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Cập nhật thất bại: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isActioning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.application;
    final statusColor = _getStatusColor(app.statusId);
    final statusLabel = _getStatusLabel(app.statusName);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF14003E),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Chi tiết hồ sơ ứng viên',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: true,
      ),
      body: _isActioning
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF14003E)))
          : FutureBuilder<CvDto>(
              future: _cvFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF14003E)));
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'Lỗi tải thông tin CV: ${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final cv = snapshot.data!;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card ứng viên đầu trang
                      _buildOverviewCard(app, cv, statusColor, statusLabel),
                      const SizedBox(height: 16),

                      // Thư ứng tuyển
                      if (app.coverLetter != null && app.coverLetter!.trim().isNotEmpty) ...[
                        _buildSectionHeader('Thư giới thiệu / Cover Letter'),
                        _buildCoverLetterCard(app.coverLetter!),
                        const SizedBox(height: 16),
                      ],

                      // Thông tin sinh viên (Academic Info)
                      _buildSectionHeader('Thông tin học vấn & Liên hệ'),
                      _buildAcademicCard(cv),
                      const SizedBox(height: 16),

                      // CV đính kèm File PDF
                      if (cv.resumeUrl != null && cv.resumeUrl!.isNotEmpty) ...[
                        _buildSectionHeader('Tài liệu CV gốc'),
                        _buildFileCVCard(cv.resumeUrl!),
                        const SizedBox(height: 16),
                      ],

                      // Kỹ năng
                      if (cv.skills != null && cv.skills!.isNotEmpty) ...[
                        _buildSectionHeader('Kỹ năng chuyên môn'),
                        _buildSkillsCard(cv.skills!),
                        const SizedBox(height: 16),
                      ],

                      // Kinh nghiệm
                      if (cv.experiences != null && cv.experiences!.isNotEmpty) ...[
                        _buildSectionHeader('Kinh nghiệm làm việc'),
                        _buildExperiencesCard(cv.experiences!),
                        const SizedBox(height: 16),
                      ],

                      // Học vấn chi tiết
                      if (cv.educations != null && cv.educations!.isNotEmpty) ...[
                        _buildSectionHeader('Lịch sử đào tạo'),
                        _buildEducationsCard(cv.educations!),
                        const SizedBox(height: 16),
                      ],

                      // Chứng chỉ
                      if (cv.certificates != null && cv.certificates!.isNotEmpty) ...[
                        _buildSectionHeader('Chứng chỉ & Bằng cấp'),
                        _buildCertificatesCard(cv.certificates!),
                        const SizedBox(height: 100), // Khoảng trống cho Action Bar ở đáy
                      ],
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: Row(
          children: [
            // Trò chuyện
            Expanded(
              flex: 1,
              child: OutlinedButton.icon(
                onPressed: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) => const Center(
                      child: CircularProgressIndicator(color: Color(0xFF14003E)),
                    ),
                  );

                  try {
                    final cv = await _cvFuture;
                    final studentUserId = cv.userId ?? 0;
                    if (studentUserId == 0) {
                      throw 'Không tìm thấy thông tin ID người dùng của ứng viên';
                    }

                    final chatService = ref.read(chatServiceProvider);
                    final conversation = await chatService.getOrCreateConversation(
                      studentUserId, // ID của sinh viên ứng tuyển
                      app.jobPostId, // ID tin tuyển dụng tương ứng
                    );

                    if (context.mounted) Navigator.pop(context);

                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatRoomScreen(
                            conversationId: conversation.id,
                            recipientId: studentUserId,
                            recipientName: app.applicantName,
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) Navigator.pop(context);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Không thể kết nối trò chuyện: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF14003E)),
                label: const Text('Chat', style: TextStyle(color: Color(0xFF14003E), fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFF14003E)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Nhóm phê duyệt
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  // Đang xem xét
                  if (app.statusId == 1) ...[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _updateStatus(2, 'Đang xem xét'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Xem xét', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  // Chấp nhận
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(6, 'Đã chấp nhận'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Nhận', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Từ chối
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(7, 'Bị từ chối'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Từ chối', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF14003E),
        ),
      ),
    );
  }

  Widget _buildOverviewCard(ApplicationDto app, CvDto cv, Color statusColor, String statusLabel) {
    final initials = app.applicantName.isNotEmpty
        ? app.applicantName.trim().split(' ').last.substring(0, 1).toUpperCase()
        : 'U';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: const Color(0xFF14003E).withValues(alpha: 0.08),
                child: Text(
                  initials,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF14003E)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.applicantName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF14003E)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cv.targetPosition ?? cv.major ?? 'Sinh viên tìm việc',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (app.reviewNotes != null && app.reviewNotes!.isNotEmpty) ...[
            const Divider(height: 24),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.feedback_outlined, size: 16, color: Colors.blueGrey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Lưu ý xem xét: "${app.reviewNotes}"',
                      style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCoverLetterCard(String text) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDAE5C).withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, color: Colors.grey.shade800, height: 1.5, fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget _buildAcademicCard(CvDto cv) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoRow(Icons.school_outlined, 'Trường đại học', cv.university ?? 'Chưa cập nhật'),
          const Divider(height: 20),
          _buildInfoRow(Icons.book_outlined, 'Chuyên ngành học', cv.major ?? 'Chưa cập nhật'),
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildInfoRow(
                  Icons.card_membership_outlined,
                  'MSSV',
                  cv.studentId ?? 'N/A',
                ),
              ),
              Expanded(
                child: _buildInfoRow(
                  Icons.grade_outlined,
                  'GPA tích lũy',
                  cv.gpa != null ? cv.gpa!.toStringAsFixed(2) : 'N/A',
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          _buildInfoRow(Icons.mail_outline, 'Hộp thư liên hệ', cv.email ?? widget.application.employerName),
          const Divider(height: 20),
          _buildInfoRow(Icons.phone_outlined, 'Số điện thoại', cv.phoneNumber ?? 'Chưa cập nhật'),
          const Divider(height: 20),
          _buildInfoRow(Icons.location_on_outlined, 'Địa chỉ hiện tại', cv.address ?? 'Chưa cập nhật'),
        ],
      ),
    );
  }

  Widget _buildFileCVCard(String fileUrl) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF14003E).withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF14003E).withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: Colors.red, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Tài liệu CV đính kèm',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF14003E)),
                ),
                SizedBox(height: 2),
                Text(
                  'Định dạng PDF đính kèm từ ứng viên',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đang tải file CV...')),
              );
            },
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Tải về', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14003E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsCard(List<CvSkillDto> skills) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: skills.map((skill) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF14003E).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  skill.skillName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF14003E)),
                ),
                if (skill.proficiencyLevel != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    '⭐${skill.proficiencyLevel}',
                    style: const TextStyle(fontSize: 10, color: Color(0xFFFDAE5C)),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExperiencesCard(List<CvExperienceDto> expList) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(16),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: expList.length,
        separatorBuilder: (c, i) => const Divider(height: 24),
        itemBuilder: (context, index) {
          final exp = expList[index];
          final end = exp.isCurrentlyWorking ? 'Hiện tại' : (exp.endDate ?? '');
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exp.position,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF14003E)),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    exp.companyName,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${exp.startDate} - $end',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              if (exp.description != null && exp.description!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  exp.description!,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.4),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildEducationsCard(List<CvEducationDto> eduList) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(16),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: eduList.length,
        separatorBuilder: (c, i) => const Divider(height: 24),
        itemBuilder: (context, index) {
          final edu = eduList[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${edu.degree} - ${edu.fieldOfStudy ?? ""}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF14003E)),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    edu.institutionName,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${edu.startDate} - ${edu.endDate ?? ""}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              if (edu.gpa != null) ...[
                const SizedBox(height: 4),
                Text(
                  'GPA: ${edu.gpa!.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFFDAE5C)),
                ),
              ],
              if (edu.description != null && edu.description!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  edu.description!,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.4),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildCertificatesCard(List<CvCertificateDto> certs) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(16),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: certs.length,
        separatorBuilder: (c, i) => const Divider(height: 24),
        itemBuilder: (context, index) {
          final cert = certs[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cert.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF14003E)),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    cert.issuingOrganization ?? 'Tổ chức cấp bằng',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                  ),
                  if (cert.issueDate != null)
                    Text(
                      'Cấp ngày: ${cert.issueDate}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF14003E)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF14003E)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
