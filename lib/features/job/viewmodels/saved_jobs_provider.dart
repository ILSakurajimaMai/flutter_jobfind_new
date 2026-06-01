import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_jobfind/features/job/models/job_post_dto.dart';
import 'package:app_jobfind/features/auth/viewmodels/auth_provider.dart';

class SavedJobsNotifier extends Notifier<List<JobPostDto>> {
  @override
  List<JobPostDto> build() {
    ref.watch(authProvider); // Tự động reset state khi authProvider thay đổi (Logout/Login)
    return [];
  }

  void toggleSave(JobPostDto job) {
    if (state.any((j) => j.id == job.id)) {
      state = state.where((j) => j.id != job.id).toList();
    } else {
      state = [...state, job];
    }
  }

  bool isSaved(int jobId) {
    return state.any((j) => j.id == jobId);
  }
}

final savedJobsProvider = NotifierProvider<SavedJobsNotifier, List<JobPostDto>>(SavedJobsNotifier.new);
