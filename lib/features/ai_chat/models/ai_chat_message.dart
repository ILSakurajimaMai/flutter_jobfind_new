class AIChatMessage {
  final String id;
  final String text;
  final bool isFromUser;
  final DateTime createdAt;

  AIChatMessage({
    required this.id,
    required this.text,
    required this.isFromUser,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isFromUser': isFromUser,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AIChatMessage.fromJson(Map<String, dynamic> json) {
    return AIChatMessage(
      id: json['id'] as String,
      text: json['text'] as String,
      isFromUser: json['isFromUser'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
