import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_jobfind/features/ai_chat/models/ai_chat_message.dart';
import 'package:app_jobfind/features/ai_chat/services/ai_chat_service.dart';

class AIChatState {
  final List<AIChatMessage> messages;
  final bool isLoading;
  final bool isCleaning;
  final String? error;

  AIChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isCleaning = false,
    this.error,
  });

  AIChatState copyWith({
    List<AIChatMessage>? messages,
    bool? isLoading,
    bool? isCleaning,
    String? error,
  }) {
    return AIChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isCleaning: isCleaning ?? this.isCleaning,
      error: error,
    );
  }
}

class AIChatViewModel extends Notifier<AIChatState> {
  final AIChatService _aiChatService = AIChatService();

  @override
  AIChatState build() {
    // Khởi tạo cuộc trò chuyện với tin nhắn chào mừng của AI
    final welcomeMessage = AIChatMessage(
      id: 'welcome',
      text: 'Xin chào! Tôi là Trợ lý AI của JobFind. Tôi có thể hỗ trợ bạn tìm kiếm cơ hội và phát triển sự nghiệp.\n\nHãy thử hỏi tôi một số câu hỏi như:\n• Tìm công việc part-time ngành Thiết kế/IT\n• Tư vấn tối ưu CV gây ấn tượng với nhà tuyển dụng\n• Kỹ năng trả lời phỏng vấn xin việc',
      isFromUser: false,
      createdAt: DateTime.now(),
    );

    return AIChatState(messages: [welcomeMessage]);
  }

  /// Gửi tin nhắn đến AI chatbot
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = AIChatMessage(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      text: text.trim(),
      isFromUser: true,
      createdAt: DateTime.now(),
    );

    // Cập nhật giao diện ngay lập tức với tin nhắn của user
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    try {
      final aiResponse = await _aiChatService.sendMessage(text.trim());

      final aiMessage = AIChatMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        text: aiResponse,
        isFromUser: false,
        createdAt: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      );
    } catch (e) {
      final errorMessage = AIChatMessage(
        id: 'error_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Xin lỗi, tôi gặp sự cố kết nối tới máy chủ. Vui lòng kiểm tra lại mạng hoặc thử lại sau.',
        isFromUser: false,
        createdAt: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Khởi động lại phiên trò chuyện (xóa ngữ cảnh và tin nhắn cũ)
  Future<bool> restartConversation() async {
    state = state.copyWith(isCleaning: true, error: null);
    try {
      await _aiChatService.restartSession();

      final welcomeMessage = AIChatMessage(
        id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Phiên trò chuyện đã được làm mới! Tôi là Trợ lý AI của JobFind. Bạn cần tôi hỗ trợ việc làm hay tối ưu hồ sơ thế nào?',
        isFromUser: false,
        createdAt: DateTime.now(),
      );

      state = AIChatState(messages: [welcomeMessage]);
      return true;
    } catch (e) {
      state = state.copyWith(
        isCleaning: false,
        error: 'Không thể làm mới phiên trò chuyện: ${e.toString().replaceAll('Exception: ', '')}',
      );
      return false;
    }
  }
}

/// Provider toàn cục để quản lý ViewModel của AI Chat
final aiChatProvider = NotifierProvider<AIChatViewModel, AIChatState>(() {
  return AIChatViewModel();
});
