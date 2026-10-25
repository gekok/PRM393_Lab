# Hướng dẫn đọc code – Lab 10.5 Local Notification

## Bài này làm gì?

App có một nút **Gửi thông báo**.
Bấm nút thì app xin quyền thông báo (Android 13+).
Được phép thì hệ thống hiện thông báo "Đăng nhập thành công".

Đây là thông báo cục bộ: app tự tạo ngay trên máy, không cần server hay Internet.

Cách chạy, cấu hình Android và kết quả kiểm thử nằm trong `README.md`.
File này chỉ giúp bạn đọc code.

## Nên đọc file theo thứ tự nào?

Ba file Dart là phần chính, đọc trước:

```
1. lib/main.dart
2. lib/services/notification_service.dart
3. lib/screens/home_screen.dart
```

Bốn file Android là phần cấu hình cho plugin, đọc sau:

```
4. android/app/src/main/AndroidManifest.xml
5. android/app/src/main/res/drawable/ic_stat_notification.xml
6. android/app/src/main/res/raw/keep.xml
7. android/app/build.gradle.kts
```

Cuối cùng là test:

```
8. test/home_screen_test.dart
```

## Mỗi file làm gì?

**`lib/main.dart`** — điểm bắt đầu của app.

- Gọi `NotificationService().init()` một lần, trước `runApp`.
- Chạy `NotificationApp`. Đây là một `StatelessWidget`.
- Hàm `build` của nó trả về `MaterialApp`, mở `HomeScreen`.

**`lib/services/notification_service.dart`** — gói plugin `flutter_local_notifications` thành 3 hàm.

- `init()`: khởi tạo plugin và tạo kênh thông báo.
- `requestPermission()`: xin quyền `POST_NOTIFICATIONS`, trả `true` nếu được phép.
- `showLoginSuccess()`: hiện thông báo "Đăng nhập thành công" / "Chào mừng bạn quay lại!".

Các hằng `static const` ở đầu lớp gom id, tên kênh, icon về một chỗ.

Lớp `NotificationService` không tự giữ dữ liệu riêng.
`FlutterLocalNotificationsPlugin()` luôn trả về cùng một plugin dùng chung.
Vì vậy màn hình tự tạo `NotificationService()` mới vẫn dùng được plugin mà `main()` đã `init()`.

**`lib/screens/home_screen.dart`** — màn hình có nút "Gửi thông báo".

- Bấm nút thì màn hình tự tạo `NotificationService()`, rồi xin quyền trước.
- Được phép thì gửi thông báo, rồi hiện SnackBar "Đã gửi thông báo...".
- Bị từ chối thì hiện SnackBar hướng dẫn bật trong Cài đặt.

**`AndroidManifest.xml`** — khai báo quyền `POST_NOTIFICATIONS`.
Plugin 22.x cũng tự khai báo quyền này. App khai báo lại để thấy rõ app cần quyền gì.

**`ic_stat_notification.xml`** — icon nhỏ (chuông trắng) hiện trên thanh trạng thái.

**`keep.xml`** — giữ icon trên lại khi build release.

**`build.gradle.kts`** — bật desugaring mà plugin yêu cầu.

**`test/home_screen_test.dart`** — một test duy nhất.
Nó kiểm màn hình có nút `FilledButton` mang chữ "Gửi thông báo" và dòng chữ hướng dẫn.

## Từ lúc mở app tới lúc thấy thông báo, chuyện gì xảy ra?

### Lúc mở app

```
main()
↓  WidgetsFlutterBinding.ensureInitialized()
↓  NotificationService().init()
↓     _plugin.initialize(...)          → icon nhỏ = ic_stat_notification
↓     createNotificationChannel(...)   → kênh id "login_success", Importance.high
↓  runApp(NotificationApp)
HomeScreen
```

### Khi bấm "Gửi thông báo"

```
HomeScreen: khóa nút (_sending = true)
↓  tạo NotificationService()
requestPermission()
↓  Android 13+, lần đầu: hiện hộp thoại "Allow ... to send you notifications?"
├─ được phép  → showLoginSuccess()
│               → thông báo hiện trên thanh trạng thái
│               → SnackBar "Đã gửi thông báo..."
└─ bị từ chối → SnackBar "Chưa có quyền thông báo..."
↓
finally: mở lại nút (_sending = false)
```

Nếu plugin báo lỗi, `catch` bắt lại và hiện SnackBar "Gửi thông báo thất bại: ...".

## Các khái niệm trong code nghĩa là gì?

**Thông báo cục bộ (local notification)**
App tự tạo thông báo ngay trên máy.
Khác thông báo đẩy (push notification), loại do server gửi qua Internet.

**Plugin `flutter_local_notifications`**
Plugin giúp code Dart gọi xuống hệ thống thông báo của Android.
`_plugin.initialize(...)` khởi tạo, `_plugin.show(...)` hiện một thông báo.

**Kênh thông báo (notification channel)**
Từ Android 8, mỗi thông báo phải thuộc một kênh, và người dùng bật/tắt từng kênh trong Cài đặt.
App này có một kênh: id trong code là `login_success`, tên người dùng thấy là "Đăng nhập".

**Mức độ quan trọng (`Importance`) và mức ưu tiên (`Priority`)**
`Importance.high` làm thông báo bật xuống đầu màn hình (heads-up), không chỉ nằm trong khay.
`Priority.high` là cách đặt tương tự cho Android 7, đời chưa có kênh.

**Quyền lúc chạy (runtime permission) `POST_NOTIFICATIONS`**
Từ Android 13 (API 33), app phải xin quyền lúc chạy, bằng `requestNotificationsPermission()`, mới hiện được thông báo.
Quyền này còn phải có trong manifest: plugin 22.x đã tự khai báo, app khai báo lại cho rõ ràng.

**Id của thông báo**
`_loginSuccessId = 1` là id cố định.
Gửi nhiều lần chỉ cập nhật một thông báo, không xếp chồng.

**Icon nhỏ (small icon)**
Android 5+ chỉ lấy hình dáng (độ trong suốt) của icon, rồi tô một màu.
Vì vậy icon là chuông trắng trên nền trong suốt.

**Giữ icon khi thu gọn app (`keep.xml` và R8)**
R8 thu gọn app khi build release, bỏ code và resource mà nó nghĩ không ai dùng.
Dart gọi icon bằng chuỗi tên nên R8 không thấy, `keep.xml` bảo R8 giữ icon lại.

**Chuyển đổi thư viện Java (desugaring)**
Cho phép dùng thư viện Java mới trên Android đời cũ.
README của plugin yêu cầu bật trong `build.gradle.kts`.

**Lấy phần riêng cho Android (`resolvePlatformSpecificImplementation<...>()`)**
Hàm này lấy phần riêng cho Android của plugin, tên trong `< >` cho biết lấy phần nền tảng nào.
Kết quả là `null` khi app không chạy trên Android.

**Thuộc tính tính toán (getter, từ khóa `get`)**
`get _androidPlugin { ... }` khai báo một getter: code đọc `_androidPlugin`, không có dấu `()`.
Mỗi lần đọc, thân getter chạy lại `resolvePlatformSpecificImplementation<...>()` rồi trả kết quả.

**Xử lý null (kiểm `== null` và `??`)**
`init()` và `requestPermission()` cùng viết `final androidPlugin = _androidPlugin;` rồi `if (androidPlugin == null) return ...;`.
Phải chép sang biến cục bộ trước, vì Dart không tự hiểu "đã kiểm, không null" với getter; với biến cục bộ thì hiểu.
`x ?? false` nghĩa là "nếu `x` null thì dùng `false`", ví dụ `granted ?? false` trong `requestPermission()`.

**Dấu gạch dưới `_` ở đầu tên**
Tên như `_plugin`, `_androidPlugin`, `_sending`, `_showMessage` là riêng tư (private): chỉ code trong cùng file dùng được.

**Hằng số dùng chung của lớp (`static const`)**
Hằng số dùng chung cho cả lớp, cố định ngay lúc biên dịch.
Đổi tên kênh hay id chỉ cần sửa một chỗ.

**Đối tượng dùng chung (singleton)**
`FlutterLocalNotificationsPlugin()` nhìn như tạo mới, nhưng luôn trả về cùng một đối tượng (singleton).
Vì vậy `init()` gọi ở `main()` có tác dụng cho mọi `NotificationService()` tạo sau.

**Hàm bất đồng bộ (`Future`, `async`, `await`)**
`Future` là kết quả "sẽ có sau", ví dụ chờ người dùng bấm Allow.
`await` (chỉ dùng trong hàm `async`) cho hàm đó tạm dừng chờ kết quả, còn giao diện vẫn chạy.

**Khởi tạo binding (`WidgetsFlutterBinding.ensureInitialized()`)**
Chuẩn bị phần nối giữa Dart và Android (binding) trước khi `runApp` chạy.
Plugin cần phần này, nên phải gọi trước `init()` trong `main()`.

**`StatefulWidget` và `setState`**
`_sending` là dữ liệu tự đổi được (state) của `HomeScreen`.
`setState(() => _sending = true)` đổi nó và vẽ lại màn hình.

**Toán tử ba ngôi (`điều kiện ? a : b`) và cách khóa nút**
`_sending ? null : _sendNotification` nghĩa là "đang gửi thì `null`, không thì `_sendNotification`".
Nút có `onPressed` là `null` thì bị khóa, không bấm được.

**`mounted`**
Trong lúc `await`, màn hình có thể đã bị đóng.
`_showMessage` kiểm `mounted` trước khi hiện SnackBar.

**`try` / `catch` / `finally`**
`catch` bắt lỗi của plugin để báo bằng SnackBar.
`finally` luôn chạy, kể cả khi `return` sớm lúc bị từ chối quyền, nên nút luôn được mở lại.

**`ScaffoldMessenger`, `SnackBar` và dấu `..`**
`SnackBar` là thanh thông báo nhỏ ở đáy màn hình, nằm trong app (khác thông báo hệ thống).
Dấu `..` (cascade) gọi liên tiếp hai hàm trên cùng một đối tượng: ẩn SnackBar cũ, rồi hiện SnackBar mới.

**Kiểm thử giao diện (widget test: `testWidgets`, `pumpWidget`, `find`, `expect`)**
`pumpWidget` dựng màn hình trong môi trường test, không cần điện thoại.
`find.widgetWithText(...)` tìm nút có chữ, `find.text(...)` tìm dòng chữ, `expect(..., findsOneWidget)` kiểm có đúng một chỗ.
