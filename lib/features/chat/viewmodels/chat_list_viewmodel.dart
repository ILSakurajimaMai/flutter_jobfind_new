import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_jobfind/features/chat/models/chat_conversation_dto.dart';
import 'package:app_jobfind/features/chat/services/chat_service.dart';

final chatServiceProvider = Provider((ref) => ChatService());

class ChatListState {
  final List<ChatConversationDto> conversations;
  final bool isLoading;
  final int totalUnreadCount;
  final String? error;

  ChatListState({
    this.conversations = const [],
    this.isLoading = false,
    this.totalUnreadCount = 0,
    this.error,
  });

  ChatListState copyWith({
    List<ChatConversationDto>? conversations,
    bool? isLoading,
    int? totalUnreadCount,
    String? error,
  }) {
    return ChatListState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      totalUnreadCount: totalUnreadCount ?? this.totalUnreadCount,
      error: error,
    );
  }
}

/// ViewModel quản lý danh sách cuộc hội thoại và số tin nhắn chưa đọc toàn cục (MVVM).
class ChatListViewModel extends Notifier<ChatListState> {
  @override
  ChatListState build() {
    // Tải danh sách khi khởi tạo
    Future.microtask(() => loadConversations());
    return ChatListState();
  }

  /// Tải danh sách cuộc hội thoại từ REST API
  Future<void> loadConversations() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final service = ref.read(chatServiceProvider);
      final list = await service.getConversations();
      final unread = await service.getUnreadCount();
      state = state.copyWith(
        conversations: list,
        totalUnreadCount: unread,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Cập nhật tin nhắn cuối cùng một cách mượt mà và chuyển đổi vị trí cuộc trò chuyện lên đầu danh sách
  void updateLastMessage(
    int conversationId,
    String content,
    DateTime time, {
    bool incrementUnread = false,
  }) {
    final updatedList = state.conversations.map((c) {
      if (c.id == conversationId) {
        return ChatConversationDto(
          id: c.id,
          employerId: c.employerId,
          employerName: c.employerName,
          studentId: c.studentId,
          studentName: c.studentName,
          jobPostId: c.jobPostId,
          jobPostTitle: c.jobPostTitle,
          lastMessage: content,
          lastMessageAt: time,
          unreadCount: incrementUnread ? c.unreadCount + 1 : c.unreadCount,
          createdAt: c.createdAt,
        );
      }
      return c;
    }).toList();

    // Sắp xếp lại danh sách: cuộc trò chuyện mới có tin nhắn sẽ đưa lên đầu
    updatedList.sort((a, b) {
      if (a.lastMessageAt == null && b.lastMessageAt == null) return 0;
      if (a.lastMessageAt == null) return 1;
      if (b.lastMessageAt == null) return -1;
      return b.lastMessageAt!.compareTo(a.lastMessageAt!);
    });

    state = state.copyWith(
      conversations: updatedList,
      totalUnreadCount: incrementUnread
          ? state.totalUnreadCount + 1
          : state.totalUnreadCount,
    );
  }

  /// Reset số tin nhắn chưa đọc của cuộc hội thoại về 0
  void resetUnreadCount(int conversationId) {
    ChatConversationDto? target;
    for (var c in state.conversations) {
      if (c.id == conversationId) {
        target = c;
        break;
      }
    }

    if (target == null) return;
    final unreadSaved = target.unreadCount;

    state = state.copyWith(
      conversations: state.conversations.map((c) {
        if (c.id == conversationId) {
          return ChatConversationDto(
            id: c.id,
            employerId: c.employerId,
            employerName: c.employerName,
            studentId: c.studentId,
            studentName: c.studentName,
            jobPostId: c.jobPostId,
            jobPostTitle: c.jobPostTitle,
            lastMessage: c.lastMessage,
            lastMessageAt: c.lastMessageAt,
            unreadCount: 0,
            createdAt: c.createdAt,
          );
        }
        return c;
      }).toList(),
      totalUnreadCount: state.totalUnreadCount - unreadSaved < 0
          ? 0
          : state.totalUnreadCount - unreadSaved,
    );
  }
}

/// Provider toàn cục để lắng nghe sự thay đổi của ChatListViewModel
final chatListProvider = NotifierProvider<ChatListViewModel, ChatListState>(
  ChatListViewModel.new,
);
