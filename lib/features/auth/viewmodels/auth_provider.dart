import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_jobfind/features/auth/models/login_dto.dart';
import 'package:app_jobfind/features/auth/models/register_dto.dart';
import 'package:app_jobfind/features/auth/models/change_password_dto.dart';
import 'package:app_jobfind/features/auth/models/auth_response_dto.dart';
import 'package:app_jobfind/features/auth/services/auth_service.dart';
import 'auth_state.dart';

/// Provider cung cấp đối tượng AuthService để gửi API đi bất kì đâu (tương tự ProfileService)
final authServiceProvider = Provider((ref) => AuthService());

/// AuthProvider chịu trách nhiệm nắm giữ khóa Token và đẩy trạng thái đăng nhập xuống cho các Widget UI (như SplashScreen, LoginScreen)
final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Ngay lúc khởi tạo app (tại hàm build), thì lập tức rà soát xem cục Local Preferences có token dư không
    _checkInitialAuth();
    return AuthState(); // Khởi tạo state gốc khởi điểm
  }

  /// Hàm kiểm tra Token nội bộ tự chạy ngầm
  /// Kiểm tra token tồn tại VÀ còn hạn trước khi cho vào app
  Future<void> _checkInitialAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null || token.isEmpty) return;

    // Kiểm tra expiresAt đã lưu
    final expiresAtStr = prefs.getString('expiresAt');
    if (expiresAtStr != null) {
      final expiresAt = DateTime.tryParse(expiresAtStr);
      if (expiresAt != null && expiresAt.isBefore(DateTime.now())) {
        // Token hết hạn → xóa, không cho vào app
        await prefs.remove('accessToken');
        await prefs.remove('refreshToken');
        await prefs.remove('expiresAt');
        await prefs.remove('userId');
        await prefs.remove('email');
        await prefs.remove('fullName');
        await prefs.remove('roles');
        return;
      }
    }

    final userId = prefs.getInt('userId') ?? 0;
    final email = prefs.getString('email') ?? '';
    final fullName = prefs.getString('fullName');
    final roles = prefs.getStringList('roles') ?? [];
    final refreshToken = prefs.getString('refreshToken') ?? '';
    final expiresAt = DateTime.tryParse(expiresAtStr ?? '') ?? DateTime.now();

    final user = AuthResponseDto(
      userId: userId,
      email: email,
      fullName: fullName,
      roles: roles,
      accessToken: token,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
    );

    state = state.copyWith(
      isAuthenticated: true,
      user: user,
    );
  }

  /// Hàm Đăng Nhập
  Future<bool> login(LoginDto dto) async {
    // Sửa trạng thái thành "Đang Load"
    state = state.copyWith(isLoading: true, error: null);
    try {
      final authService = ref.read(authServiceProvider);
      final userResponse = await authService.login(dto);

      // Lưu token + expiresAt vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', userResponse.accessToken);
      await prefs.setString('refreshToken', userResponse.refreshToken);
      await prefs.setString('expiresAt', userResponse.expiresAt.toIso8601String());
      await prefs.setInt('userId', userResponse.userId);
      await prefs.setString('email', userResponse.email);
      if (userResponse.fullName != null) {
        await prefs.setString('fullName', userResponse.fullName!);
      } else {
        await prefs.remove('fullName');
      }
      await prefs.setStringList('roles', userResponse.roles);

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: userResponse,
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

  /// Hàm Đăng Ký 
  Future<bool> register(RegisterDto dto) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final authService = ref.read(authServiceProvider);
      // Đợi việc đăng ký được xác nhận (API Register ném 200)
      await authService.register(dto);
      
      // Xong thì tắt Loading, State vẫn vậy (chưa authenticated vì cần bắt người dùng tự gõ pass để đăng nhập tay lại một lần cho chắc)
      state = state.copyWith(isLoading: false);
      return true; 
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false; 
    }
  }

  /// Hàm Đăng Xuất (Log out)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('expiresAt');
    await prefs.remove('userId');
    await prefs.remove('email');
    await prefs.remove('fullName');
    await prefs.remove('roles');
    state = AuthState();
  }

  /// Hàm Đổi mật khẩu
  Future<bool> changePassword(ChangePasswordDto dto) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final authService = ref.read(authServiceProvider);
      await authService.changePassword(dto);
      
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }
}
