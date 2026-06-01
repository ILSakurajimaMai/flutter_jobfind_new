import 'package:app_jobfind/core/api_client.dart';
import 'package:app_jobfind/features/user/models/profile_dto.dart';

/// Lớp Service chịu trách nhiệm giao tiếp trực tiếp với Backend API liên quan đến Profile.
class ProfileService {
  final ApiClient _apiClient;
  ProfileService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  /// Hàm gọi lệnh lấy thông tin hồ sơ của chính người dùng đang đăng nhập
  Future<ProfileDto> getMyProfile() async {
    final data = await _apiClient.get('/profile/me');
    return ProfileDto.fromJson(data);
  }

  /// Hàm gửi yêu cầu cập nhật hồ sơ cá nhân
  Future<ProfileDto> updateProfile(ProfileDto dto) async {
    final data = await _apiClient.put('/profile/me', data: dto.toJson());
    return ProfileDto.fromJson(data);
  }
}
