import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_jobfind/features/auth/models/login_dto.dart';
import 'package:app_jobfind/features/auth/models/auth_response_dto.dart';
import 'package:app_jobfind/features/auth/services/auth_service.dart';
import 'package:app_jobfind/features/auth/viewmodels/auth_provider.dart';
import 'package:app_jobfind/core/exceptions/api_exception.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late ProviderContainer container;
  late MockAuthService mockAuthService;

  setUp(() {
    // 1. Giả lập SharedPreferences rỗng ban đầu để AuthNotifier không bị lỗi khi khởi tạo
    SharedPreferences.setMockInitialValues({});
    
    // 2. Giả lập Service
    mockAuthService = MockAuthService();

    // 3. Khởi tạo ProviderContainer và ghi đè (override) authServiceProvider
    container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(mockAuthService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthNotifier - Login', () {
    final loginDto = LoginDto(email: 'test@example.com', password: 'password123');
    final mockResponse = AuthResponseDto(
      userId: 1,
      email: 'test@example.com',
      fullName: 'Test User',
      roles: ['USER'],
      accessToken: 'dummy_token',
      refreshToken: 'dummy_refresh',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );

    test('login success should update state to authenticated', () async {
      // Arrange
      when(() => mockAuthService.login(any())).thenAnswer((_) async => mockResponse);

      // Lấy notifier
      final notifier = container.read(authProvider.notifier);

      // Act
      // Lưu ý: Cần await do login là hàm bất đồng bộ
      final success = await notifier.login(loginDto);

      // Assert
      expect(success, true);
      
      // Đọc state cuối cùng
      final state = container.read(authProvider);
      
      expect(state.isLoading, false);
      expect(state.isAuthenticated, true);
      expect(state.user?.email, 'test@example.com');
      expect(state.error, null);
    });

    test('login failure should update state with error message', () async {
      // Arrange
      when(() => mockAuthService.login(any()))
          .thenThrow(ApiException('Sai mật khẩu', 400));

      final notifier = container.read(authProvider.notifier);

      // Act
      final success = await notifier.login(loginDto);

      // Assert
      expect(success, false);
      
      final state = container.read(authProvider);
      expect(state.isLoading, false);
      expect(state.isAuthenticated, false);
      expect(state.error, contains('Sai mật khẩu'));
    });
  });
}
