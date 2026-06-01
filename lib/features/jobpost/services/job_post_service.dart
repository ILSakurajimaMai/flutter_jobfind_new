// lib/features/jobpost/services/job_post_service.dart
// Service layer – gọi API backend cho tính năng tin tuyển dụng

import 'package:app_jobfind/core/api_client.dart';
import 'package:app_jobfind/features/jobpost/models/job_post_model.dart';
import 'package:app_jobfind/features/jobpost/models/create_job_post_request.dart';

class JobPostService {
  final ApiClient _apiClient = ApiClient();

  /// Lấy danh sách tin tuyển dụng của Employer đang đăng nhập
  Future<List<JobPostModel>> getMyJobPosts() async {
    final data = await _apiClient.get('/jobposts/my');
    return (data as List).map((e) => JobPostModel.fromJson(e)).toList();
  }

  /// Lấy chi tiết 1 tin
  Future<JobPostModel> getById(int id) async {
    final data = await _apiClient.get('/jobposts/$id');
    return JobPostModel.fromJson(data);
  }

  /// Lấy tất cả tin công khai (dùng cho Student)
  Future<List<JobPostModel>> getAllPublic({int page = 1, int pageSize = 20}) async {
    final data = await _apiClient.get(
      '/jobposts',
      queryParameters: {'pageNumber': page, 'pageSize': pageSize},
    );
    // Backend trả PaginatedList: { items: [...], ... }
    final items = data is Map ? (data['items'] ?? data) : data;
    return (items as List).map((e) => JobPostModel.fromJson(e)).toList();
  }

  /// Tạo tin tuyển dụng mới
  Future<JobPostModel> createJobPost(CreateJobPostRequest request) async {
    final data = await _apiClient.post('/jobposts', data: request.toJson());
    return JobPostModel.fromJson(data);
  }

  /// Cập nhật tin tuyển dụng
  Future<JobPostModel> updateJobPost(int id, CreateJobPostRequest request) async {
    final data = await _apiClient.put('/jobposts/$id', data: request.toJson());
    return JobPostModel.fromJson(data);
  }

  /// Xóa tin tuyển dụng
  Future<void> deleteJobPost(int id) async {
    await _apiClient.delete('/jobposts/$id');
  }

  /// Thay đổi trạng thái tin: 0=Draft, 1=Active, 2=Closed
  Future<void> changeStatus(int id, int status) async {
    await _apiClient.patch('/jobposts/$id/status', data: status);
  }
}

// Extension cho ApiClient để hỗ trợ PATCH
extension ApiClientPatch on ApiClient {
  Future<dynamic> patch(String path, {dynamic data}) async {
    try {
      final response = await dio.patch(path, data: data);
      if (response.data is Map<String, dynamic>) {
        final success = response.data['success'];
        if (success == true) return response.data['data'];
        throw Exception(response.data['message'] ?? 'Lỗi');
      }
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
