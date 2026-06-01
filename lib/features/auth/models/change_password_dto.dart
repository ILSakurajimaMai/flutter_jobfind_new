// lib/features/auth/models/change_password_dto.dart

class ChangePasswordDto {
  final String currentPassword;
  final String newPassword;
  final String confirmNewPassword;

  ChangePasswordDto({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmNewPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'confirmNewPassword': confirmNewPassword,
    };
  }
}
