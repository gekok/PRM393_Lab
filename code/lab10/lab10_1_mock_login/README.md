# Lab10_1_MockLogin

Lab 10.1: màn hình đăng nhập (email + password) giả lập backend bằng `MockAuthService`.
Có validate bằng `Form`, độ trễ 2 giây và mock token. Chưa gọi Internet.

Mới đọc code lần đầu: xem `HUONG_DAN_DOC.md` (thứ tự đọc file, luồng chạy, giải thích khái niệm).

## Cách chạy

Yêu cầu: Flutter 3.47.7 (Dart 3.13.5), Android emulator hoặc thiết bị Android.

```
flutter pub get
flutter run
```

Chạy test (1 widget test: đăng nhập bằng tài khoản demo rồi kiểm tra đã sang Home):

```
flutter test
```

## Tài khoản test

- Email: `demo@test.com`
- Password: `123456`

Tài khoản khác (hoặc để trống) sẽ bị từ chối.

## Tính năng

- Màn Login có ô Email, ô Password (ẩn ký tự) và nút Login.
- Validate bằng `Form` + `validator`:
  - Email không được rỗng và phải chứa `@`.
  - Password không được rỗng và tối thiểu 6 ký tự.
- Bấm Login gọi hàm `login()` của `MockAuthService` và chờ 2 giây để giả lập mạng. Trong lúc chờ, nút Login bị vô hiệu hóa và hiện vòng xoay.
- Đúng tài khoản demo: sang `HomeScreen`, hiện email và mock token (rút gọn 16 ký tự đầu). Nút Back không quay lại Login.
- Sai tài khoản: ở lại màn Login và hiện SnackBar `Invalid credentials`.
- Nút Logout trên Home đưa về màn Login và xóa hết stack điều hướng. Lab 10.1 chưa lưu token nên không có gì để xóa (phần xóa token nằm ở Lab 10.3).
- Màn Login và Home đều cuộn được, nên không bị tràn khi xoay ngang hoặc khi chữ phóng to.

## Cấu trúc thư mục

```
lib/main.dart                        Lab10App: mở màn Login đầu tiên
lib/services/mock_auth_service.dart  MockAuthService: server giả, kiểm tra tài khoản demo
lib/screens/login_screen.dart        LoginScreen: form, validate, loading, báo lỗi
lib/screens/home_screen.dart         HomeScreen: email, token rút gọn, nút Logout
test/widget_test.dart                1 widget test: tài khoản demo đăng nhập sang Home
```

## Giới hạn

- Chỉ là mock: token là chuỗi `mock-token-<timestamp>` tự sinh, không do server cấp.
- Chưa lưu phiên đăng nhập: tắt app là phải đăng nhập lại (phần lưu phiên nằm ở Lab 10.3).
- Chưa có đăng nhập bằng API thật (Lab 10.2).
