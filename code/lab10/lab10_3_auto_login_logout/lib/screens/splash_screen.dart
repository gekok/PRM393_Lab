import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_token_key.dart';
import 'home_screen.dart';
import 'login_screen.dart';

// Màn đầu tiên của app: đọc token đã lưu rồi chuyển sang Home hoặc Login
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _routeBySession();
  }

  Future<void> _routeBySession() async {
    String? token;
    try {
      final prefs = await SharedPreferences.getInstance();
      // null nghĩa là chưa đăng nhập hoặc đã logout
      token = prefs.getString(authTokenKey);
    } catch (_) {
      // Đọc phiên bị lỗi thì coi như chưa đăng nhập để người dùng đăng nhập lại
      token = null;
    }
    // Màn hình có thể đã bị đóng trong lúc chờ
    if (!mounted) return;

    // Token rỗng hoặc chỉ toàn khoảng trắng cũng coi như chưa đăng nhập
    final Widget next = (token != null && token.trim().isNotEmpty)
        ? HomeScreen(token: token)
        : const LoginScreen();
    // Thay thế Splash để nút Back không quay lại màn này
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
