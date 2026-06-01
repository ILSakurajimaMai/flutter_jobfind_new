import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_jobfind/features/ai_chat/models/ai_chat_message.dart';
import 'package:app_jobfind/features/ai_chat/viewmodels/ai_chat_viewmodel.dart';
import 'package:intl/intl.dart';

class AIChatScreen extends ConsumerStatefulWidget {
  const AIChatScreen({super.key});

  @override
  ConsumerState<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends ConsumerState<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _suggestions = [
    'Tìm việc part-time ngành IT/Thiết kế',
    'Tư vấn tối ưu CV chuẩn ATS',
    'Kỹ năng trả lời phỏng vấn xin việc',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSend([String? text]) {
    final messageText = text ?? _messageController.text;
    if (messageText.trim().isEmpty) return;

    ref.read(aiChatProvider.notifier).sendMessage(messageText);

    if (text == null) {
      _messageController.clear();
    }

    // Đợi UI render xong rồi cuộn xuống cuối cùng
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _showRestartConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Làm mới hội thoại',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF14003E),
            ),
          ),
          content: const Text(
            'Bạn có chắc chắn muốn xóa toàn bộ lịch sử chat hiện tại để bắt đầu phiên mới?',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                final success = await ref
                    .read(aiChatProvider.notifier)
                    .restartConversation();
                if (success) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Đã làm mới phiên chat AI thành công'),
                      backgroundColor: Color(0xFF14003E),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14003E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Đồng ý',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(aiChatProvider);

    // Tự động cuộn xuống cuối khi có tin nhắn mới hoặc đang loading
    ref.listen(aiChatProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length ||
          previous?.isLoading != next.isLoading) {
        Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF14003E),
        elevation: 0,
        titleSpacing: 0,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFE2D6FF),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.smart_toy_rounded,
                    color: Color(0xFF14003E),
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trợ lý AI JobFind',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF50C878), // Emerald green
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'Đang hoạt động',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Làm mới cuộc trò chuyện',
            onPressed: chatState.isCleaning ? null : _showRestartConfirmation,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // List tin nhắn
            Expanded(
              child: chatState.messages.isEmpty
                  ? const Center(
                      child: Text(
                        'Chưa có tin nhắn nào',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 20.0,
                      ),
                      itemCount:
                          chatState.messages.length +
                          (chatState.isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == chatState.messages.length) {
                          return _buildThinkingIndicator();
                        }
                        return _buildChatBubble(chatState.messages[index]);
                      },
                    ),
            ),

            // Các Suggestion Chips hiển thị trên thanh gõ khi chưa nhắn gì nhiều hoặc khi AI đã trả lời xong
            if (!chatState.isLoading && chatState.messages.length <= 2)
              _buildSuggestionsBar(),

            // Thanh nhập tin nhắn
            _buildInputBar(chatState.isLoading || chatState.isCleaning),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              'GỢI Ý HỎI NHANH',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () => _handleSend(_suggestions[index]),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFDCD1FF)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          _suggestions[index],
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF14003E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(AIChatMessage message) {
    final isMe = message.isFromUser;
    final timeStr = DateFormat('HH:mm').format(message.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8.0),
              decoration: const BoxDecoration(
                color: Color(0xFFE2D6FF),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.smart_toy_rounded,
                  color: Color(0xFF14003E),
                  size: 18,
                ),
              ),
            ),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF14003E) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(8),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 14.5,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    timeStr,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThinkingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8.0),
            decoration: const BoxDecoration(
              color: Color(0xFFE2D6FF),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.smart_toy_rounded,
                color: Color(0xFF14003E),
                size: 18,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    color: Color(0xFF14003E),
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'AI đang suy nghĩ...',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(bool disabled) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEBEBF0))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                enabled: !disabled,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSend(),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(fontSize: 15),
                decoration: const InputDecoration(
                  hintText: 'Nhập câu hỏi của bạn tại đây...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 10.0,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF14003E),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: disabled ? null : () => _handleSend(),
            ),
          ),
        ],
      ),
    );
  }
}
