/// Mô hình dữ liệu đăng ký tài khoản đẩy lên Backend.
class RegisterDto {
  final String email;
  final String password;
  final String confirmPassword;
  final String? fullName;
  final String? phoneNumber;
  final String? address;
  final String role;

  RegisterDto({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.role,
    this.fullName,
    this.phoneNumber,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'role': role,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'address': address,
    };
  }
}
