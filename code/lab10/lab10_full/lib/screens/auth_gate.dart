import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_token_key.dart';
import '../services/google_auth_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

// Màn chờ (Splash), màn đầu tiên của app: xem máy còn phiên đăng nhập nào
// (token DummyJSON hoặc phiên Google của Firebase) rồi chuyển sang Home hoặc Login
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _routeBySession();
  }

  Future<void> _routeBySession() async {
    // 1. Phiên DummyJSON: token đã lưu trong SharedPreferences (như bài 10.3)
    String? token;
    String? username;
    try {
      final prefs = await SharedPreferences.getInstance();
      // null nghĩa là chưa đăng nhập hoặc đã logout
      token = prefs.getString(authTokenKey);
      username = prefs.getString(authUsernameKey);
    } catch (_) {
      // Đọc phiên bị lỗi thì coi như chưa đăng nhập để người dùng đăng nhập lại
      token = null;
    }

    // 2. Phiên Google: Firebase tự khôi phục user cũ lúc initializeApp (như bài 10.4)
    final googleUser = GoogleAuthService().currentUser;

    // Màn hình có thể đã bị đóng trong lúc chờ
    if (!mounted) return;

    final Widget next;
    // Token rỗng hoặc chỉ toàn khoảng trắng cũng coi như chưa đăng nhập
    if (token != null && token.trim().isNotEmpty) {
      next = HomeScreen(username: username);
    } else if (googleUser != null) {
      next = HomeScreen(googleUser: googleUser);
    } else {
      next = const LoginScreen();
    }
    // Thay thế màn chờ để nút Back không quay lại màn này
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => next));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 72),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
