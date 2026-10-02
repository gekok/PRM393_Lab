import 'package:flutter/material.dart';

// Lab 7: form đăng ký có kiểm tra và UX tốt
// Gom 7.1 + 7.2 + 7.3 + 7.4 trong một file main.dart duy nhất
void main() {
  runApp(const SignupApp());
}

// Widget gốc giữ theme chung
// Dùng StatelessWidget vì không cần nhớ gì thêm
class SignupApp extends StatelessWidget {
  const SignupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PRM393 lab7',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SignupScreen(),
    );
  }
}

// Màn hình form đăng ký
// Dùng StatefulWidget vì phải nhớ: chữ đã gõ, focus, tick điều khoản, cờ đang chờ
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Chìa khóa điều khiển Form, để gọi validate() từ nút Submit
  final _formKey = GlobalKey<FormState>();

  // Controller giữ chữ người dùng đang gõ trong từng ô
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  // Tay nắm focus của từng ô, để nhảy Next/Done trên bàn phím
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  final _confirmFocus = FocusNode();

  // Hai công tắc ẩn hiện mật khẩu
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  // Checkbox điều khoản, bắt buộc tick mới cho nộp
  bool _acceptedTerms = false;

  // Cờ đang giả lập kiểm tra email, true thì khóa nút và hiện vòng xoay
  bool _isCheckingEmail = false;

  @override
  void dispose() {
    // Vòng đời cleanup: mở gì thì đóng nấy, tránh rò rỉ bộ nhớ
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  // Luật 1 (7.1 -> 7.2): tên bắt buộc, cắt khoảng trắng hai đầu rồi mới kiểm tra
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  // Luật 2 (7.1 -> 7.2): email bắt buộc, tối thiểu có @ và .
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final text = value.trim();
    if (!text.contains('@') || !text.contains('.')) {
      return 'Enter a valid email';
    }
    return null;
  }

  // Luật 3 (7.2): mật khẩu bắt buộc, dài từ 8 ký tự, có ít nhất 1 chữ số
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'At least 8 characters';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Must contain at least 1 digit';
    }
    return null;
  }

  // Luật 4 (7.2): ô nhập lại phải khớp chữ trong ô mật khẩu
  String? validateConfirm(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm password';
    }
    if (value != _passCtrl.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Đo mạnh mật khẩu để hiện chữ Weak / Medium / Strong (bonus)
  // Dưới 8 ký tự là Weak, có số là Medium, dài + số + ký tự đặc biệt là Strong
  String passwordStrength(String value) {
    if (value.length < 8) return 'Weak';
    final hasDigit = RegExp(r'[0-9]').hasMatch(value);
    final hasSpecial = RegExp(r'[!@#$%^&*]').hasMatch(value);
    if (value.length >= 12 && hasDigit && hasSpecial) return 'Strong';
    if (hasDigit) return 'Medium';
    return 'Weak';
  }

  // Nút nộp (7.1 + 7.4): kiểm tra đồng bộ trước, kiểm tra bất đồng bộ sau
  Future<void> _submit() async {
    // Giấu bàn phím trước khi kiểm tra cho gọn màn hình
    FocusScope.of(context).unfocus();

    // Bước 1: chạy hết validator, một ô sai thì cả form sai, dừng lại
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    // Bước 2: bắt tick điều khoản mới cho đi tiếp
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept Terms & Conditions')),
      );
      return;
    }

    // Bước 3: bật cờ chờ, khóa nút nộp lại
    setState(() {
      _isCheckingEmail = true;
    });

    // Bước 4: giả lập gọi server mất 2 giây
    await Future.delayed(const Duration(seconds: 2));

    // Màn hình có thể đã đóng trong lúc chờ, không còn mounted thì dừng
    if (!mounted) return;

    // Bước 5: luật email trùng giả, bắt đầu bằng taken là coi như đã dùng
    final email = _emailCtrl.text.trim().toLowerCase();
    if (email.startsWith('taken')) {
      setState(() {
        _isCheckingEmail = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This email is already taken')),
      );
      return;
    }

    // Bước 6: qua hết thì tắt cờ và báo thành công
    setState(() {
      _isCheckingEmail = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Signup success! Welcome ${_nameCtrl.text.trim()}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tính lại độ mạnh mỗi lần build để chữ Strength nhảy theo phím gõ
    final strength = passwordStrength(_passCtrl.text);

    return GestureDetector(
      // Chạm ra ngoài form thì giấu bàn phím (7.3)
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lab 7 Signup'),
        ),
        // Tránh tai thỏ và camera đục lỗ
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              // Chạm vào ô rồi mới báo lỗi, gõ sai thấy đỏ ngay (7.2)
              autovalidateMode: AutovalidateMode.onUserInteraction,
              // ListView để bàn phím mở lên vẫn cuộn được, không tràn (7.3)
              child: ListView(
                children: [
                  // Tiêu đề vùng hero 7.1
                  Text(
                    'Create account',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Ô 1: họ tên, Next để nhảy xuống email
                  TextFormField(
                    controller: _nameCtrl,
                    focusNode: _nameFocus,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Full name',
                      border: OutlineInputBorder(),
                    ),
                    validator: validateName,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_emailFocus);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Ô 2: email, bàn phím hiện dạng @ cho dễ gõ
                  TextFormField(
                    controller: _emailCtrl,
                    focusNode: _emailFocus,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'you@example.com',
                      border: OutlineInputBorder(),
                    ),
                    validator: validateEmail,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_passFocus);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Ô 3: mật khẩu, có nút mắt hiện ẩn (bonus)
                  TextFormField(
                    controller: _passCtrl,
                    focusNode: _passFocus,
                    obscureText: _obscurePass,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePass ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePass = !_obscurePass;
                          });
                        },
                      ),
                    ),
                    validator: validatePassword,
                    // Gõ mật khẩu thì vẽ lại để chữ Strength đổi theo
                    onChanged: (_) => setState(() {}),
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_confirmFocus);
                    },
                  ),
                  const SizedBox(height: 6),
                  // Dòng đo mạnh mật khẩu (bonus)
                  Text('Strength: $strength'),
                  const SizedBox(height: 12),

                  // Ô 4: nhập lại mật khẩu, Done thì nộp luôn
                  TextFormField(
                    controller: _confirmCtrl,
                    focusNode: _confirmFocus,
                    obscureText: _obscureConfirm,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Confirm password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirm = !_obscureConfirm;
                          });
                        },
                      ),
                    ),
                    validator: validateConfirm,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 12),

                  // Checkbox điều khoản (bonus), phải tick mới cho nộp
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('I accept Terms & Conditions'),
                    value: _acceptedTerms,
                    onChanged: (v) {
                      setState(() {
                        _acceptedTerms = v ?? false;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // Nút nộp, lúc chờ thì khóa và hiện vòng xoay (7.4)
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isCheckingEmail ? null : _submit,
                      child: _isCheckingEmail
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create account'),
                    ),
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
