/// DTO đại diện cho dữ liệu trả về khi đăng nhập thành công (Token, Thông tin User).
class AuthResponseDto {
  final int userId;
  final String email;
  final String? fullName;
  final List<String> roles;
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  AuthResponseDto({
    required this.userId,
    required this.email,
    this.fullName,
    required this.roles,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      userId: json['userId'] ?? 0,
      email: json['email'] ?? '',
      fullName: json['fullName'],
      roles: List<String>.from(json['roles'] ?? []),
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      expiresAt: DateTime.tryParse(json['expiresAt'] ?? '') ?? DateTime.now(),
    );
  }
}
