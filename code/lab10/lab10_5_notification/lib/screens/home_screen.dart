import 'package:flutter/material.dart';

import '../services/notification_service.dart';

/// Màn hình demo: bấm nút để gửi thông báo "Đăng nhập thành công".
///
/// Bấm nút thì màn hình tự tạo [NotificationService] để gọi;
/// `main()` đã gọi `init()` một lần lúc mở app.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _sending = false;

  Future<void> _sendNotification() async {
    setState(() => _sending = true);
    try {
      final notificationService = NotificationService();
      // Xin quyền đúng lúc người dùng cần; Android 13+ hiện hộp thoại ở lần đầu.
      final granted = await notificationService.requestPermission();
      if (!granted) {
        _showMessage(
          'Chưa có quyền thông báo. Hãy bật trong Cài đặt > Ứng dụng > Thông báo.',
        );
        return;
      }
      await notificationService.showLoginSuccess();
      _showMessage('Đã gửi thông báo. Kéo thanh trạng thái xuống để xem.');
    } catch (error) {
      _showMessage('Gửi thông báo thất bại: $error');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab 10.5 - Local Notification')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.notifications_active_outlined, size: 72),
              const SizedBox(height: 16),
              const Text(
                'Bấm nút để giả lập thông báo sau khi đăng nhập thành công.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                // Khóa nút khi đang chờ hộp thoại xin quyền, tránh bấm chồng.
                onPressed: _sending ? null : _sendNotification,
                icon: const Icon(Icons.send),
                label: const Text('Gửi thông báo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
