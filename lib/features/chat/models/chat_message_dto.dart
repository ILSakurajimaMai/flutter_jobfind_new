class ChatMessageDto {
  final int id;
  final int conversationId;
  final int senderId;
  final String senderName;
  final String content;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  ChatMessageDto({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) {
    return ChatMessageDto(
      id: json['id'] ?? json['Id'] ?? 0,
      conversationId: json['conversationId'] ?? json['ConversationId'] ?? 0,
      senderId: json['senderId'] ?? json['SenderId'] ?? json['senderID'] ?? 0,
      senderName: json['senderName'] ?? json['SenderName'] ?? '',
      content: json['content'] ?? json['Content'] ?? '',
      isRead: json['isRead'] ?? json['IsRead'] ?? false,
      readAt: json['readAt'] != null
          ? DateTime.tryParse(json['readAt'])
          : json['ReadAt'] != null
          ? DateTime.tryParse(json['ReadAt'])
          : null,
      createdAt: DateTime.parse(
        json['createdAt'] ??
            json['CreatedAt'] ??
            DateTime.now().toIso8601String(),
      ),
    );
  }
}
