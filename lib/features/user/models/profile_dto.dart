/// Lớp Data Transfer Object (DTO) đại diện cho mô hình dữ liệu Profile từ Backend.
/// Dùng để hứng dữ liệu JSON trả về từ API và chuyển đổi ngược lại thành JSON để gửi lên server.
class ProfileDto {
  final int? id;
  final int? userId;
  final String? fullName;
  final String? dateOfBirth;
  final String? phoneNumber;
  final String? email;
  final String? address;

  ProfileDto({
    this.id,
    this.userId,
    this.fullName,
    this.dateOfBirth,
    this.phoneNumber,
    this.email,
    this.address,
  });

  /// Hàm khởi tạo ProfileDto từ chuỗi JSON lấy từ Backend
  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    return ProfileDto(
      id: json['id'],
      userId: json['userId'],
      fullName: json['fullName'],
      dateOfBirth: json['dateOfBirth'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      address: json['address'],
    );
  }

  /// Hàm chuyển đổi đối tượng ProfileDto sang Map (JSON) để gửi dữ liệu cập nhật về Backend
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'userId': userId,
      if (fullName != null) 'fullName': fullName,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
    };
  }

  /// Khởi tạo một bản sao của đối tượng thay đổi một vài thuộc tính nhất định
  ProfileDto copyWith({
    int? id,
    int? userId,
    String? fullName,
    String? dateOfBirth,
    String? phoneNumber,
    String? email,
    String? address,
  }) {
    return ProfileDto(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
    );
  }
}
