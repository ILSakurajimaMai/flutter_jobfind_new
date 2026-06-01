class SendMessageDto {
  final int? conversationId;
  final int? recipientId;
  final int? jobPostId;
  final String content;

  SendMessageDto({
    this.conversationId,
    this.recipientId,
    this.jobPostId,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      if (conversationId != null) 'conversationId': conversationId,
      if (recipientId != null) 'recipientId': recipientId,
      if (jobPostId != null) 'jobPostId': jobPostId,
      'content': content,
    };
  }
}
