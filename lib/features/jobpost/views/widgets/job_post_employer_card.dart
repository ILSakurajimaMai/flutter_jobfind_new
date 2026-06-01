// lib/features/jobpost/views/widgets/job_post_employer_card.dart
// Card hiển thị 1 tin tuyển dụng trong danh sách của Employer

import 'package:flutter/material.dart';
import 'package:app_jobfind/features/jobpost/models/job_post_model.dart';

class JobPostEmployerCard extends StatelessWidget {
  final JobPostModel job;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onTap;

  const JobPostEmployerCard({
    super.key,
    required this.job,
    this.onEdit,
    this.onDelete,
    this.onToggleStatus,
    this.onTap,
  });

  Color get _statusColor {
    switch (job.status) {
      case 1:
        return const Color(0xFF22C55E); // Active – xanh lá
      case 0:
        return const Color(0xFF94A3B8); // Draft – xám
      case 2:
      case 3:
        return const Color(0xFFEF4444); // Closed/Expired – đỏ
      default:
        return Colors.grey;
    }
  }

  IconData get _statusIcon {
    switch (job.status) {
      case 1:
        return Icons.check_circle_outline;
      case 0:
        return Icons.edit_note;
      case 2:
      case 3:
        return Icons.cancel_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF14003E).withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF14003E).withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_statusIcon, size: 13, color: _statusColor),
                        const SizedBox(width: 4),
                        Text(
                          job.statusLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (job.isUrgent) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '🔥 Tuyển gấp',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFF6B35),
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  // Menu 3 chấm
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      color: Colors.grey,
                      size: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      if (value == 'edit') onEdit?.call();
                      if (value == 'toggle') onToggleStatus?.call();
                      if (value == 'delete') onDelete?.call();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: Color(0xFF14003E),
                            ),
                            SizedBox(width: 8),
                            Text('Chỉnh sửa'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(
                              job.status == 1
                                  ? Icons.pause_circle_outline
                                  : Icons.play_circle_outline,
                              size: 18,
                              color: job.status == 1
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF22C55E),
                            ),
                            const SizedBox(width: 8),
                            Text(job.status == 1 ? 'Đóng tin' : 'Đăng lại'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Xóa tin',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Body ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF14003E),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Info row
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      if (job.location != null)
                        _infoChip(Icons.location_on_outlined, job.location!),
                      if (job.workType != null)
                        _infoChip(Icons.work_outline, job.workType!),
                      if (job.numberOfPositions != null)
                        _infoChip(
                          Icons.people_outline,
                          '${job.numberOfPositions} vị trí',
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Salary
                  Row(
                    children: [
                      const Icon(
                        Icons.payments_outlined,
                        size: 16,
                        color: Color(0xFFFDAE5C),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        job.salaryDisplay,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF14003E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Stats + skills
                  Row(
                    children: [
                      _statBadge(
                        Icons.visibility_outlined,
                        '${job.viewCount} lượt xem',
                      ),
                      const SizedBox(width: 8),
                      _statBadge(
                        Icons.person_add_outlined,
                        '${job.applicationCount} ứng viên',
                      ),
                      const Spacer(),
                      if (job.applicationDeadline != null)
                        Text(
                          'HN: ${_formatDate(job.applicationDeadline!)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),

                  if (job.requiredSkills.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: job.requiredSkills.take(4).map((skill) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF14003E,
                            ).withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            skill,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF14003E),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.grey),
        const SizedBox(width: 3),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _statBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF14003E)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF14003E),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}
