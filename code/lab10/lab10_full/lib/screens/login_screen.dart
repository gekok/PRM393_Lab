import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_token_key.dart';
import '../services/dummyjson_auth_service.dart';
import '../services/google_auth_service.dart';
import '../services/local_notification_service.dart';
import 'home_screen.dart';

// Màn đăng nhập có hai cách: form DummyJSON (như bài 10.3) và nút Google
// (như bài 10.4). Đăng nhập thành công bằng cách nào cũng xin quyền và hiện
// thông báo (như bài 10.5; bị từ chối quyền thì bỏ qua) rồi mới vào Home
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  // Mỗi cách đăng nhập một cờ chờ, để vòng xoay hiện đúng ở nút vừa bấm
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  // Khung báo lỗi dùng chung cho cả hai cách đăng nhập
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // DummyJSON đăng nhập bằng username (vd emilys) nên không kiểm tra '@'
  String? _validateUsername(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Please enter your username';
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Please enter your password';
    if (password.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  void _showError(String message) {
    // Màn hình có thể đã bị đóng trong lúc chờ
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _isGoogleLoading = false;
      _errorMessage = message;
    });
  }

  // Đăng nhập DummyJSON rồi lưu token (bài 10.2 + 10.3)
  Future<void> _submit() async {
    // Phím Enter trong ô password vẫn gọi được hàm này khi đang chờ server
    if (_isLoading || _isGoogleLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      // Xóa lỗi của lần thử trước để người dùng thấy lần này đang chạy
      _errorMessage = null;
    });

    // DummyJSON đăng nhập bằng username, nên username vừa gõ cũng là tên
    // của tài khoản; lưu lại để Home hiện được cả khi tự đăng nhập
    final username = _usernameController.text.trim();
    try {
      final token = await DummyJsonAuthService().login(
        username: username,
        password: _passwordController.text,
      );
      // Lưu phiên sau khi server xác nhận; lần mở app sau AuthGate sẽ đọc lại.
      // Ghi username trước, token sau cùng: AuthGate chỉ nhìn token, nên đã có
      // token thì username chắc chắn đã ghi xong
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(authUsernameKey, username);
      await prefs.setString(authTokenKey, token);
      await _onLoginSuccess(HomeScreen(username: username));
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      // Lỗi ngoài dự kiến (vd lệnh ghi SharedPreferences ném lỗi): vẫn phải
      // tắt loading, nếu không nút Login sẽ bị khóa mãi
      _showError('Something went wrong. Please try again.');
    }
  }

  // Đăng nhập Google qua Firebase (bài 10.4). Firebase tự lưu phiên trên máy,
  // nên ở đây không phải lưu token
  Future<void> _signInWithGoogle() async {
    if (_isLoading || _isGoogleLoading) return;

    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await GoogleAuthService().signInWithGoogle();
      await _onLoginSuccess(HomeScreen(googleUser: user));
    } catch (error) {
      // Lỗi (huỷ, sai cấu hình) từ GoogleAuthService được bắt ở đây.
      // AuthFailure ghi đè toString() nên '$error' ra đúng câu thông báo
      _showError('$error');
    }
  }

  // Bước chung sau khi đăng nhập thành công (DummyJSON hoặc Google):
  // xin quyền rồi hiện thông báo như nút "Gửi thông báo" của bài 10.5,
  // sau đó thay màn Login bằng Home
  Future<void> _onLoginSuccess(Widget home) async {
    try {
      final notificationService = NotificationService();
      // Android 13+ hiện hộp thoại xin quyền ở lần đầu
      final granted = await notificationService.requestPermission();
      // Bị từ chối thì bỏ qua thông báo nhưng vẫn vào Home
      if (granted) {
        await notificationService.showLoginSuccess();
      }
    } catch (error) {
      // Lỗi thông báo bị bắt ngay ở đây, không lọt ra catch của nút đăng nhập:
      // đăng nhập đã xong (token hoặc phiên Firebase đã lưu) thì vẫn phải vào Home
      debugPrint('Không hiện được thông báo: $error');
    }
    // Màn hình có thể đã bị đóng trong lúc chờ
    if (!mounted) return;
    // Thay thế màn Login để nút Back không quay lại form đăng nhập
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => home));
  }

  // Khung báo lỗi màu đỏ (icon lỗi + câu lỗi) hiện phía trên nút Login.
  // build() chỉ gọi hàm này khi _errorMessage khác null
  Widget _buildErrorBox(String message) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colors.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: colors.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Đang chờ một trong hai cách đăng nhập thì khóa cả hai nút
    final isBusy = _isLoading || _isGoogleLoading;
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          // Giới hạn bề rộng để form không bị kéo dãn trên màn hình lớn
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.account_circle, size: 72),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _usernameController,
                    textInputAction: TextInputAction.next,
                    // Báo lỗi ngay trên từng ô sau khi người dùng đã gõ vào ô đó
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateUsername,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 24),
                  // Khung báo lỗi hiện phía trên nút Login
                  if (_errorMessage != null) _buildErrorBox(_errorMessage!),
                  FilledButton(
                    // null = nút bị vô hiệu hóa trong lúc chờ server
                    onPressed: isBusy ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Login'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Test account: emilys / emilyspass',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  // Đường kẻ ngăn form DummyJSON với cách đăng nhập thứ hai
                  const Divider(height: 48),
                  OutlinedButton.icon(
                    // null = khóa nút, tránh bấm 2 lần khi hộp chọn tài khoản đang mở
                    onPressed: isBusy ? null : _signInWithGoogle,
                    icon: _isGoogleLoading
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
        ),
      ),
    );
  }
}
