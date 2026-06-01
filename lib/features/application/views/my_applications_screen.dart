// lib/features/application/views/my_applications_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_jobfind/features/application/viewmodels/application_provider.dart';
import 'package:app_jobfind/features/application/models/application_dto.dart';
import 'package:app_jobfind/features/job/views/job_details_screen.dart';
import 'package:app_jobfind/features/job/services/job_service.dart';

class MyApplicationsScreen extends ConsumerWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync = ref.watch(applicationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Việc làm đã ứng tuyển'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade50,
      body: applicationsAsync.when(
        data: (applications) {
          if (applications.isEmpty) {
            return const Center(
              child: Text(
                'Bạn chưa ứng tuyển công việc nào.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(applicationProvider.notifier).fetchMyApplications(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: applications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final app = applications[index];
                return _ApplicationCard(application: app);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Lỗi tải dữ liệu: $e',
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref
                    .read(applicationProvider.notifier)
                    .fetchMyApplications(),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApplicationCard extends ConsumerStatefulWidget {
  final ApplicationDto application;

  const _ApplicationCard({required this.application});

  @override
  ConsumerState<_ApplicationCard> createState() => _ApplicationCardState();
}

class _ApplicationCardState extends ConsumerState<_ApplicationCard> {
  bool _isWithdrawing = false;

  /// Trả về label tiếng Việt tương ứng với statusName từ backend
  String _getStatusLabel(String statusName) {
    switch (statusName) {
      case 'Pending':
        return 'Chờ xét duyệt';
      case 'Reviewing':
        return 'Đang xem xét';
      case 'Shortlisted':
        return 'Đã lọc hồ sơ';
      case 'Interviewing':
        return 'Đang phỏng vấn';
      case 'Offered':
        return 'Đã được offer';
      case 'Accepted':
        return 'Đã chấp nhận';
      case 'Rejected':
        return 'Bị từ chối';
      case 'Withdrawn':
        return 'Đã rút đơn';
      case 'Expired':
        return 'Hết hạn';
      default:
        return statusName; // Giữ nguyên nếu không map được
    }
  }

  Color _getStatusColor(int statusId) {
    switch (statusId) {
      case 1: // Pending
        return Colors.orange;
      case 2: // Reviewing
        return Colors.blue;
      case 3: // Shortlisted
      case 4: // Interviewing
        return Colors.purple;
      case 5: // Offered
      case 6: // Accepted
        return Colors.green;
      case 7: // Rejected
        return Colors.red;
      case 8: // Withdrawn
      case 9: // Expired
      default:
        return Colors.grey;
    }
  }

  Future<void> _handleWithdraw() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận rút đơn'),
        content: const Text(
          'Bạn có chắc chắn muốn rút đơn ứng tuyển này không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huỷ', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Rút đơn', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isWithdrawing = true;
      });

      try {
        await ref
            .read(applicationProvider.notifier)
            .withdrawApplication(widget.application.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã rút đơn ứng tuyển thành công.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isWithdrawing = false;
          });
        }
      }
    }
  }

  Future<void> _viewJobDetails() async {
    try {
      final job = await JobService().getJobById(widget.application.jobPostId);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => JobDetailsScreen(job: job)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Không thể tải chi tiết công việc. Có thể công việc đã bị xoá.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.application;
    final statusColor = _getStatusColor(app.statusId);
    final statusLabel = _getStatusLabel(app.statusName);

    // Cho phép rút đơn khi Pending (1) hoặc Reviewing (2)
    final canWithdraw = app.statusId == 1 || app.statusId == 2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade100,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: app.companyLogoUrl != null
                      ? Image.network(
                          app.companyLogoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Icon(Icons.business),
                        )
                      : const Icon(Icons.business, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.jobTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      app.companyName,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                'Đã nộp: ${app.appliedAt.toLocal().toString().split(' ')[0]}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  if (canWithdraw)
                    _isWithdrawing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            onPressed: _handleWithdraw,
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            tooltip: 'Rút đơn',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                  if (canWithdraw) const SizedBox(width: 16),
                  TextButton(
                    onPressed: _viewJobDetails,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Xem chi tiết',
                      style: TextStyle(
                        color: Color(0xFF0D9D58),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
