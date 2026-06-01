// lib/features/job/views/widgets/apply_job_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_jobfind/features/cv/viewmodels/cv_provider.dart';
import 'package:app_jobfind/features/application/viewmodels/application_provider.dart';

class ApplyJobBottomSheet extends ConsumerStatefulWidget {
  final int jobId;
  final String jobTitle;

  const ApplyJobBottomSheet({
    super.key,
    required this.jobId,
    required this.jobTitle,
  });

  @override
  ConsumerState<ApplyJobBottomSheet> createState() => _ApplyJobBottomSheetState();
}

class _ApplyJobBottomSheetState extends ConsumerState<ApplyJobBottomSheet> {
  int? _selectedCvId;
  final TextEditingController _coverLetterController = TextEditingController();
  bool _isApplying = false;

  @override
  void dispose() {
    _coverLetterController.dispose();
    super.dispose();
  }

  Future<void> _handleApply() async {
    if (_selectedCvId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn một CV để ứng tuyển.')),
      );
      return;
    }

    setState(() {
      _isApplying = true;
    });

    try {
      await ref.read(applicationProvider.notifier).applyForJob(
        jobId: widget.jobId,
        cvId: _selectedCvId,
        coverLetter: _coverLetterController.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context); // Đóng bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ứng tuyển thành công!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi ứng tuyển: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isApplying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cvAsyncValue = ref.watch(cvProvider);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ứng tuyển công việc',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.jobTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0D9D58),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Chọn CV của bạn',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            cvAsyncValue.when(
              data: (cvs) {
                if (cvs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: const Text(
                      'Bạn chưa có CV nào. Vui lòng tạo CV trong phần Hồ sơ của tôi trước khi ứng tuyển.',
                      style: TextStyle(color: Colors.orange),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cvs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final cv = cvs[index];
                    final isSelected = _selectedCvId == cv.id;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCvId = cv.id;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.green.shade50 : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF0D9D58) : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.description,
                              color: isSelected ? const Color(0xFF0D9D58) : Colors.grey,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cv.title ?? 'CV Không tên',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: isSelected ? const Color(0xFF0D9D58) : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    cv.targetPosition ?? 'Chưa cập nhật vị trí ứng tuyển',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF0D9D58),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text('Lỗi tải CV: $e'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Thư giới thiệu (Tùy chọn)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _coverLetterController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Nhập thông tin giới thiệu bản thân để nhà tuyển dụng chú ý hơn...',
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
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isApplying || cvAsyncValue.value?.isEmpty == true ? null : _handleApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9D58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: _isApplying
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Xác nhận ứng tuyển',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
