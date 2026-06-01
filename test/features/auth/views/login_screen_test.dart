import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_jobfind/features/auth/views/login_screen.dart';
import 'package:app_jobfind/features/auth/services/auth_service.dart';
import 'package:app_jobfind/core/exceptions/api_exception.dart';
import 'package:app_jobfind/features/auth/models/login_dto.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockAuthService mockAuthService;

  setUpAll(() {
    // Đăng ký fallback value cho bất kỳ tham số LoginDto nào được truyền vào hàm mock
    registerFallbackValue(LoginDto(email: '', password: ''));
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockAuthService = MockAuthService();
  });

  Widget createLoginScreen() {
    return ProviderScope(
      overrides: [
        // Ghi đè Service thực tế bằng Mock Service
        authServiceProvider.overrideWithValue(mockAuthService),
      ],
      child: const MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('hiển thị đầy đủ UI tĩnh ban đầu', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Kiểm tra xem chữ "Welcome Back" và các TextField có tồn tại trên màn hình không
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      
      // Nút LOGIN
      expect(find.text('LOGIN'), findsOneWidget);
    });

    testWidgets('hiển thị báo lỗi form rỗng khi không điền gì mà bấm Login', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Tìm nút LOGIN và bấm
      final loginButton = find.text('LOGIN');
      await tester.tap(loginButton);
      
      // Chờ form hiển thị báo lỗi (Animation)
      await tester.pump();

      // Kiểm tra có thông báo bắt buộc nhập
      expect(find.text('Please enter an email'), findsOneWidget);
      expect(find.text('Please enter a password'), findsOneWidget);
    });

    testWidgets('hiển thị SnackBar báo lỗi khi API trả về lỗi', (WidgetTester tester) async {
      // Arrange: Cấu hình Mock ném ra lỗi khi gọi hàm login
      when(() => mockAuthService.login(any()))
          .thenThrow(ApiException('Tài khoản không tồn tại', 404));

      await tester.pumpWidget(createLoginScreen());

      // Nhập text
      await tester.enterText(find.byType(TextFormField).at(0), 'test@gmail.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');

      // Bấm đăng nhập
      await tester.tap(find.text('LOGIN'));

      // Chờ State thay đổi (bắt đầu gọi api) -> Màn hình sẽ chuyển sang loading (vòng xoay vòng)
      await tester.pump(); 

      // Kiểm tra xem vòng tròn loading có hiện lên không
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Chờ xử lý Future login xong
      await tester.pumpAndSettle();

      // Kiểm tra SnackBar đỏ hiển thị thông báo lỗi
      expect(find.text('Tài khoản không tồn tại'), findsOneWidget);
    });
  });
}
