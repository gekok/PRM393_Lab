import 'package:flutter/material.dart';

import 'screens/login_screen.dart';

void main() {
  runApp(const Lab10App());
}

class Lab10App extends StatelessWidget {
  const Lab10App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 10.2 - Real API Login',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const LoginScreen(),
    );
  }
}
