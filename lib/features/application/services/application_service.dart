// lib/features/application/services/application_service.dart

import 'package:app_jobfind/core/api_client.dart';
import 'package:app_jobfind/core/models/paginated_list_dto.dart';
import 'package:app_jobfind/features/application/models/application_dto.dart';
import 'package:app_jobfind/features/application/models/create_application_dto.dart';

class ApplicationService {
  final ApiClient _apiClient = ApiClient();

  /// Lấy danh sách các đơn ứng tuyển của tôi
  Future<PaginatedListDto<ApplicationDto>> getMyApplications({int pageNumber = 1, int pageSize = 50}) async {
    final response = await _apiClient.get('/applications/me', queryParameters: {
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    });
    return PaginatedListDto.fromJson(
      response,
      (item) => ApplicationDto.fromJson(item),
    );
  }

  /// Nộp đơn ứng tuyển mới
  Future<ApplicationDto> createApplication(CreateApplicationDto dto) async {
    final response = await _apiClient.post('/applications', data: dto.toJson());
    return ApplicationDto.fromJson(response);
  }

  /// Rút đơn ứng tuyển
  Future<void> withdrawApplication(int id) async {
    await _apiClient.post('/applications/$id/withdraw');
  }

  /// Lấy danh sách toàn bộ ứng viên đã ứng tuyển của Employer
  Future<PaginatedListDto<ApplicationDto>> getEmployerApplications({int pageNumber = 1, int pageSize = 50}) async {
    final response = await _apiClient.get('/applications/employer', queryParameters: {
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    });
    return PaginatedListDto.fromJson(
      response,
      (item) => ApplicationDto.fromJson(item),
    );
  }

  /// Lấy danh sách ứng viên ứng tuyển theo một tin tuyển dụng cụ thể
  Future<PaginatedListDto<ApplicationDto>> getApplicationsByJob(int jobPostId, {int pageNumber = 1, int pageSize = 50}) async {
    final response = await _apiClient.get('/applications/job/$jobPostId', queryParameters: {
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    });
    return PaginatedListDto.fromJson(
      response,
      (item) => ApplicationDto.fromJson(item),
    );
  }

  /// Cập nhật trạng thái đơn ứng tuyển (Employer)
  Future<void> updateApplicationStatus(int id, {required int statusId, String? notes}) async {
    await _apiClient.patch('/applications/$id/status', data: {
      'statusId': statusId,
      'notes': notes,
    });
  }
}
