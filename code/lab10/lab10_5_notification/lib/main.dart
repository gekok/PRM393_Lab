import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  // Bắt buộc trước khi gọi plugin khi chưa runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo plugin và tạo channel một lần lúc mở app.
  await NotificationService().init();

  runApp(const NotificationApp());
}

class NotificationApp extends StatelessWidget {
  const NotificationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 10.5 - Local Notification',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const HomeScreen(),
    );
  }
}
