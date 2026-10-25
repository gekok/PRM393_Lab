import 'package:flutter/material.dart';

import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.email, required this.token});

  final String email;
  final String token;

  void _logout(BuildContext context) {
    // Xóa hết các màn trong stack để nút Back không quay lại Home
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Chỉ hiện phần đầu của token cho gọn; token ngắn thì giữ nguyên
    final shortToken =
        token.length <= 16 ? token : '${token.substring(0, 16)}...';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        // Cuộn được để không tràn khi màn hình thấp (xoay ngang) hoặc chữ phóng to
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.check_circle, size: 72, color: Colors.green),
                const SizedBox(height: 16),
                Text(
                  'Login successful',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.email_outlined),
                        title: const Text('Email'),
                        subtitle: Text(email),
                      ),
                      ListTile(
                        leading: const Icon(Icons.vpn_key_outlined),
                        title: const Text('Mock token'),
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
