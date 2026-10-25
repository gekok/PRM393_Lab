# Lab10_2_RealApiLogin

Lab 10.2: đăng nhập bằng REST API thật (DummyJSON `POST /auth/login`).
Thay cho `MockAuthService` ở Lab 10.1, app gửi request HTTP thật và xử lý loading, lỗi.

Mới đọc code lần đầu: xem `HUONG_DAN_DOC.md` (thứ tự đọc file, luồng chạy, giải thích khái niệm).

## Cách chạy

Yêu cầu: Flutter 3.47.7 (Dart 3.13.5) và kết nối Internet.

```
flutter pub get
flutter run
```

Chạy test (1 widget test: bấm Login khi form trống thì hiện lỗi; test này không gọi mạng):

```
flutter test
```

## Tài khoản test

- Username: `emilys`
- Password: `emilyspass`

Danh sách user khác của DummyJSON: https://dummyjson.com/users

## Tính năng

- Form có ô Username (không được rỗng) và ô Password (ẩn ký tự, tối thiểu 6 ký tự).
- Gửi `POST https://dummyjson.com/auth/login` với header `Content-Type: application/json` và body `{"username": ..., "password": ...}`.
- Thành công (HTTP 200): đọc `accessToken`, `username`, `email`, `firstName`, `lastName`, `image`, rồi sang `HomeScreen` (ảnh đại diện, tên, email, access token rút gọn).
- Các trạng thái:
  - Đang chờ: nút Login bị vô hiệu hóa và hiện vòng xoay.
  - Sai tài khoản (HTTP 400): hiện đúng `message` do server trả về, ví dụ `Invalid credentials`.
  - Mất mạng hoặc quá 10 giây không có phản hồi: hiện thông báo dễ hiểu, nút Login bật lại để thử lại.
  - Server trả dữ liệu lạ hoặc hỏng, hoặc có lỗi ngoài dự kiến: hiện thông báo chung, nút Login vẫn bật lại (không bị khóa mãi).
- Nút Logout trên Home đưa về màn Login (chưa lưu phiên, xem Lab 10.3).

## Cấu trúc thư mục

```
lib/main.dart                    Lab10App: mở màn Login đầu tiên
lib/models/auth_user.dart        AuthUser: user + token đọc từ JSON trả về
lib/services/auth_service.dart   AuthService: gọi API bằng http.post; AuthException
lib/screens/login_screen.dart    LoginScreen: form, loading, hiển thị lỗi
lib/screens/home_screen.dart     HomeScreen: màn sau khi đăng nhập, nút Logout
test/widget_test.dart            1 widget test: form trống hiện lỗi
```

## Giới hạn

- Token chỉ nằm trong bộ nhớ: tắt app là mất, phải đăng nhập lại (lưu phiên nằm ở Lab 10.3).
- Chưa dùng `refreshToken` để gia hạn phiên.
- Quá 10 giây app bỏ qua kết quả, nhưng request đã gửi đi vẫn chạy nốt ở nền.
- Android: `AndroidManifest.xml` chính đã thêm quyền `INTERNET`; thiếu quyền này thì bản release không gọi được API.
