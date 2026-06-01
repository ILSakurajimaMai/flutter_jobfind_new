import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_jobfind/features/cv/models/cv_dto.dart';
import 'package:app_jobfind/features/cv/views/upload_cv_screen.dart';
import 'package:app_jobfind/features/cv/views/cv_templates_screen.dart';
import 'package:app_jobfind/features/cv/views/cv_edit_screen.dart';
import 'package:app_jobfind/features/cv/viewmodels/cv_provider.dart';
import 'package:app_jobfind/features/cv/views/widgets/cv_template_impression.dart';
import 'package:app_jobfind/features/cv/views/widgets/cv_template_modern.dart';
import 'package:app_jobfind/features/cv/views/widgets/cv_template_basic.dart';
import 'package:app_jobfind/core/constants.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class MyCvScreen extends ConsumerWidget {
  const MyCvScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cvState = ref.watch(cvProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        title: const Text(
          'Quản lý CV',
          style: TextStyle(color: Color(0xFF14003E), fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black54),
        centerTitle: true,
      ),
      body: cvState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF0D9D58))),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.wifi_off_outlined, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text('Không tải được danh sách CV', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              Text(e.toString(), style: const TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9D58), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text('Thử lại', style: TextStyle(color: Colors.white)),
                onPressed: () => ref.refresh(cvProvider),
              ),
            ]),
          ),
        ),
        data: (cvs) {
          final uploadedCvs = cvs.where((c) => c.resumeUrl != null && c.resumeUrl!.isNotEmpty).toList();
          final templateCvs = cvs.where((c) => c.resumeUrl == null || c.resumeUrl!.isEmpty).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Section 1: CV tải lên ──
                _sectionTitle('CV tải lên từ thiết bị'),
                const SizedBox(height: 12),
                _buildUploadSection(context, uploadedCvs.length),
                if (uploadedCvs.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...uploadedCvs.map((cv) => _buildUploadedCvCard(context, ref, cv)),
                ],
                const SizedBox(height: 32),

                // ── Section 2: CV tạo trên JobFind ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionTitle('CV tạo trên JobFind'),
                    TextButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CvTemplatesScreen()),
                      ).then((_) => ref.refresh(cvProvider)),
                      icon: const Icon(Icons.add, size: 18, color: Color(0xFF0D9D58)),
                      label: const Text('Tạo mới', style: TextStyle(color: Color(0xFF0D9D58), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (templateCvs.isEmpty)
                  _buildEmptyTemplateSection(context)
                else
                  ...templateCvs.map((cv) => _buildCvCard(context, ref, cv)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF14003E)),
      );

  Widget _buildUploadSection(BuildContext context, int count) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFF0D9D58).withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.upload_file, color: Color(0xFF0D9D58), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$count CV đã tải lên', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                const Text('Hỗ trợ .doc, .docx, pdf dưới 5MB', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9D58),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadCvScreen())),
            child: const Text('Tải lên', style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadedCvCard(BuildContext context, WidgetRef ref, CvDto cv) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cv.title ?? 'Tài liệu không tên',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF14003E)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                const Text('Đã tải lên', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          _actionIcon(Icons.download_rounded, 'Tải xuống', const Color(0xFF0D9D58), () {
            _downloadFile(cv.resumeUrl);
          }),
          _actionIcon(Icons.delete_outline, 'Xóa', Colors.redAccent, () => _confirmDeleteUpload(context, ref, cv)),
        ],
      ),
    );
  }

  Future<void> _downloadFile(String? fileUrl) async {
    if (fileUrl == null || fileUrl.isEmpty) return;
    
    // Thêm import url_launcher để mở trình duyệt tải file
    final urlStr = '${Constants.baseUrl}/files/download?fileUrl=$fileUrl';
    final uri = Uri.parse(urlStr);
    try {
      if (await url_launcher.canLaunchUrl(uri)) {
        await url_launcher.launchUrl(uri, mode: url_launcher.LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error downloading: $e');
    }
  }

  Widget _buildEmptyTemplateSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFFDAE5C).withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.edit_document, color: Color(0xFFFDAE5C), size: 36),
          ),
          const SizedBox(height: 16),
          const Text('Chưa có CV nào', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 6),
          const Text('Tạo CV từ mẫu thiết kế chuyên nghiệp', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFDAE5C),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CvTemplatesScreen())),
              child: const Text('Tạo CV mới', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCvCard(BuildContext context, WidgetRef ref, CvDto cv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // ── Thumbnail Preview ──
          GestureDetector(
            onTap: () => _showViewDialog(context, cv),
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFEFEFF4),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                child: AbsorbPointer(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    child: _getTemplateWidget(cv),
                  ),
                ),
              ),
            ),
          ),

          // ── Info & Actions ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              cv.title ?? 'CV không tên',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF14003E)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (cv.isDefault) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D9D58).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('Mặc định', style: TextStyle(fontSize: 11, color: Color(0xFF0D9D58), fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                      if (cv.targetPosition != null && cv.targetPosition!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(cv.targetPosition!, style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis),
                        ),
                    ],
                  ),
                ),
                // Action buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _actionIcon(Icons.visibility_outlined, 'Xem', const Color(0xFF5C6BC0), () => _showViewDialog(context, cv)),
                    _actionIcon(Icons.edit_outlined, 'Sửa', const Color(0xFF0D9D58), () => _goToEdit(context, ref, cv)),
                    _actionIcon(Icons.delete_outline, 'Xóa', Colors.redAccent, () => _confirmDelete(context, ref, cv)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionIcon(IconData icon, String tooltip, Color color, VoidCallback onTap) => Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: color, size: 22),
          ),
        ),
      );

  Widget _getTemplateWidget(CvDto cv) {
    // Dùng targetPosition để đoán template type (lưu tạm), mặc định impression
    final t = cv.title?.toLowerCase() ?? '';
    if (t.contains('modern') || t.contains('hiện đại')) return CvTemplateModern(cvData: cv);
    if (t.contains('basic') || t.contains('cơ bản')) return CvTemplateBasic(cvData: cv);
    return CvTemplateImpression(cvData: cv);
  }

  void _showViewDialog(BuildContext context, CvDto cv) {
    showDialog(
      context: context,
      builder: (ctx) {
        final screenW = MediaQuery.of(context).size.width - 32;
        final screenH = MediaQuery.of(context).size.height - 160;
        // Scale để template 500x707 vừa màn hình
        final scale = (screenW / 500).clamp(0.0, screenH / 707);
        final displayW = 500 * scale;
        final displayH = 707 * scale;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: displayW,
                  height: displayH,
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.topLeft,
                    child: AbsorbPointer(
                      child: SizedBox(
                        width: 500,
                        height: 707,
                        child: _getTemplateWidget(cv),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Đóng', style: TextStyle(color: Color(0xFF14003E), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _goToEdit(BuildContext context, WidgetRef ref, CvDto cv) {
    final t = cv.title?.toLowerCase() ?? '';
    String templateType = 'impression';
    if (t.contains('modern') || t.contains('hiện đại')) templateType = 'modern';
    if (t.contains('basic') || t.contains('cơ bản')) templateType = 'basic';

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CvEditScreen(templateType: templateType, existingCv: cv)),
    ).then((_) => ref.refresh(cvProvider));
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, CvDto cv) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xóa CV?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc muốn xóa CV "${cv.title ?? 'này'}" không? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              Navigator.pop(ctx);
              if (cv.id != null) {
                await ref.read(cvProvider.notifier).removeCv(cv.id!);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Đã xóa CV'), backgroundColor: Color(0xFF0D9D58)),
                  );
                }
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteUpload(BuildContext context, WidgetRef ref, CvDto cv) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xóa tài liệu?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc muốn xóa tài liệu "${cv.title ?? 'này'}" không? Hành động này sẽ xoá luôn tệp trên hệ thống.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              Navigator.pop(ctx);
              if (cv.id != null) {
                await ref.read(cvProvider.notifier).deleteCvAndFile(cv.id!, cv.resumeUrl);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Đã xóa tài liệu'), backgroundColor: Color(0xFF0D9D58)),
                  );
                }
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
