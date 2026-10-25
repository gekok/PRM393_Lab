import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab10_5_notification/screens/home_screen.dart';

void main() {
  testWidgets('hiển thị nút Gửi thông báo và dòng hướng dẫn', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.widgetWithText(FilledButton, 'Gửi thông báo'), findsOneWidget);
    expect(
      find.text('Bấm nút để giả lập thông báo sau khi đăng nhập thành công.'),
      findsOneWidget,
    );
  });
}
