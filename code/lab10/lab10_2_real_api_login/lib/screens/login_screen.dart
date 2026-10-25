import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
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
      _errorMessage = message;
    });
  }

  Future<void> _submit() async {
    // Phím Enter trong ô password vẫn gọi được hàm này khi đang chờ server
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      // Xóa lỗi của lần thử trước để người dùng thấy lần này đang chạy
      _errorMessage = null;
    });

    try {
      final user = await _authService.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );
      // Màn hình có thể đã bị đóng trong lúc chờ
      if (!mounted) return;
      // Thay thế màn Login để nút Back không quay lại form đăng nhập
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
      );
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      // Lỗi ngoài dự kiến: vẫn phải tắt loading, nếu không nút Login sẽ bị
      // khóa mãi
      _showError('Something went wrong. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Real API Login')),
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
                  if (_errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: colors.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: colors.onErrorContainer),
                            ),
                          ),
                        ],
                      ),
                    ),
                  FilledButton(
                    // null = nút bị vô hiệu hóa trong lúc chờ server
                    onPressed: _isLoading ? null : _submit,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
