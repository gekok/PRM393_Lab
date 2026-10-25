// Người dùng và token trả về từ DummyJSON `POST /auth/login`
class AuthUser {
  const AuthUser({
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.image,
    required this.accessToken,
  });

  // Chỉ accessToken là bắt buộc; thiếu trường khác thì dùng giá trị rỗng
  // để app không crash khi server bỏ bớt dữ liệu hồ sơ
  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      image: json['image'] ?? '',
      accessToken: json['accessToken'] as String,
    );
  }

  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String image;
  final String accessToken;
}
