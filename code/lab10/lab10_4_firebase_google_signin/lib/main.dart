import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  // Bắt buộc trước khi gọi plugin (Firebase, Google) khi chưa runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Cấu hình Firebase lấy từ firebase_options.dart (sinh bởi FlutterFire CLI).
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // google_sign_in v7: phải initialize() đúng một lần trước mọi lệnh khác.
  // Không truyền serverClientId vì trên Android plugin tự đọc web client id
  // (default_web_client_id) do plugin Gradle google-services sinh từ google-services.json.
  await GoogleSignIn.instance.initialize();

  runApp(const GoogleSignInApp());
}

/// Gốc của app: mở SplashScreen trước, sau đó mỗi màn hình tự chuyển màn theo luồng
/// Splash → SignIn hoặc Profile → (Đăng xuất) → SignIn.
class GoogleSignInApp extends StatelessWidget {
  const GoogleSignInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 10.4 - Google Sign-In',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const SplashScreen(),
    );
  }
}
