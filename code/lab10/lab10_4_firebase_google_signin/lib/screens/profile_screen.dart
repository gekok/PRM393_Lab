import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'sign_in_screen.dart';

/// Hồ sơ sau khi đăng nhập: ảnh, tên hiển thị, email và nút Đăng xuất.
///
/// Nhận `User` của Firebase: kết quả đăng nhập, hoặc phiên còn lưu khi auto-login.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.user});

  final User user;

  Future<void> _logout(BuildContext context) async {
    await AuthService().signOut();
    if (!context.mounted) return;
    // pushReplacement: bấm Back không quay lại Profile đã đăng xuất.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Link ảnh đại diện Google, null nếu tài khoản không có ảnh.
    final photoUrl = user.photoURL;
    final image = (photoUrl == null || photoUrl.isEmpty)
        ? null
        : NetworkImage(photoUrl);
    // Bán kính ảnh; icon mặc định dùng cùng cỡ.
    const avatarRadius = 48.0;
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ Google')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ảnh đại diện tròn. Icon mặc định nằm bên dưới ảnh nên vẫn hiện
              // khi ảnh đang tải, khi không có ảnh, hoặc khi ảnh tải lỗi.
              CircleAvatar(
                radius: avatarRadius,
                foregroundImage: image,
                // Có ảnh thì phải nhận lỗi tải (mất mạng, link hỏng) ở đây,
                // nếu không Flutter báo lỗi ra console; icon bên dưới tự lộ ra.
                onForegroundImageError: image == null
                    ? null
                    : (error, stackTrace) {},
                child: const Icon(Icons.person, size: avatarRadius),
              ),
              const SizedBox(height: 16),
              // Firebase cho phép null (tài khoản chưa đặt tên).
              Text(
                user.displayName ?? '(Chưa có tên hiển thị)',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              // Email là thông tin phụ nên để màu nhạt hơn tên.
              Text(
                user.email ?? '(Chưa có email)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout),
                label: const Text('Đăng xuất'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
