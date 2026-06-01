// lib/features/jobpost/viewmodels/my_job_posts_provider.dart
// ViewModel – quản lý state danh sách tin tuyển dụng của Employer (Riverpod 3.x)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_jobfind/features/jobpost/models/job_post_model.dart';
import 'package:app_jobfind/features/jobpost/models/create_job_post_request.dart';
import 'package:app_jobfind/features/jobpost/services/job_post_service.dart';

// ──────────────────────────────────────────────
// State
// ──────────────────────────────────────────────

class MyJobPostsState {
  final List<JobPostModel> jobs;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String? successMessage;

  const MyJobPostsState({
    this.jobs = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.successMessage,
  });

  MyJobPostsState copyWith({
    List<JobPostModel>? jobs,
    bool? isLoading,
    bool? isSaving,
    String? error,
    String? successMessage,
  }) {
    return MyJobPostsState(
      jobs: jobs ?? this.jobs,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      successMessage: successMessage,
    );
  }

  List<JobPostModel> get activeJobs =>
      jobs.where((j) => j.status == 1).toList();
  List<JobPostModel> get draftJobs => jobs.where((j) => j.status == 0).toList();
  List<JobPostModel> get closedJobs =>
      jobs.where((j) => j.status == 2 || j.status == 3).toList();
}

// ──────────────────────────────────────────────
// Providers
// ──────────────────────────────────────────────

final jobPostServiceProvider = Provider<JobPostService>(
  (ref) => JobPostService(),
);

final myJobPostsProvider =
    NotifierProvider<MyJobPostsNotifier, MyJobPostsState>(
      MyJobPostsNotifier.new,
    );

// ──────────────────────────────────────────────
// Notifier (Riverpod 3.x – extends Notifier)
// ──────────────────────────────────────────────

class MyJobPostsNotifier extends Notifier<MyJobPostsState> {
  JobPostService get _service => ref.read(jobPostServiceProvider);

  @override
  MyJobPostsState build() => const MyJobPostsState();

  Future<void> fetchMyJobs() async {
    state = state.copyWith(isLoading: true);
    try {
      final jobs = await _service.getMyJobPosts();
      state = state.copyWith(isLoading: false, jobs: jobs);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<bool> createJob(CreateJobPostRequest request) async {
    state = state.copyWith(isSaving: true);
    try {
      final newJob = await _service.createJobPost(request);
      state = state.copyWith(
        isSaving: false,
        jobs: [newJob, ...state.jobs],
        successMessage: '✅ Tin tuyển dụng đã được đăng thành công!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> updateJob(int id, CreateJobPostRequest request) async {
    state = state.copyWith(isSaving: true);
    try {
      final updated = await _service.updateJobPost(id, request);
      final updatedList = state.jobs
          .map((j) => j.id == id ? updated : j)
          .toList();
      state = state.copyWith(
        isSaving: false,
        jobs: updatedList,
        successMessage: '✅ Cập nhật tin tuyển dụng thành công!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> deleteJob(int id) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.deleteJobPost(id);
      final remaining = state.jobs.where((j) => j.id != id).toList();
      state = state.copyWith(
        isLoading: false,
        jobs: remaining,
        successMessage: 'Đã xóa tin tuyển dụng',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> changeStatus(int id, int status) async {
    try {
      await _service.changeStatus(id, status);
      final updatedList = state.jobs.map((j) {
        if (j.id != id) return j;
        return JobPostModel(
          id: j.id,
          companyId: j.companyId,
          companyName: j.companyName,
          companyLogoUrl: j.companyLogoUrl,
          title: j.title,
          description: j.description,
          requirements: j.requirements,
          benefits: j.benefits,
          salaryMin: j.salaryMin,
          salaryMax: j.salaryMax,
          salaryPeriod: j.salaryPeriod,
          location: j.location,
          workType: j.workType,
          category: j.category,
          numberOfPositions: j.numberOfPositions,
          applicationDeadline: j.applicationDeadline,
          status: status,
          viewCount: j.viewCount,
          applicationCount: j.applicationCount,
          isFeatured: j.isFeatured,
          isUrgent: j.isUrgent,
          createdAt: j.createdAt,
          updatedAt: DateTime.now(),
          requiredSkills: j.requiredSkills,
        );
      }).toList();
      state = state.copyWith(
        jobs: updatedList,
        successMessage: 'Đã cập nhật trạng thái',
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  void clearMessages() {
    state = MyJobPostsState(
      jobs: state.jobs,
      isLoading: state.isLoading,
      isSaving: state.isSaving,
    );
  }
}
