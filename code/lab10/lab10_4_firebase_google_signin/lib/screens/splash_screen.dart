import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'profile_screen.dart';
import 'sign_in_screen.dart';

/// Màn hình chờ: kiểm tra phiên đăng nhập còn lưu trên máy rồi chuyển màn.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigator đang dựng frame đầu tiên nên chưa chuyển màn được trong initState
    // → đợi frame vẽ xong rồi mới kiểm tra phiên.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Đọc user của phiên Firebase hiện có (null = chưa đăng nhập).
      final user = AuthService().currentUser;
      // pushReplacement: bấm Back không quay lại Splash đã đi qua.
      if (user == null) {
        // Không còn phiên → sang màn hình đăng nhập.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        );
      } else {
        // Còn phiên → vào thẳng Profile (auto-login).
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen(user: user)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang kiểm tra phiên đăng nhập...'),
          ],
        ),
      ),
    );
  }
}
