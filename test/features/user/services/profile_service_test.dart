import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_jobfind/core/api_client.dart';
import 'package:app_jobfind/features/user/services/profile_service.dart';
import 'package:app_jobfind/features/user/models/profile_dto.dart';
import 'package:app_jobfind/core/exceptions/api_exception.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late ProfileService profileService;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    profileService = ProfileService(apiClient: mockApiClient);
  });

  group('ProfileService', () {
    final mockProfileResponse = {
      'id': '1',
      'email': 'user@example.com',
      'firstName': 'John',
      'lastName': 'Doe',
    };

    test('getMyProfile returns ProfileDto on success', () async {
      when(
        () => mockApiClient.get('/profile/me'),
      ).thenAnswer((_) async => mockProfileResponse);

      final result = await profileService.getMyProfile();

      expect(result, isA<ProfileDto>());
      verify(() => mockApiClient.get('/profile/me')).called(1);
    });

    test('getMyProfile throws ApiException on failure', () async {
      when(
        () => mockApiClient.get('/profile/me'),
      ).thenThrow(ApiException('Lỗi server', 500));

      expect(() => profileService.getMyProfile(), throwsA(isA<ApiException>()));
    });
  });
}
