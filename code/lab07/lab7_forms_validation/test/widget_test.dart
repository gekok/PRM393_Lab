import 'package:flutter_test/flutter_test.dart';

import 'package:lab7_forms_validation/main.dart';

void main() {
  testWidgets('Signup form renders all fields', (WidgetTester tester) async {
    // Build signup app and trigger a frame.
    await tester.pumpWidget(const SignupApp());

    // Verify all four input fields show up.
    expect(find.text('Full name'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm password'), findsOneWidget);

    // Verify submit button shows up.
    expect(find.text('Create account'), findsWidgets);
  });
}
