import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'profile_screen.dart';

/// Màn hình đăng nhập với một nút "Sign in with Google".
///
/// Màn hình không gọi Firebase trực tiếp: việc đăng nhập nằm trong [AuthService].
/// Màn hình chỉ lo khóa nút khi đang chờ, báo lỗi bằng SnackBar
/// và chuyển sang Profile khi đăng nhập xong.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _loading = false;

  Future<void> _handleSignIn() async {
    setState(() => _loading = true);
    try {
      final user = await AuthService().signInWithGoogle();
      if (!mounted) return;
      // pushReplacement: bấm Back không quay lại SignIn đã đi qua.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen(user: user)),
      );
    } catch (error) {
      // Lỗi (huỷ, sai cấu hình) từ AuthService được bắt ở đây;
      // nội dung lỗi được hiện lên SnackBar.
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('$error')));
    } finally {
      // Mở lại nút để người dùng thử lại khi lỗi hoặc huỷ.
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab 10.4 - Google Sign-In')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 72),
              const SizedBox(height: 16),
              const Text(
                'Đăng nhập bằng tài khoản Google để tiếp tục',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                // null = khóa nút, tránh bấm 2 lần khi hộp chọn tài khoản đang mở.
                onPressed: _loading ? null : _handleSignIn,
                icon: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login),
                label: const Text('Sign in with Google'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
