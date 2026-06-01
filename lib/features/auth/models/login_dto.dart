/// Mô hình dữ liệu đẩy lên Backend khi thực hiện đăng nhập.
class LoginDto {
  final String email;
  final String password;

  LoginDto({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}
