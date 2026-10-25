import 'package:flutter/material.dart';

import '../services/mock_auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = MockAuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Please enter your email';
    // Chỉ cần có '@' là đủ cho bài lab, không dùng regex đầy đủ
    if (!email.contains('@')) return 'Invalid email format (missing @)';
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Please enter your password';
    if (password.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<void> _submit() async {
    // Phím Enter trong ô password vẫn gọi được hàm này khi đang chờ server
    if (_isLoading) return;
    // Form chưa hợp lệ thì dừng, không gọi "server"
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    // SnackBar thuộc ScaffoldMessenger nên tồn tại qua cả lúc đổi màn; ẩn lỗi của
    // lần thử trước để nó không còn hiện khi đang chờ hoặc sau khi sang Home
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    setState(() {
      _isLoading = true;
    });

    final token = await _authService.login(
      email: email,
      password: _passwordController.text,
    );

    // Màn hình có thể đã bị đóng trong lúc chờ
    if (!mounted) return;

    if (token == null) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Invalid credentials')));
      return;
    }

    // Thay thế màn Login để nút Back không quay lại form đăng nhập
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomeScreen(email: email, token: token),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mock Login')),
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
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    // Báo lỗi ngay trên từng ô sau khi người dùng đã gõ vào ô đó
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateEmail,
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
                    'Demo account: ${MockAuthService.demoEmail} / '
                    '${MockAuthService.demoPassword}',
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
