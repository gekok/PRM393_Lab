// Giả lập server đăng nhập; chưa gọi Internet
class MockAuthService {
  // Cặp tài khoản demo duy nhất được chấp nhận
  static const String demoEmail = 'demo@test.com';
  static const String demoPassword = '123456';

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    // Tạo độ trễ giống lúc chờ phản hồi từ server
    await Future.delayed(const Duration(seconds: 2));

    if (email == demoEmail && password == demoPassword) {
      return 'mock-token-${DateTime.now().millisecondsSinceEpoch}';
    }

    // Sai thông tin thì không có token
    return null;
  }
}
