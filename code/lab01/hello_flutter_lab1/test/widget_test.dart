import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hello_flutter_lab1/main.dart';

void main() {
  // Kiểm tra các widget chính của giao diện Lab 1 được dựng đúng.
  // Test tạo MyApp, tìm text/icon/FAB và xác nhận mỗi phần xuất hiện một lần.
  testWidgets('renders the customized Lab 1 UI', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Lab 1 Demo'), findsOneWidget);
    expect(find.text('Welcome to Flutter!'), findsOneWidget);
    expect(find.text('Your first customized layout 😊'), findsOneWidget);
    expect(find.byIcon(Icons.flutter_dash), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
