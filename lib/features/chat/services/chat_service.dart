import 'package:app_jobfind/core/api_client.dart';
import 'package:app_jobfind/features/chat/models/chat_conversation_dto.dart';
import 'package:app_jobfind/features/chat/models/chat_message_dto.dart';
import 'package:app_jobfind/features/chat/models/send_message_dto.dart';

class ChatService {
  final ApiClient _apiClient;
  ChatService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // ── REST API Methods ──

  /// Lấy hoặc tạo cuộc hội thoại mới giữa User hiện tại và đối phương
  Future<ChatConversationDto> getOrCreateConversation(
    int recipientId,
    int? jobPostId,
  ) async {
    final data = await _apiClient.post(
      '/chat/conversations',
      data: {'recipientId': recipientId, 'jobPostId': jobPostId}
        ..removeWhere((k, v) => v == null),
    );
    return ChatConversationDto.fromJson(data);
  }

  /// Lấy danh sách toàn bộ các cuộc trò chuyện của User hiện tại
  Future<List<ChatConversationDto>> getConversations({
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final data = await _apiClient.get(
      '/chat/conversations',
      queryParameters: {'pageNumber': pageNumber, 'pageSize': pageSize},
    );
    if (data is Map && data['items'] is List) {
      final list = data['items'] as List;
      return list.map((json) => ChatConversationDto.fromJson(json)).toList();
    }
    if (data is List) {
      return data.map((json) => ChatConversationDto.fromJson(json)).toList();
    }
    return [];
  }

  /// Lấy danh sách tin nhắn lịch sử trong một cuộc hội thoại cụ thể
  Future<List<ChatMessageDto>> getMessages(
    int conversationId, {
    int pageNumber = 1,
    int pageSize = 50,
  }) async {
    final data = await _apiClient.get(
      '/chat/conversations/$conversationId/messages',
      queryParameters: {'pageNumber': pageNumber, 'pageSize': pageSize},
    );
    if (data is Map && data['items'] is List) {
      final list = data['items'] as List;
      return list.map((json) => ChatMessageDto.fromJson(json)).toList();
    }
    if (data is List) {
      return data.map((json) => ChatMessageDto.fromJson(json)).toList();
    }
    return [];
  }

  /// Gọi API REST gửi tin nhắn (dùng làm phương án dự phòng khi SignalR ngắt kết nối)
  Future<ChatMessageDto> sendMessageRest(SendMessageDto dto) async {
    final data = await _apiClient.post('/chat/messages', data: dto.toJson());
    return ChatMessageDto.fromJson(data);
  }

  /// Đánh dấu tất cả tin nhắn trong hội thoại là đã đọc
  Future<void> markAsRead(int conversationId) async {
    await _apiClient.post('/chat/conversations/$conversationId/read');
  }

  /// Lấy tổng số tin nhắn chưa đọc của người dùng hiện tại
  Future<int> getUnreadCount() async {
    final data = await _apiClient.get('/chat/unread-count');
    if (data is Map) {
      return data['unreadCount'] ?? 0;
    }
    return data as int? ?? 0;
  }
}
