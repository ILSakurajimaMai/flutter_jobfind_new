import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_jobfind/core/api_client.dart';
import 'package:app_jobfind/features/application/services/application_service.dart';
import 'package:app_jobfind/core/exceptions/api_exception.dart';
import 'package:app_jobfind/core/models/paginated_list_dto.dart';
import 'package:app_jobfind/features/application/models/application_dto.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late ApplicationService applicationService;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    applicationService = ApplicationService(apiClient: mockApiClient);
  });

  group('ApplicationService', () {
    final mockResponse = {
      'items': [
        {'id': '1', 'status': 'Pending'},
      ],
      'pageNumber': 1,
      'totalPages': 1,
      'totalCount': 1,
      'hasPreviousPage': false,
      'hasNextPage': false,
    };

    test('getMyApplications returns PaginatedListDto on success', () async {
      when(
        () => mockApiClient.get(
          '/applications/me',
          queryParameters: {'pageNumber': 1, 'pageSize': 50},
        ),
      ).thenAnswer((_) async => mockResponse);

      final result = await applicationService.getMyApplications(
        pageNumber: 1,
        pageSize: 50,
      );

      expect(result, isA<PaginatedListDto<ApplicationDto>>());
      verify(
        () => mockApiClient.get(
          '/applications/me',
          queryParameters: {'pageNumber': 1, 'pageSize': 50},
        ),
      ).called(1);
    });

    test('getMyApplications throws ApiException on failure', () async {
      when(
        () => mockApiClient.get(
          '/applications/me',
          queryParameters: {'pageNumber': 1, 'pageSize': 50},
        ),
      ).thenThrow(ApiException('Error', 500));

      expect(
        () => applicationService.getMyApplications(pageNumber: 1, pageSize: 50),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
