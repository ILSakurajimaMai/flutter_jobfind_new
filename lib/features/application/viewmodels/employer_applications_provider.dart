// lib/features/application/viewmodels/employer_applications_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_jobfind/features/application/models/application_dto.dart';
import 'package:app_jobfind/features/application/viewmodels/application_provider.dart';
import 'package:app_jobfind/features/auth/viewmodels/auth_provider.dart';

final employerApplicationsProvider = AsyncNotifierProvider<EmployerApplicationsNotifier, List<ApplicationDto>>(() {
  return EmployerApplicationsNotifier();
});

class EmployerApplicationsNotifier extends AsyncNotifier<List<ApplicationDto>> {
  @override
  Future<List<ApplicationDto>> build() async {
    ref.watch(authProvider); // Tự động reset state khi auth thay đổi (đăng nhập/đăng xuất)
    
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated || authState.user == null) return [];

    final service = ref.read(applicationServiceProvider);
    final response = await service.getEmployerApplications();
    return response.items;
  }

  /// Tải danh sách ứng viên (Tất cả bài đăng hoặc Một bài đăng cụ thể)
  Future<void> fetchApplications({int? jobPostId}) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(applicationServiceProvider);
      if (jobPostId != null) {
        final response = await service.getApplicationsByJob(jobPostId);
        state = AsyncValue.data(response.items);
      } else {
        final response = await service.getEmployerApplications();
        state = AsyncValue.data(response.items);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Cập nhật trạng thái của đơn ứng tuyển
  Future<void> updateStatus(int id, int statusId, {String? notes}) async {
    try {
      final service = ref.read(applicationServiceProvider);
      await service.updateApplicationStatus(id, statusId: statusId, notes: notes);
      
      if (state.hasValue) {
        String statusName;
        switch (statusId) {
          case 1:
            statusName = 'Pending';
            break;
          case 2:
            statusName = 'Reviewing';
            break;
          case 3:
            statusName = 'Shortlisted';
            break;
          case 4:
            statusName = 'Interviewing';
            break;
          case 5:
            statusName = 'Offered';
            break;
          case 6:
            statusName = 'Accepted';
            break;
          case 7:
            statusName = 'Rejected';
            break;
          case 8:
            statusName = 'Withdrawn';
            break;
          case 9:
            statusName = 'Expired';
            break;
          default:
            statusName = 'Unknown';
        }

        // Cập nhật trạng thái cục bộ ngay lập tức để UI cập nhật mượt mà
        state = AsyncValue.data(
          state.value!.map((app) {
            if (app.id == id) {
              return ApplicationDto(
                id: app.id,
                jobPostId: app.jobPostId,
                jobTitle: app.jobTitle,
                companyName: app.companyName,
                companyLogoUrl: app.companyLogoUrl,
                employerId: app.employerId,
                employerName: app.employerName,
                profileId: app.profileId,
                applicantName: app.applicantName,
                statusId: statusId,
                statusName: statusName,
                coverLetter: app.coverLetter,
                resumeUrl: app.resumeUrl,
                appliedAt: app.appliedAt,
                reviewedAt: DateTime.now(),
                reviewNotes: notes,
              );
            }
            return app;
          }).toList(),
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
