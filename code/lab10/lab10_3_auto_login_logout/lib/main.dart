import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';

void main() {
  runApp(const Lab10App());
}

class Lab10App extends StatelessWidget {
  const Lab10App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 10.3 - Auto Login & Logout',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      // Splash là màn đầu: nó quyết định đi tiếp sang Home hay Login
      home: const SplashScreen(),
    );
  }
}
