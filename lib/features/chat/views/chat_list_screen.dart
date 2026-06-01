import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:app_jobfind/features/auth/viewmodels/auth_provider.dart';
import 'package:app_jobfind/features/chat/models/chat_conversation_dto.dart';
import 'package:app_jobfind/features/chat/viewmodels/chat_list_viewmodel.dart';
import 'chat_room_screen.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatListProvider);
    final authState = ref.watch(authProvider);
    final isEmployer = authState.user?.roles.contains('EMPLOYER') ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF14003E),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Ẩn nút Back vì màn hình này là tab trong BottomNav
        title: const Text(
          'Hộp thoại tin nhắn',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(chatListProvider.notifier).loadConversations(),
          ),
        ],
      ),
      body: chatState.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF14003E)))
          : chatState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(
                        'Lỗi: ${chatState.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => ref.read(chatListProvider.notifier).loadConversations(),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : chatState.conversations.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: () => ref.read(chatListProvider.notifier).loadConversations(),
                      color: const Color(0xFF14003E),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: chatState.conversations.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final conversation = chatState.conversations[index];
                          // Hiển thị tên của đối phương dựa vào vai trò hiện tại
                          final peerName = isEmployer
                              ? conversation.studentName
                              : conversation.employerName;
                          final peerId = isEmployer
                              ? conversation.studentId
                              : conversation.employerId;

                          return _buildConversationCard(
                            context,
                            conversation,
                            peerName,
                            peerId,
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.forum_outlined, size: 72, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Chưa có cuộc trò chuyện nào',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Hãy kết nối với các ứng viên hoặc nhà tuyển dụng để trao đổi công việc.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationCard(
    BuildContext context,
    ChatConversationDto conv,
    String peerName,
    int peerId,
  ) {
    final hasUnread = conv.unreadCount > 0;
    final initials = peerName.isNotEmpty
        ? peerName.trim().split(' ').last.substring(0, 1).toUpperCase()
        : 'U';

    String timeStr = '';
    if (conv.lastMessageAt != null) {
      timeStr = DateFormat('HH:mm dd/MM').format(conv.lastMessageAt!.toLocal());
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatRoomScreen(
              conversationId: conv.id,
              recipientId: peerId,
              recipientName: peerName,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
          border: hasUnread
              ? Border.all(color: const Color(0xFF0D9D58).withValues(alpha: 0.3), width: 1.5)
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF14003E).withValues(alpha: 0.08),
              child: Text(
                initials,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF14003E), fontSize: 18),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          peerName,
                          style: TextStyle(
                            fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                            fontSize: 15,
                            color: const Color(0xFF14003E),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (timeStr.isNotEmpty)
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 11,
                            color: hasUnread ? const Color(0xFF0D9D58) : Colors.grey,
                            fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (conv.jobPostTitle != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Công việc: ${conv.jobPostTitle}',
                        style: const TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    conv.lastMessage ?? 'Bắt đầu cuộc hội thoại...',
                    style: TextStyle(
                      fontSize: 13,
                      color: hasUnread ? Colors.black87 : Colors.grey.shade600,
                      fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (hasUnread) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFF0D9D58),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${conv.unreadCount}',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
