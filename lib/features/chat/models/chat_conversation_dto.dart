class ChatConversationDto {
  final int id;
  final int employerId;
  final String employerName;
  final int studentId;
  final String studentName;
  final int? jobPostId;
  final String? jobPostTitle;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final DateTime createdAt;

  ChatConversationDto({
    required this.id,
    required this.employerId,
    required this.employerName,
    required this.studentId,
    required this.studentName,
    this.jobPostId,
    this.jobPostTitle,
    this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
    required this.createdAt,
  });

  factory ChatConversationDto.fromJson(Map<String, dynamic> json) {
    return ChatConversationDto(
      id: json['id'] ?? json['Id'] ?? 0,
      employerId: json['employerId'] ?? json['EmployerId'] ?? 0,
      employerName: json['employerName'] ?? json['EmployerName'] ?? '',
      studentId: json['studentId'] ?? json['StudentId'] ?? 0,
      studentName: json['studentName'] ?? json['StudentName'] ?? '',
      jobPostId: json['jobPostId'] ?? json['JobPostId'],
      jobPostTitle: json['jobPostTitle'] ?? json['JobPostTitle'],
      lastMessage: json['lastMessage'] ?? json['LastMessage'],
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.tryParse(json['lastMessageAt'])
          : json['LastMessageAt'] != null
              ? DateTime.tryParse(json['LastMessageAt'])
              : null,
      unreadCount: json['unreadCount'] ?? json['UnreadCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? json['CreatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
