import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab10_2_real_api_login/main.dart';

void main() {
  testWidgets('empty form shows required errors and does not call the API', (
    tester,
  ) async {
    await tester.pumpWidget(const Lab10App());

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text('Please enter your username'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
    // Form chưa hợp lệ nên không gọi API: không có vòng xoay chờ server
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
