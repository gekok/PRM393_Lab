// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lab10_full/screens/login_screen.dart';

void main() {
  // Chỉ dựng màn Login, không bấm nút, nên không gọi mạng, Firebase hay plugin
  // thông báo. Không dựng AuthGate vì nó đọc FirebaseAuth, mà test không có Firebase
  testWidgets('Login screen shows the DummyJSON form and the Google button', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.widgetWithText(TextFormField, 'Username'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Login'), findsOneWidget);
    expect(
      find.widgetWithText(OutlinedButton, 'Sign in with Google'),
      findsOneWidget,
    );
  });
}
