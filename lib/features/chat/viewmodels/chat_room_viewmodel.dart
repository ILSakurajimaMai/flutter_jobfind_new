import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:app_jobfind/core/constants.dart';
import 'package:app_jobfind/features/chat/models/chat_message_dto.dart';
import 'package:app_jobfind/features/chat/models/send_message_dto.dart';
import 'package:app_jobfind/features/chat/viewmodels/chat_list_viewmodel.dart';

class ChatRoomState {
  final List<ChatMessageDto> messages;
  final bool isLoading;
  final bool isConnected;
  final bool isPeerTyping;
  final String? error;

  ChatRoomState({
    this.messages = const [],
    this.isLoading = false,
    this.isConnected = false,
    this.isPeerTyping = false,
    this.error,
  });

  ChatRoomState copyWith({
    List<ChatMessageDto>? messages,
    bool? isLoading,
    bool? isConnected,
    bool? isPeerTyping,
    String? error,
  }) {
    return ChatRoomState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isConnected: isConnected ?? this.isConnected,
      isPeerTyping: isPeerTyping ?? this.isPeerTyping,
      error: error,
    );
  }
}

/// ViewModel quản lý kết nối và trạng thái của phòng chat chi tiết (MVVM).
class ChatRoomViewModel extends Notifier<ChatRoomState> {
  final int conversationId;

  ChatRoomViewModel(this.conversationId);

  HubConnection? _hubConnection;
  bool _isDisposed = false;

  @override
  ChatRoomState build() {
    _isDisposed = false;

    // Khởi tạo phòng chat sau khi build xong
    Future.microtask(() => _initializeChat());

    // Tự động giải phóng HubConnection khi Provider bị hủy
    ref.onDispose(() {
      _isDisposed = true;
      if (_hubConnection != null &&
          _hubConnection!.state == HubConnectionState.Connected) {
        _hubConnection!.invoke("LeaveConversation", args: [conversationId]);
        _hubConnection!.stop();
      }
    });

    return ChatRoomState();
  }

  /// Khởi tạo và thiết lập các sự kiện kết nối
  Future<void> _initializeChat() async {
    if (_isDisposed) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 1. Tải tin nhắn lịch sử qua REST API
      final service = ref.read(chatServiceProvider);
      final history = await service.getMessages(conversationId);

      if (_isDisposed) return;
      state = state.copyWith(messages: history, isLoading: false);

      // Đánh dấu đã đọc trên REST API
      await service.markAsRead(conversationId);
      ref.read(chatListProvider.notifier).resetUnreadCount(conversationId);

      // 2. Cấu hình kết nối SignalR Hub
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      if (token.isEmpty) {
        if (!_isDisposed) {
          state = state.copyWith(error: "Bạn chưa đăng nhập");
        }
        return;
      }

      _hubConnection = HubConnectionBuilder()
          .withUrl(
            Constants.hubUrl,
            options: HttpConnectionOptions(
              accessTokenFactory: () => Future.value(token),
              logMessageContent: kDebugMode,
            ),
          )
          .withAutomaticReconnect()
          .build();

      // Đăng ký các sự kiện SignalR
      _hubConnection!.on("ReceiveMessage", _onReceiveMessage);
      _hubConnection!.on("UserTyping", _onUserTyping);
      _hubConnection!.on("MessagesMarkedAsRead", _onMessagesMarkedAsRead);

      _hubConnection!.onclose(({error}) {
        if (!_isDisposed) {
          state = state.copyWith(isConnected: false);
        }
      });

      // Bắt đầu kết nối
      await _hubConnection!.start();

      if (_isDisposed) return;
      state = state.copyWith(isConnected: true);

      // Đăng ký tham gia nhóm hội thoại
      await _hubConnection!.invoke("JoinConversation", args: [conversationId]);
    } catch (e) {
      debugPrint("Error initializing chat: $e");
      if (!_isDisposed) {
        state = state.copyWith(
          isLoading: false,
          error: "Không thể kết nối Real-time. Chuyển sang chế độ thủ công.",
        );
      }
    }
  }

  // ── Xử lý sự kiện nhận tin nhắn Real-time từ Hub ──
  void _onReceiveMessage(List<dynamic>? args) {
    if (args == null || args.isEmpty) return;
    try {
      final rawMessage = Map<String, dynamic>.from(args[0] as Map);
      final message = ChatMessageDto.fromJson(rawMessage);

      if (message.conversationId == conversationId) {
        if (!_isDisposed) {
          state = state.copyWith(messages: [message, ...state.messages]);
        }
        // Tự động đánh dấu đã đọc
        ref.read(chatServiceProvider).markAsRead(conversationId);
        ref
            .read(chatListProvider.notifier)
            .updateLastMessage(
              conversationId,
              message.content,
              message.createdAt,
              incrementUnread: false,
            );
      } else {
        // Tin nhắn đến từ cuộc trò chuyện khác -> tăng đếm unread ở danh sách chính
        ref
            .read(chatListProvider.notifier)
            .updateLastMessage(
              message.conversationId,
              message.content,
              message.createdAt,
              incrementUnread: true,
            );
      }
    } catch (e) {
      debugPrint("Error in _onReceiveMessage: $e");
    }
  }

  // ── Xử lý sự kiện đối phương đang gõ phím ──
  void _onUserTyping(List<dynamic>? args) {
    if (args == null || args.length < 2) return;
    try {
      final isTyping = args[1] as bool;
      if (!_isDisposed) {
        state = state.copyWith(isPeerTyping: isTyping);
      }
    } catch (e) {
      debugPrint("Error in _onUserTyping: $e");
    }
  }

  // ── Xử lý sự kiện tin nhắn đã được đọc ──
  void _onMessagesMarkedAsRead(List<dynamic>? args) {
    if (!_isDisposed) {
      state = state.copyWith(
        messages: state.messages
            .map(
              (m) => ChatMessageDto(
                id: m.id,
                conversationId: m.conversationId,
                senderId: m.senderId,
                senderName: m.senderName,
                content: m.content,
                isRead: true,
                readAt: DateTime.now(),
                createdAt: m.createdAt,
              ),
            )
            .toList(),
      );
    }
  }

  // ── Gửi tin nhắn ──
  Future<void> sendMessage(String content, int recipientId) async {
    if (content.trim().isEmpty) return;

    final dto = SendMessageDto(
      conversationId: conversationId,
      recipientId: recipientId,
      content: content.trim(),
    );

    try {
      if (state.isConnected && _hubConnection != null) {
        // Gửi qua SignalR
        await _hubConnection!.invoke("SendMessage", args: [dto.toJson()]);
      } else {
        // Phương án dự phòng: Gửi qua REST API nếu SignalR ngắt kết nối
        final sentMessage = await ref
            .read(chatServiceProvider)
            .sendMessageRest(dto);
        if (!_isDisposed) {
          state = state.copyWith(messages: [sentMessage, ...state.messages]);
        }
        ref
            .read(chatListProvider.notifier)
            .updateLastMessage(
              conversationId,
              sentMessage.content,
              sentMessage.createdAt,
            );
      }
    } catch (e) {
      if (!_isDisposed) {
        state = state.copyWith(error: "Lỗi khi gửi: ${e.toString()}");
      }
    }
  }

  // ── Cập nhật trạng thái đang gõ ──
  Future<void> sendTypingStatus(bool isTyping) async {
    if (_hubConnection != null && state.isConnected) {
      try {
        await _hubConnection!.invoke(
          "UpdateTyping",
          args: [conversationId, isTyping],
        );
      } catch (e) {
        debugPrint("Error sending typing status: $e");
      }
    }
  }
}

/// Provider dạng family để quản lý ViewModel cho từng phòng chat riêng biệt (MVVM)
final chatRoomProvider =
    NotifierProvider.family<ChatRoomViewModel, ChatRoomState, int>(
      ChatRoomViewModel.new,
    );
