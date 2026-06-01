import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_jobfind/features/job/models/job_post_dto.dart';
import 'package:app_jobfind/features/job/services/job_service.dart';

final jobServiceProvider = Provider<JobService>((ref) {
  return JobService();
});

/// State lưu trữ danh sách tin tuyển dụng
class JobsState {
  final bool isLoading;
  final String? error;
  final List<JobPostDto> jobs;

  JobsState({this.isLoading = false, this.error, this.jobs = const []});

  JobsState copyWith({bool? isLoading, String? error, List<JobPostDto>? jobs}) {
    return JobsState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // Error có thể truyền null để xóa lỗi
      jobs: jobs ?? this.jobs,
    );
  }
}

class JobNotifier extends Notifier<JobsState> {
  @override
  JobsState build() {
    // Tự động load khi khởi tạo provider
    Future.microtask(() => fetchJobs());
    return JobsState();
  }

  Future<void> fetchJobs() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final service = ref.read(jobServiceProvider);
      final paginatedData = await service.getAllJobs();
      state = state.copyWith(
        isLoading: false,
        jobs: paginatedData.items,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> searchJobs(String searchTerm) async {
    if (searchTerm.trim().isEmpty) {
      await fetchJobs();
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final service = ref.read(jobServiceProvider);
      final paginatedData = await service.searchJobs(searchTerm);
      state = state.copyWith(
        isLoading: false,
        jobs: paginatedData.items,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final jobsProvider = NotifierProvider<JobNotifier, JobsState>(JobNotifier.new);
