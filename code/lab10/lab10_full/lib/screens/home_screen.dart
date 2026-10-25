import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_token_key.dart';
import '../services/google_auth_service.dart';
import 'login_screen.dart';

// Màn sau khi đăng nhập. Đăng nhập Google thì truyền googleUser (hiện tên và
// email); đăng nhập DummyJSON thì truyền username. Logout xóa mọi phiên rồi về Login
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.googleUser, this.username});

  // User của Firebase: kết quả đăng nhập Google, hoặc phiên còn lưu khi tự đăng nhập
  final User? googleUser;

  // Username DummyJSON: vừa gõ ở Login, hoặc đọc lại từ SharedPreferences khi tự đăng nhập
  final String? username;

  Future<void> _logout(BuildContext context) async {
    // 1. Xóa phiên DummyJSON (như bài 10.3): lần mở app sau AuthGate không còn
    // thấy token nên quay về Login. Chỉ xóa 2 khóa này, các khóa khác giữ nguyên
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(authTokenKey);
    await prefs.remove(authUsernameKey);
    // 2. Thoát Firebase và Google (như bài 10.4). Đăng nhập bằng DummyJSON thì
    // không có phiên Google, nhưng đề yêu cầu Logout thoát cả hai nên vẫn gọi
    await GoogleAuthService().signOut();
    if (!context.mounted) return;
    // Xóa hết các màn trong stack để nút Back không quay lại Home
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Chép sang biến cục bộ để Dart biết user khác null bên trong nhánh if
    final user = googleUser;
    final Widget info;
    if (user != null) {
      // Đăng nhập Google: tên và email lấy từ User của Firebase, đều có thể null
      info = Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Name'),
            subtitle: Text(user.displayName ?? '(No display name)'),
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Email'),
            subtitle: Text(user.email ?? '(No email)'),
          ),
        ],
      );
    } else {
      // Đăng nhập DummyJSON: chỉ có username đã lưu lúc đăng nhập
      info = ListTile(
        leading: const Icon(Icons.person_outline),
        title: const Text('Username'),
        subtitle: Text(username ?? '(No saved username)'),
      );
    }

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
                  'You are logged in',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                Card(child: info),
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
