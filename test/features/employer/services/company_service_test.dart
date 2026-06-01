import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_jobfind/core/api_client.dart';
import 'package:app_jobfind/features/employer/services/company_service.dart';
import 'package:app_jobfind/features/employer/models/company_dto.dart';
import 'package:app_jobfind/core/exceptions/api_exception.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late CompanyService companyService;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    companyService = CompanyService(apiClient: mockApiClient);
  });

  group('CompanyService', () {
    final mockResponse = {
      'id': '1',
      'name': 'Tech Corp',
      'description': 'A great company',
    };

    test('getMyCompany returns CompanyDto on success', () async {
      when(() => mockApiClient.get('/companies/me'))
          .thenAnswer((_) async => mockResponse);

      final result = await companyService.getMyCompany();

      expect(result, isA<CompanyDto>());
      verify(() => mockApiClient.get('/companies/me')).called(1);
    });

    test('getMyCompany throws ApiException on failure', () async {
      when(() => mockApiClient.get('/companies/me'))
          .thenThrow(ApiException('Lỗi server', 500));

      expect(() => companyService.getMyCompany(), throwsA(isA<ApiException>()));
    });
  });
}
