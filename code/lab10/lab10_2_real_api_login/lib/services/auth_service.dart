import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/auth_user.dart';

// Lỗi đăng nhập thường gặp (sai tài khoản, mất mạng, quá thời gian, lỗi server)
// được đổi thành lỗi này; message đã đủ thân thiện để hiển thị thẳng lên UI
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;
}

class AuthService {
  // Thành công trả về AuthUser; sai tài khoản, mất mạng, quá thời gian hoặc lỗi
  // server thì ném AuthException. Dữ liệu trả về bị hỏng thì lỗi khác đi thẳng
  // lên LoginScreen và được bắt ở nhánh catch chung
  Future<AuthUser> login({
    required String username,
    required String password,
  }) async {
    // Chỉ lời gọi mạng nằm trong try. AuthException cũng là một Exception, nên
    // nếu đưa phần kiểm tra statusCode vào đây thì sai mật khẩu sẽ bị bắt nhầm
    // thành lỗi mất kết nối
    final http.Response response;
    try {
      response = await http
          .post(
            Uri.parse('https://dummyjson.com/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          // Quá 10 giây chưa có phản hồi thì ném TimeoutException
          .timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw const AuthException(
        'The server took too long to respond. Please try again.',
      );
    } on Exception {
      // SocketException, http.ClientException, lỗi TLS... đều là lỗi đường
      // truyền; không cần phân biệt vì người dùng chỉ cần biết "mất kết nối"
      throw const AuthException(
        'Cannot connect to the server. '
        'Please check your internet connection and try again.',
      );
    }

    if (response.statusCode == 200) {
      return AuthUser.fromJson(jsonDecode(response.body));
    }
    // DummyJSON trả 400 kèm {"message": "..."} khi sai tài khoản hoặc thiếu trường
    if (response.statusCode == 400 || response.statusCode == 401) {
      final json = jsonDecode(response.body);
      // Lấy trường "message" do server gửi; không có thì dùng câu mặc định
      throw AuthException(json['message'] ?? 'Invalid credentials');
    }
    throw AuthException(
      'Server error (HTTP ${response.statusCode}). Please try again later.',
    );
  }
}
