import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_jobfind/core/api_client.dart';
import 'package:app_jobfind/features/job/services/job_service.dart';
import 'package:app_jobfind/core/exceptions/api_exception.dart';
import 'package:app_jobfind/core/models/paginated_list_dto.dart';
import 'package:app_jobfind/features/job/models/job_post_dto.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late JobService jobService;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    jobService = JobService(apiClient: mockApiClient);
  });

  group('JobService', () {
    final mockResponse = {
      'items': [
        {'id': 1, 'title': 'Developer'},
      ],
      'pageNumber': 1,
      'totalPages': 1,
      'totalCount': 1,
      'hasPreviousPage': false,
      'hasNextPage': false,
    };

    test('getAllJobs returns PaginatedListDto on success', () async {
      when(
        () => mockApiClient.get(
          '/jobposts',
          queryParameters: {'pageNumber': 1, 'pageSize': 50},
        ),
      ).thenAnswer((_) async => mockResponse);

      final result = await jobService.getAllJobs(page: 1, pageSize: 50);

      expect(result, isA<PaginatedListDto<JobPostDto>>());
      verify(
        () => mockApiClient.get(
          '/jobposts',
          queryParameters: {'pageNumber': 1, 'pageSize': 50},
        ),
      ).called(1);
    });

    test('getAllJobs throws ApiException on failure', () async {
      when(
        () => mockApiClient.get(
          '/jobposts',
          queryParameters: {'pageNumber': 1, 'pageSize': 50},
        ),
      ).thenThrow(ApiException('Lỗi không xác định', 500));

      expect(
        () => jobService.getAllJobs(page: 1, pageSize: 50),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
