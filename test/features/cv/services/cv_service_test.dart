import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_jobfind/core/api_client.dart';
import 'package:app_jobfind/features/cv/services/cv_service.dart';
import 'package:app_jobfind/features/cv/models/cv_dto.dart';
import 'package:app_jobfind/core/exceptions/api_exception.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late CvService cvService;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    cvService = CvService(apiClient: mockApiClient);
  });

  group('CvService', () {
    final mockResponse = [
      {'id': '1', 'fileUrl': 'https://example.com/cv.pdf', 'isDefault': true},
    ];

    test('getMyCvs returns List<CvDto> on success', () async {
      when(
        () => mockApiClient.get('/cvs/my-cvs'),
      ).thenAnswer((_) async => mockResponse);

      final result = await cvService.getMyCvs();

      expect(result, isA<List<CvDto>>());
      expect(result.length, 1);
      verify(() => mockApiClient.get('/cvs/my-cvs')).called(1);
    });

    test('getMyCvs throws ApiException on failure', () async {
      when(
        () => mockApiClient.get('/cvs/my-cvs'),
      ).thenThrow(ApiException('Not found', 404));

      expect(() => cvService.getMyCvs(), throwsA(isA<ApiException>()));
    });
  });
}
