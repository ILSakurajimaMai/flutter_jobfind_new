import 'package:app_jobfind/core/api_client.dart';

class AIChatService {
  final ApiClient _apiClient = ApiClient();

  /// Gửi tin nhắn tới AI chatbot và lấy phản hồi dạng chuỗi văn bản.
  Future<String> sendMessage(String message) async {
    final dynamic data = await _apiClient.post(
      '/aichat/message',
      data: {
        'message': message,
      },
    );
    if (data is String) {
      return data;
    }
    // Trường hợp dự phòng nếu API trả về một Map chứa response
    if (data is Map<String, dynamic> && data['response'] != null) {
      return data['response'] as String;
    }
    return data?.toString() ?? '';
  }

  /// Khởi động lại phiên hội thoại (xóa ngữ cảnh cũ).
  Future<void> restartSession() async {
    await _apiClient.post('/aichat/restart');
  }
}
