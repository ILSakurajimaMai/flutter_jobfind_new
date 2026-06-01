import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_jobfind/core/api_client.dart';
import 'package:app_jobfind/features/jobpost/services/job_post_service.dart';
import 'package:app_jobfind/features/jobpost/models/job_post_model.dart';
import 'package:app_jobfind/core/exceptions/api_exception.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late JobPostService jobPostService;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    jobPostService = JobPostService(apiClient: mockApiClient);
  });

  group('JobPostService', () {
    final mockResponse = [
      {'id': 1, 'title': 'Flutter Developer'},
    ];

    test('getMyJobPosts returns List<JobPostModel> on success', () async {
      when(
        () => mockApiClient.get('/jobposts/my'),
      ).thenAnswer((_) async => mockResponse);

      final result = await jobPostService.getMyJobPosts();

      expect(result, isA<List<JobPostModel>>());
      expect(result.length, 1);
      verify(() => mockApiClient.get('/jobposts/my')).called(1);
    });

    test('getMyJobPosts throws ApiException on failure', () async {
      when(
        () => mockApiClient.get('/jobposts/my'),
      ).thenThrow(ApiException('Unauthorized', 401));

      expect(
        () => jobPostService.getMyJobPosts(),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
