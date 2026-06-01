import 'dart:typed_data';
import 'package:app_jobfind/core/api_client.dart';
import 'package:app_jobfind/features/cv/models/cv_dto.dart';
import 'package:dio/dio.dart' as dio;

/// Lớp Service chịu trách nhiệm giao tiếp trực tiếp với Backend API liên quan đến CV.
class CvService {
  final ApiClient _apiClient = ApiClient();

  /// Lấy danh sách tất cả CV của user hiện tại
  Future<List<CvDto>> getMyCvs() async {
    final data = await _apiClient.get('/cvs/my');
    return (data as List).map((e) => CvDto.fromJson(e)).toList();
  }

  /// Lấy CV mặc định của user hiện tại
  Future<CvDto> getMyDefaultCv() async {
    final data = await _apiClient.get('/cvs/me');
    return CvDto.fromJson(data);
  }

  /// Lấy chi tiết 1 CV theo ID
  Future<CvDto> getCvById(int id) async {
    final data = await _apiClient.get('/cvs/$id');
    return CvDto.fromJson(data);
  }

  /// Tạo mới 1 CV
  Future<CvDto> createCv(CvDto dto) async {
    final data = await _apiClient.post('/cvs', data: dto.toJson());
    return CvDto.fromJson(data);
  }

  /// Cập nhật CV
  Future<CvDto> updateCv(int id, CvDto dto) async {
    final data = await _apiClient.put('/cvs/$id', data: dto.toJson());
    return CvDto.fromJson(data);
  }

  /// Đặt CV làm mặc định
  Future<void> setDefaultCv(int cvId) async {
    await _apiClient.post('/cvs/$cvId/set-default');
  }

  /// Xóa CV
  Future<void> deleteCv(int cvId) async {
    await _apiClient.delete('/cvs/$cvId');
  }

  /// Upload file CV (dùng bytes để hỗ trợ cả Android, iOS lẫn Web)
  Future<String> uploadCvFile(Uint8List bytes, String fileName) async {
    final formData = dio.FormData.fromMap({
      'folder': 'cvs',
      'file': dio.MultipartFile.fromBytes(bytes, filename: fileName),
    });

    final data = await _apiClient.uploadFile('/files/upload', formData);
    return data as String; // URL file trả về
  }

  /// Xoá file vật lý
  Future<void> deleteFile(String fileUrl) async {
    await _apiClient.delete('/files', queryParameters: {'fileUrl': fileUrl});
  }
}
