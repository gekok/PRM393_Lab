import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab10_4_firebase_google_signin/screens/sign_in_screen.dart';

void main() {
  testWidgets('hiển thị nút Sign in with Google', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignInScreen()));

    expect(
      find.widgetWithText(FilledButton, 'Sign in with Google'),
      findsOneWidget,
    );
  });
}
