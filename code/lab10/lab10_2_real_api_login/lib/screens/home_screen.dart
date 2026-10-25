import 'package:flutter/material.dart';

import '../models/auth_user.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.user});

  final AuthUser user;

  void _logout(BuildContext context) {
    // Xóa hết các màn trong stack để nút Back không quay lại Home
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullName = '${user.firstName} ${user.lastName}'.trim();
    final displayName = fullName.isEmpty ? user.username : fullName;
    // Access token thật dài vài trăm ký tự nên chỉ hiện phần đầu
    final shortToken = user.accessToken.length <= 16
        ? user.accessToken
        : '${user.accessToken.substring(0, 16)}...';
    // Icon dự phòng (fallback) khi không có ảnh hoặc tải ảnh lỗi
    const fallback = Icon(Icons.account_circle, size: 96);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ảnh đại diện lấy từ server; không có URL hoặc tải lỗi thì hiện icon mặc định
                Center(
                  child: user.image.isEmpty
                      ? fallback
                      : ClipOval(
                          child: Image.network(
                            user.image,
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                fallback,
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome, $displayName',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text('@${user.username}', textAlign: TextAlign.center),
                const SizedBox(height: 24),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.email_outlined),
                        title: const Text('Email'),
                        subtitle: Text(user.email),
                      ),
                      ListTile(
                        leading: const Icon(Icons.vpn_key_outlined),
                        title: const Text('Access token'),
                        subtitle: Text(shortToken),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
