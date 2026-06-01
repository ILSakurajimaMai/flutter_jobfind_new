// lib/features/application/viewmodels/application_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_jobfind/features/application/models/application_dto.dart';
import 'package:app_jobfind/features/application/models/create_application_dto.dart';
import 'package:app_jobfind/features/application/services/application_service.dart';
import 'package:app_jobfind/features/auth/viewmodels/auth_provider.dart';

final applicationServiceProvider = Provider((ref) => ApplicationService());

final applicationProvider = AsyncNotifierProvider<ApplicationNotifier, List<ApplicationDto>>(() {
  return ApplicationNotifier();
});

class ApplicationNotifier extends AsyncNotifier<List<ApplicationDto>> {
  @override
  Future<List<ApplicationDto>> build() async {
    ref.watch(authProvider); // Tự động reset state khi authProvider thay đổi (Logout/Login)
    
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) return [];

    final service = ref.read(applicationServiceProvider);
    final response = await service.getMyApplications();
    return response.items;
  }

  Future<void> fetchMyApplications() async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(applicationServiceProvider);
      final response = await service.getMyApplications();
      state = AsyncValue.data(response.items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> applyForJob({
    required int jobId,
    int? cvId,
    String? coverLetter,
    String? resumeUrl,
  }) async {
    try {
      final service = ref.read(applicationServiceProvider);
      final dto = CreateApplicationDto(
        jobPostId: jobId,
        profileId: cvId,
        coverLetter: coverLetter,
        resumeUrl: resumeUrl,
      );
      final newApp = await service.createApplication(dto);
      
      if (state.hasValue) {
        final existingIndex = state.value!.indexWhere((app) => app.id == newApp.id);
        if (existingIndex >= 0) {
          // Backend tái sử dụng ID cũ (Re-activate). Cập nhật đè lên thay vì thêm mới để tránh trùng ID.
          final updatedList = List<ApplicationDto>.from(state.value!);
          updatedList[existingIndex] = newApp;
          state = AsyncValue.data(updatedList);
        } else {
          // ID mới hoàn toàn, thêm vào mảng
          state = AsyncValue.data([...state.value!, newApp]);
        }
      } else {
        state = AsyncValue.data([newApp]);
      }
    } catch (e) {
      // Re-throw to be caught by UI
      rethrow;
    }
  }
  Future<void> withdrawApplication(int applicationId) async {
    try {
      final service = ref.read(applicationServiceProvider);
      await service.withdrawApplication(applicationId);
      
      if (state.hasValue) {
        state = AsyncValue.data(
          state.value!.map((app) {
            if (app.id == applicationId) {
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
                statusId: 8, // Withdrawn
                statusName: 'Withdrawn',
                coverLetter: app.coverLetter,
                resumeUrl: app.resumeUrl,
                appliedAt: app.appliedAt,
                reviewedAt: app.reviewedAt,
                reviewNotes: app.reviewNotes,
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
