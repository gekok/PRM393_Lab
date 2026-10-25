# Lab 10.5 – Local Notification (LO7)

App có một nút **Gửi thông báo**.
Bấm nút thì app xin quyền thông báo (Android 13+), rồi hệ thống hiện thông báo "Đăng nhập thành công".
Phần thông báo nằm riêng trong `NotificationService`, để Lab10_Full gọi lại sau khi đăng nhập thành công.

Mới học Flutter? Đọc [HUONG_DAN_DOC.md](HUONG_DAN_DOC.md) trước.
File đó có thứ tự nên đọc file, luồng chạy và giải thích từng khái niệm trong code.

## Cần chuẩn bị gì?

- Flutter 3.47.x (Dart 3.13) và Android SDK 36.
- Thiết bị hoặc emulator Android 13+ (API 33+) để thấy hộp thoại xin quyền.
  Android 7–12 (minSdk 24) vẫn chạy nhưng không có hộp thoại.
  Khi đó app chỉ đọc trạng thái bật/tắt thông báo của app trong Cài đặt.
- Không cần tài khoản, không cần Internet.

## Chạy thế nào?

```bash
cd code/lab10/lab10_5_notification
flutter pub get
flutter run -d <device-id>
```

Kiểm tra code:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

## App làm gì?

Lúc mở app, `main()` tạo một `NotificationService` rồi gọi `init()`:

```
FlutterLocalNotificationsPlugin.initialize(settings: ...)   icon nhỏ = drawable ic_stat_notification
↓
createNotificationChannel(...)                              channel "login_success", Importance.high
```

Khi bấm **Gửi thông báo**:

```
notificationService.requestPermission()
↓  Android 13+: hộp thoại "Allow ... to send you notifications?"
↓ được phép                     ↓ bị từ chối
showLoginSuccess()               SnackBar hướng dẫn bật trong Cài đặt
↓
Thông báo "Đăng nhập thành công" / "Chào mừng bạn quay lại!"
```

`NotificationService` có 3 hàm:

- `init()`: khởi tạo plugin và tạo channel. Gọi một lần trong `main()`.
- `requestPermission()`: xin quyền `POST_NOTIFICATIONS`, trả về `true` nếu được phép.
- `showLoginSuccess()`: hiện thông báo "Đăng nhập thành công" / "Chào mừng bạn quay lại!".

Muốn Lab10_Full dùng lại, app đó cần đủ các phần sau.
Quyền và channel gắn với từng app, nên những gì đã làm ở Lab 10.5 không dùng chung được.

- Copy `notification_service.dart`. Lab10_Full đặt bản chép ở `lib/services/local_notification_service.dart`, tên lớp vẫn là `NotificationService`.
- Tạo `NotificationService` và gọi `init()` trong `main()` của Lab10_Full.
- Gọi `requestPermission()` trong chính Lab10_Full (trước lần gửi đầu tiên).
- Có drawable `ic_stat_notification`, `res/raw/keep.xml` và desugaring trong Gradle.
  Quyền `POST_NOTIFICATIONS` thì plugin đã tự khai báo; app khai báo lại trong manifest cho rõ.
- Ngay sau khi đăng nhập thành công, tạo `NotificationService()` rồi gọi `showLoginSuccess()`.

## Đã cấu hình Android thế nào?

- `AndroidManifest.xml`: thêm `<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>`.
  Plugin 22.x đã tự khai báo quyền này; app khai báo lại để thấy rõ app cần quyền gì.
- `android/app/build.gradle.kts`: bật core library desugaring.
  README của plugin yêu cầu bật từ v10, kể cả khi app không hẹn giờ thông báo.

  ```kotlin
  compileOptions { isCoreLibraryDesugaringEnabled = true }
  dependencies { coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") }
  ```

- Không thêm `multiDexEnabled` dù README plugin có ghi: minSdk 24 ≥ 21 nên Android đã tự hỗ trợ multidex.
- Không dán khối `kotlinOptions` từ README plugin: template AGP 9 đã dùng `kotlin { compilerOptions { ... } }`.
- `res/drawable/ic_stat_notification.xml`: icon chuông trắng, nền trong suốt.
  Android 5+ chỉ lấy hình dáng (kênh alpha) của icon nhỏ rồi tô một màu, nên icon nhiều màu sẽ mất hết màu.
- `res/raw/keep.xml`: giữ icon trên khi build release.
  Dart gọi icon bằng tên chuỗi, nên R8 không thấy tham chiếu và có thể xoá icon.

Phiên bản: flutter_local_notifications 22.3.2 (constraint `^22.3.2`, giống lab10_full), AGP 9.1.0, compileSdk 36.

## Cấu trúc thư mục

```
lib/
  main.dart                              init NotificationService rồi chạy app
  screens/home_screen.dart               nút "Gửi thông báo" (bấm thì tự tạo NotificationService)
  services/notification_service.dart     init(), requestPermission(), showLoginSuccess()
android/app/
  build.gradle.kts                       bật core library desugaring cho plugin
android/app/src/main/
  AndroidManifest.xml                    quyền POST_NOTIFICATIONS
  res/drawable/ic_stat_notification.xml  icon nhỏ của thông báo
  res/raw/keep.xml                       giữ icon khi build release
test/
  home_screen_test.dart                  1 widget test: hiện nút "Gửi thông báo"
HUONG_DAN_DOC.md                         hướng dẫn đọc code cho người mới học
```

## Đã kiểm thử những gì?

`flutter test`: 1 widget test.
Test dựng `HomeScreen` và kiểm có nút `FilledButton` mang chữ "Gửi thông báo" cùng dòng chữ hướng dẫn.
Test chỉ dựng màn hình, không bấm nút, nên không gọi tới plugin thật.
Đề Lab 10 không yêu cầu test, nên bài chỉ giữ một test ngắn làm mẫu.

Kiểm chứng bản code ngay trước đợt sửa cho dễ đọc (xem cuối mục này) trên emulator `pixel7_api36` (API 36), bằng `app-debug.apk` mới build:

1. Cài xong, `lastUpdateTime` đổi sang giờ vừa cài.
2. Quyền `POST_NOTIFICATIONS` đang là `granted=true` (cờ `USER_SET`).
   Lần thử trước đã bấm Allow, nên lần này không hiện hộp thoại xin quyền.
3. Trước khi bấm nút, `dumpsys notification` không có bản ghi nào của `com.example.lab10_5_notification`.
4. Bấm "Gửi thông báo": `dumpsys notification` có bản ghi
   `pkg=com.example.lab10_5_notification id=1 importance=4 channel=login_success`,
   với `android.title=Đăng nhập thành công` và `android.text=Chào mừng bạn quay lại!`.
5. Kéo khay thông báo xuống thấy thông báo của "Lab10_5 Notification", có icon chuông.
   Ở một lần chạy ngay trước đó (cùng channel), thông báo còn bật xuống đầu màn hình (heads-up).

Bản code **trước khi rút gọn** còn được kiểm thêm hai việc, chưa chạy lại với bản hiện tại:

- Vừa cài mới: quyền là `granted=false`, channel `login_success` (importance 4 = HIGH) đã được tạo.
  Bấm nút thì hiện hộp thoại "Allow Lab10_5 Notification to send you notifications?".
  Bấm Allow thì quyền thành `granted=true`.
- Build release (có `keep.xml`): `aapt2 dump resources` trên `app-release.apk` vẫn thấy
  `drawable/ic_stat_notification` sau khi R8 thu gọn resource.
  Bản release cài lên emulator mở được, bấm nút vẫn ra đúng thông báo.

Lần rút gọn sửa code Dart và một comment trong `AndroidManifest.xml`.
Các phần tử của manifest, icon, `keep.xml` và Gradle giữ nguyên.

Sau đó có thêm một đợt sửa cho dễ đọc: `init()` kiểm null bằng `if` thay cho `?.`, và comment về importance được viết lại.
Đợt này không đổi hành vi; sau đợt này chỉ chạy lại `flutter analyze` và `flutter test`, chưa chạy lại trên emulator.

Tự kiểm lại sau khi bấm nút:

```bash
adb shell "dumpsys notification --noredact | grep -E 'NotificationRecord.*lab10_5|android.title=|android.text=' | grep -A2 lab10_5_notification"
```

## Giới hạn đã biết

- Chỉ chạy trên Android: project chỉ có thư mục `android`.
- Trên Android 13+, nếu người dùng từ chối quyền hai lần thì hệ thống không hỏi lại nữa. Khi đó `requestPermission()` trả `false` ngay, người dùng phải bật tay trong Cài đặt.
- Nếu người dùng chỉ tắt riêng channel "Đăng nhập" trong Cài đặt, quyền vẫn được cấp nên `requestPermission()` trả `true`. App vẫn báo "Đã gửi" nhưng thông báo không hiện.
- Thông báo dùng id cố định `1`: gửi nhiều lần chỉ cập nhật một thông báo, không xếp chồng.
- Chưa xử lý khi người dùng bấm vào thông báo (không truyền `onDidReceiveNotificationResponse`).
