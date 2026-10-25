import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_token_key.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.token});

  // Chỉ có token vì lần auto-login chỉ khôi phục được token đã lưu, không có hồ sơ
  final String token;

  Future<void> _logout(BuildContext context) async {
    // Xóa token trước khi chuyển màn: lần mở app sau Splash sẽ không còn
    // thấy token nên quay về Login
    final prefs = await SharedPreferences.getInstance();
    // Chỉ xóa token; các khóa khác của app (nếu có) được giữ nguyên
    await prefs.remove(authTokenKey);
    if (!context.mounted) return;
    // Xóa hết các màn trong stack để nút Back không quay lại Home
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access token thật dài vài trăm ký tự nên chỉ hiện phần đầu
    final shortToken =
        token.length <= 16 ? token : '${token.substring(0, 16)}...';

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
                const Icon(Icons.check_circle, size: 72, color: Colors.green),
                const SizedBox(height: 16),
                Text(
                  'You are logged in',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.vpn_key_outlined),
                    title: const Text('Access token'),
                    subtitle: Text(shortToken),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The token is saved on this device. Close and reopen the '
                  'app to skip the login screen.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
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
