import 'package:flutter_test/flutter_test.dart';
import 'package:lab10_3_auto_login_logout/main.dart';
import 'package:lab10_3_auto_login_logout/screens/home_screen.dart';
import 'package:lab10_3_auto_login_logout/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('saved token opens Home, Logout removes it and returns to Login', (
    tester,
  ) async {
    // Giả lập máy đã lưu token từ lần đăng nhập trước
    SharedPreferences.setMockInitialValues({'auth_token': 'abc'});

    // Mở app từ đầu: Splash đọc token rồi chuyển màn
    await tester.pumpWidget(const Lab10App());
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('auth_token'), isFalse);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });
}
