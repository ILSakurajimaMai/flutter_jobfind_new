// lib/features/employer/services/company_service.dart

import 'package:app_jobfind/core/api_client.dart';
import 'package:app_jobfind/features/employer/models/company_dto.dart';

class CompanyService {
  final ApiClient _apiClient = ApiClient();

  Future<CompanyDto> getMyCompany() async {
    final response = await _apiClient.get('/companies/me');
    return CompanyDto.fromJson(response);
  }

  Future<CompanyDto?> getMyPendingRequest() async {
    try {
      final response = await _apiClient.get('/companies/pending-request');
      return CompanyDto.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<CompanyDto> createCompany(CompanyDto dto) async {
    final response = await _apiClient.post('/companies', data: dto.toJson());
    return CompanyDto.fromJson(response);
  }

  Future<CompanyDto> updateCompany(int id, CompanyDto dto) async {
    final response = await _apiClient.put('/companies/$id', data: dto.toJson());
    return CompanyDto.fromJson(response);
  }
}
