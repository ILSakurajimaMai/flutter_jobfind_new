import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_jobfind/core/api_client.dart';
import 'package:app_jobfind/features/auth/services/auth_service.dart';
import 'package:app_jobfind/features/auth/models/login_dto.dart';
import 'package:app_jobfind/features/auth/models/auth_response_dto.dart';
import 'package:app_jobfind/core/exceptions/api_exception.dart';

// 1. Tạo class Mock cho ApiClient
class MockApiClient extends Mock implements ApiClient {}

void main() {
  late AuthService authService;
  late MockApiClient mockApiClient;

  // Chạy trước mỗi test case
  setUp(() {
    mockApiClient = MockApiClient();
    // Inject mockApiClient vào AuthService
    authService = AuthService(apiClient: mockApiClient);
  });

  group('AuthService - Login', () {
    final loginDto = LoginDto(email: 'test@example.com', password: 'password123');
    final mockLoginResponse = {
      'accessToken': 'dummy_access_token',
      'refreshToken': 'dummy_refresh_token',
      'user': {
        'id': '1',
        'email': 'test@example.com',
        'role': 'user',
      }
    };

    test('should return AuthResponseDto on successful login', () async {
      // Arrange: Giả lập ApiClient trả về dữ liệu thành công khi gọi post
      when(() => mockApiClient.post('/auth/login', data: loginDto.toJson()))
          .thenAnswer((_) async => mockLoginResponse);

      // Act: Gọi phương thức login
      final result = await authService.login(loginDto);

      // Assert: Kiểm tra kết quả
      expect(result, isA<AuthResponseDto>());
      expect(result.accessToken, 'dummy_access_token');
      expect(result.user.email, 'test@example.com');
      
      // Xác minh ApiClient.post đã được gọi đúng 1 lần với đúng tham số
      verify(() => mockApiClient.post('/auth/login', data: loginDto.toJson())).called(1);
    });

    test('should throw ApiException on login failure', () async {
      // Arrange: Giả lập ApiClient ném lỗi ApiException
      when(() => mockApiClient.post('/auth/login', data: loginDto.toJson()))
          .thenThrow(ApiException('Sai email hoặc mật khẩu', 400));

      // Act & Assert: Kiểm tra lỗi được ném ra
      expect(() => authService.login(loginDto), throwsA(isA<ApiException>()));
    });
  });
}
