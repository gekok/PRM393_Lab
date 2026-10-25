# Lab10_3_AutoLogin_Logout

Lab 10.3: lưu phiên đăng nhập bằng `shared_preferences` để mở lại app là vào thẳng Home, và Logout để bắt đăng nhập lại.
Đăng nhập dùng API thật của DummyJSON như Lab 10.2.

Mới đọc code lần đầu: xem `HUONG_DAN_DOC.md` (thứ tự đọc file, luồng chạy, giải thích khái niệm).

## Cách chạy

Yêu cầu: Flutter 3.47.7 (Dart 3.13.5) và kết nối Internet.

```
flutter pub get
flutter run
```

Chạy test (1 widget test: có token đã lưu thì Splash vào thẳng Home; bấm Logout thì token bị xóa và về Login. Test này không gọi mạng):

```
flutter test
```

## Tài khoản test

- Username: `emilys`
- Password: `emilyspass`

## Cách thử 3 kịch bản của lab

1. Đăng nhập lần đầu: mở app, màn Login hiện ra, nhập tài khoản test rồi bấm Login. App sang Home và hiện access token (rút gọn).
2. Auto-login: tắt hẳn app rồi mở lại. App không hiện Login mà vào thẳng Home với cùng token.
3. Logout: bấm Logout trên Home. App về màn Login và xóa token. Tắt rồi mở lại app thì vẫn ở màn Login.

## Tính năng

- `SplashScreen` là màn đầu tiên: đọc token từ `SharedPreferences` (khóa `auth_token`, khai báo một lần là hằng số `authTokenKey` trong `lib/services/auth_token_key.dart`).
  - Có token: `pushReplacement` sang `HomeScreen`.
  - Không có token (hoặc token rỗng, token chỉ toàn khoảng trắng, hoặc đọc phiên bị lỗi): `pushReplacement` sang `LoginScreen`.
- `LoginScreen` gọi `AuthService` (gọi API như Lab 10.2, nhưng chỉ lấy `accessToken`). Đăng nhập thành công thì lưu token vào khóa `auth_token` rồi sang Home.
- `HomeScreen` có nút Logout: xóa khóa `auth_token`, rồi `pushAndRemoveUntil` về Login nên nút Back không quay lại Home.
- Xử lý lỗi như Lab 10.2: sai tài khoản hiện `message` của server, mất mạng hoặc quá 10 giây hiện thông báo dễ hiểu.

## Cấu trúc thư mục

```
lib/main.dart                    Lab10App: mở SplashScreen đầu tiên
lib/services/auth_service.dart   AuthService: gọi API đăng nhập, trả về access token
lib/services/auth_token_key.dart Hằng số authTokenKey: khóa lưu token, dùng chung cho 3 màn
lib/screens/splash_screen.dart   Đọc token trong SharedPreferences rồi chọn Home hoặc Login
lib/screens/login_screen.dart    Form đăng nhập, lưu token vào SharedPreferences khi thành công
lib/screens/home_screen.dart     Hiện token, nút Logout xóa token
test/widget_test.dart            1 widget test: auto-login rồi Logout
```

## Giới hạn

- Token nằm trong `SharedPreferences`, tức là chưa mã hóa. Bản thật nên dùng kho lưu trữ an toàn như `flutter_secure_storage`.
- Auto-login chỉ kiểm tra "có token hay không", không hỏi lại server và không kiểm tra hạn của token. Token hết hạn vẫn vào được Home.
- Chỉ lưu `accessToken`, nên sau auto-login Home chỉ có token chứ không có hồ sơ (tên, email, ảnh) như Lab 10.2.
- Chưa dùng `refreshToken` để gia hạn phiên.
- Android: `AndroidManifest.xml` chính đã thêm quyền `INTERNET` (thiếu thì bản release không gọi được API) và đặt `allowBackup="false"` để bản sao lưu cũ của Android không khôi phục lại token đã Logout.
