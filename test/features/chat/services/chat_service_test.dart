import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_jobfind/core/api_client.dart';
import 'package:app_jobfind/features/chat/services/chat_service.dart';
import 'package:app_jobfind/features/chat/models/chat_conversation_dto.dart';
import 'package:app_jobfind/core/exceptions/api_exception.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late ChatService chatService;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    chatService = ChatService(apiClient: mockApiClient);
  });

  group('ChatService', () {
    final mockResponse = [
      {
        'id': '1',
        'participants': [],
        'messages': [],
      }
    ];

    test('getMyConversations returns List<ChatConversationDto> on success', () async {
      when(() => mockApiClient.get('/chats/conversations'))
          .thenAnswer((_) async => mockResponse);

      final result = await chatService.getMyConversations();

      expect(result, isA<List<ChatConversationDto>>());
      verify(() => mockApiClient.get('/chats/conversations')).called(1);
    });

    test('getMyConversations throws ApiException on failure', () async {
      when(() => mockApiClient.get('/chats/conversations'))
          .thenThrow(ApiException('Error', 500));

      expect(() => chatService.getMyConversations(), throwsA(isA<ApiException>()));
    });
  });
}
