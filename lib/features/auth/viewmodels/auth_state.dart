import 'package:app_jobfind/features/auth/models/auth_response_dto.dart';

/// Trạng thái cốt lõi của tiến trình Đăng nhập / Đăng ký (Authentication)
/// Lưu trữ cờ báo hiệu (loading), lỗi (nếu có), đối tượng thông tin người dùng và trạng thái đăng nhập.
class AuthState {
  final bool isLoading; // Đánh dấu API Đăng nhập/Đăng ký đang chạy (để hiện vòng xoay quay)
  final String? error; // Lưu trữ chuỗi thông báo lỗi ném về từ server nếu có
  final AuthResponseDto? user; // Lưu trữ đối tượng DTO chứa Token bảo mật & Role của User
  final bool isAuthenticated; // Cờ theo dõi người dùng đã đăng nhập hợp lệ hay chưa

  AuthState({
    this.isLoading = false,
    this.error,
    this.user,
    this.isAuthenticated = false,
  });

  /// Hàm copyWith giúp tạo mới state bằng cách sao chép thuộc tính cũ và đè dữ liệu mới lên
  AuthState copyWith({
    bool? isLoading,
    String? error,
    AuthResponseDto? user,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // Có thể cố ý đè error thành null khi bắt đầu chạy hàm mới
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}
