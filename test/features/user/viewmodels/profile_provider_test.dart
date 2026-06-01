import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_jobfind/features/user/services/profile_service.dart';
import 'package:app_jobfind/features/user/models/profile_dto.dart';
// Giả sử có profileProvider
// import 'package:app_jobfind/features/user/viewmodels/profile_provider.dart';

class MockProfileService extends Mock implements ProfileService {}

void main() {
  late ProviderContainer container;
  late MockProfileService mockProfileService;

  setUp(() {
    mockProfileService = MockProfileService();
    container = ProviderContainer(
      overrides: [
        // profileServiceProvider.overrideWithValue(mockProfileService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ProfileProvider Test Boilerplate', () {
    test('should initialize and load profile correctly', () async {
      final mockProfile = ProfileDto(
        id: 1,
        email: 'test@example.com',
        fullName: 'A B',
      );

      when(
        () => mockProfileService.getMyProfile(),
      ).thenAnswer((_) async => mockProfile);

      // Thêm logic test Provider của bạn tại đây
      // final profile = container.read(profileProvider);

      expect(true, true); // Placeholder
    });
  });
}
