import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_options.dart';
import 'screens/auth_gate.dart';
import 'services/local_notification_service.dart';

Future<void> main() async {
  // Bắt buộc trước khi gọi plugin (Firebase, Google, thông báo) khi chưa runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Như bài 10.4: cấu hình Firebase lấy từ firebase_options.dart (sinh bởi FlutterFire CLI).
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // google_sign_in v7: phải initialize() đúng một lần trước mọi lệnh khác.
  // Không truyền serverClientId vì trên Android plugin tự đọc web client id
  // (default_web_client_id) do plugin Gradle google-services sinh từ google-services.json.
  await GoogleSignIn.instance.initialize();

  // Như bài 10.5: khởi tạo plugin thông báo và tạo channel một lần lúc mở app.
  await NotificationService().init();

  runApp(const Lab10App());
}

// Gốc của app: mở AuthGate (màn chờ) trước, AuthGate chọn đi tiếp Home hay Login
class Lab10App extends StatelessWidget {
  const Lab10App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 10 - Full',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const AuthGate(),
    );
  }
}
