// Dịch vụ (Service) xử lý các API liên quan đến xác thực (Auth) như Đăng nhập, Đăng ký.
import 'package:app_jobfind/core/api_client.dart';
import 'package:app_jobfind/features/auth/models/login_dto.dart';
import 'package:app_jobfind/features/auth/models/register_dto.dart';
import 'package:app_jobfind/features/auth/models/auth_response_dto.dart';
import 'package:app_jobfind/features/auth/models/change_password_dto.dart';

/// Lớp [AuthService] quản lý các API liên quan đến tài khoản người dùng.
class AuthService {
  /// Đối tượng gọi API có cấu hình sẵn tự động gắn JWT Token.
  final ApiClient _apiClient;

  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Đăng nhập hệ thống qua `/auth/login`.
  /// - Gửi Email, Password từ [LoginScreen]
  /// - Thành công: Trả về [AuthResponseDto] (chứa Token, thông tin user).
  /// - Thất bại: Ném ApiException kèm câu lỗi.
  Future<AuthResponseDto> login(LoginDto dto) async {
    final data = await _apiClient.post(
      '/auth/login',
      data: dto.toJson(),
    );
    return AuthResponseDto.fromJson(data);
  }

  /// Đăng ký tài khoản mới qua `/auth/register`.
  /// - Gửi thông tin (Email, Pass, Role...) từ [RegisterScreen]
  /// - Thành công: Trả về Map chứa thông báo hoặc Data khởi tạo.
  /// - Thất bại: Ném ApiException kèm câu lỗi.
  Future<Map<String, dynamic>> register(RegisterDto dto) async {
    final data = await _apiClient.post(
      '/auth/register',
      data: dto.toJson(),
    );
    return data as Map<String, dynamic>;
  }
  /// Đổi mật khẩu qua `/auth/change-password`
  /// - Thành công: Trả về Map (có thể có message)
  /// - Thất bại: Ném ApiException
  Future<Map<String, dynamic>> changePassword(ChangePasswordDto dto) async {
    final data = await _apiClient.post(
      '/auth/change-password',
      data: dto.toJson(),
    );
    return data as Map<String, dynamic>;
  }
}
