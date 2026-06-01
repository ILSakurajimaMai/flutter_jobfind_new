import 'package:app_jobfind/core/api_client.dart';
import 'package:app_jobfind/core/models/paginated_list_dto.dart';
import 'package:app_jobfind/features/job/models/job_post_dto.dart';
import 'package:app_jobfind/features/job/models/company_dto.dart';

class JobService {
  final ApiClient _apiClient;
  JobService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<PaginatedListDto<JobPostDto>> getAllJobs({int page = 1, int pageSize = 50}) async {
    final data = await _apiClient.get(
      '/jobposts',
      queryParameters: {
        'pageNumber': page,
        'pageSize': pageSize,
      },
    );
    
    if (data is Map<String, dynamic> && data.containsKey('items')) {
       return PaginatedListDto.fromJson(data, JobPostDto.fromJson);
    }
    
    if (data is List) {
      final list = data.map((e) => JobPostDto.fromJson(e as Map<String, dynamic>)).toList();
      return PaginatedListDto(
        items: list,
        pageNumber: 1,
        totalPages: 1,
        totalCount: list.length,
        hasPreviousPage: false,
        hasNextPage: false,
      );
    }

    throw Exception('Định dạng dữ liệu không xác định từ Backend');
  }

  Future<PaginatedListDto<JobPostDto>> searchJobs(String searchTerm, {int page = 1, int pageSize = 50}) async {
    final data = await _apiClient.get(
      '/jobposts/search',
      queryParameters: {
        'searchTerm': searchTerm,
        'pageNumber': page,
        'pageSize': pageSize,
      },
    );
    
    if (data is Map<String, dynamic> && data.containsKey('items')) {
       return PaginatedListDto.fromJson(data, JobPostDto.fromJson);
    }
    
    if (data is List) {
      final list = data.map((e) => JobPostDto.fromJson(e as Map<String, dynamic>)).toList();
      return PaginatedListDto(
        items: list,
        pageNumber: 1,
        totalPages: 1,
        totalCount: list.length,
        hasPreviousPage: false,
        hasNextPage: false,
      );
    }

    throw Exception('Định dạng dữ liệu không xác định từ Backend');
  }

  Future<JobPostDto> getJobById(int id) async {
    final data = await _apiClient.get('/jobposts/$id');
    return JobPostDto.fromJson(data);
  }

  Future<CompanyDto> getCompanyById(int id) async {
    final data = await _apiClient.get('/companies/$id');
    return CompanyDto.fromJson(data);
  }
}
