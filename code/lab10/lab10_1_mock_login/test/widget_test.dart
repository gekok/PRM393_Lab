import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lab10_1_mock_login/main.dart';
import 'package:lab10_1_mock_login/screens/home_screen.dart';

void main() {
  testWidgets('valid credentials navigate to Home', (tester) async {
    await tester.pumpWidget(const Lab10App());

    // Tìm ô nhập theo nhãn hiển thị trên màn hình
    final emailField = find.widgetWithText(TextFormField, 'Email');
    final passwordField = find.widgetWithText(TextFormField, 'Password');

    // Nhập form rồi bấm Login; pump 1 frame để dựng trạng thái loading
    await tester.enterText(emailField, 'demo@test.com');
    await tester.enterText(passwordField, '123456');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    // Chờ hết 2 giây của mock để test không bỏ lại timer đang chạy
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('demo@test.com'), findsOneWidget);
  });
}
