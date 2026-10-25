# Lab10_Full – Authentication, Session & Notification

Bài tích hợp của Lab 10: gộp 5 bài con thành một app.

- Màn chờ (Splash) tự chọn vào Home hoặc Login.
- Đăng nhập bằng API thật DummyJSON, hoặc bằng tài khoản Google qua Firebase.
- Tự đăng nhập lại khi mở app, Logout để bắt đăng nhập lại.
- Đăng nhập thành công thì hiện thông báo cục bộ "Đăng nhập thành công".

Mới học Flutter? Đọc [HUONG_DAN_DOC.md](HUONG_DAN_DOC.md) trước.
File đó có thứ tự nên đọc file, luồng chạy và giải thích từng khái niệm trong code.

## Cần chuẩn bị gì?

- Flutter 3.47.x (Dart 3.13) và Android SDK.
- Thiết bị Android thật, hoặc emulator. Nên dùng Android 13+ (API 33+) để thấy hộp thoại xin quyền thông báo.
- Kết nối Internet (DummyJSON và Firebase cần mạng).
- Muốn thử đăng nhập Google: thiết bị phải có **Google Play** (máy thật, hoặc emulator image Google Play) và đã đăng nhập sẵn một tài khoản Google.
- Bản debug phải ký bằng debug keystore có SHA-1 đã đăng ký trên Firebase (xem README của Lab 10.4).

## Chạy thế nào?

```bash
cd code/lab10/lab10_full
flutter pub get
flutter run -d <device-id>
```

Kiểm tra code:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

## Tài khoản test

DummyJSON:

- Username: `emilys`
- Password: `emilyspass`

Ô đầu tiên là **Username**, không phải email, vì DummyJSON đăng nhập bằng username.

Google: không có tài khoản test cố định, dùng tài khoản Google của bạn.
Đăng nhập Google cần thiết bị có Google Play và đã đăng nhập sẵn tài khoản Google.
Emulator thiếu Google Play Services thì không đăng nhập Google được, nên dùng emulator có Play Store hoặc máy thật.
Slide Module 10 ghi là khi đó đăng nhập "trả về null", nhưng google_sign_in 7.x trong bài này không trả `null`: `GoogleSignIn.instance.authenticate()` ném `GoogleSignInException` khi thất bại.
`GoogleAuthService` đổi lỗi đó thành `AuthFailure`, rồi màn Login hiện câu lỗi trong khung đỏ.

## Đề yêu cầu gì, code nằm ở đâu?

```
SplashScreen routing        → lib/screens/auth_gate.dart
Đăng nhập API thật          → lib/services/dummyjson_auth_service.dart + lib/screens/login_screen.dart
Tự đăng nhập và Logout      → SharedPreferences (auth_gate, login_screen) + lib/screens/home_screen.dart
Firebase Google Sign-In     → lib/services/google_auth_service.dart
Thông báo sau khi đăng nhập → lib/services/local_notification_service.dart, gọi trong _onLoginSuccess của login_screen.dart
```

## App làm gì?

Lúc mở app:

```
main()
↓  Firebase.initializeApp(...)
↓  GoogleSignIn.instance.initialize()
↓  NotificationService().init()
AuthGate: có token DummyJSON hoặc còn phiên Google?
├─ có    → HomeScreen
└─ không → LoginScreen
```

Đăng nhập thành công (DummyJSON hoặc Google):

```
DummyJSON: lưu username, rồi lưu token vào SharedPreferences
↓
requestPermission() → được phép thì showLoginSuccess()
↓
HomeScreen: tên + email (Google) hoặc username (DummyJSON)
```

Logout:

```
xóa token + username trong SharedPreferences
↓
FirebaseAuth.instance.signOut()
↓
GoogleSignIn.instance.signOut()
↓
LoginScreen
```

## Đã cấu hình Android thế nào?

- `android/app/src/main/AndroidManifest.xml`:
  - quyền `INTERNET` (thiếu thì bản release không gọi được API), giống Lab 10.3;
  - quyền `POST_NOTIFICATIONS` (plugin đã tự khai báo, app khai báo lại cho rõ), giống Lab 10.5;
  - `android:allowBackup="false"`, để bản sao lưu cũ không khôi phục token đã Logout, giống Lab 10.3.
- `res/drawable/ic_stat_notification.xml` và `res/raw/keep.xml`: chép từ Lab 10.5.
  Thiếu icon này thì `NotificationService().init()` báo lỗi và app không mở được.
- Gradle giữ nguyên: plugin `google-services` và desugaring cho thông báo đã có sẵn.
- `applicationId` và `namespace` giữ nguyên là `com.example.lab10_full`.

## Lab 10.4 và Lab10_Full là cùng một app trên máy

Hai bài dùng chung package `com.example.lab10_full`, vì `google-services.json` chỉ đăng ký package này.

- Cài bài này sẽ ghi đè bài kia trên cùng thiết bị.
- Dữ liệu app được giữ khi cài đè, nên phiên Firebase của bài kia vẫn còn.
- Vì vậy lần mở đầu tiên có thể vào thẳng Home bằng tài khoản Google cũ. Bấm Logout là về Login.
- Logout của Lab 10.4 chỉ thoát Firebase và Google. Bài đó không dùng SharedPreferences, nên không xóa token DummyJSON của bài này.
  Theo code (chưa thử trên máy), kịch bản sau vẫn vào thẳng Home:

  ```
  đăng nhập DummyJSON ở bài này
  ↓
  cài Lab 10.4 đè lên, bấm Đăng xuất ở đó
  ↓
  cài lại bài này, mở app
  ```

## Cấu trúc thư mục

```
lib/
  main.dart                               khởi tạo Firebase, Google Sign-In, thông báo; mở AuthGate
  firebase_options.dart                   cấu hình Firebase (FlutterFire CLI sinh)
  screens/auth_gate.dart                  màn chờ: đọc phiên rồi chọn Home hoặc Login
  screens/login_screen.dart               form DummyJSON + nút Google, thông báo khi thành công
  screens/home_screen.dart                tên/email hoặc username, nút Logout
  services/auth_token_key.dart            tên khóa lưu token và username
  services/dummyjson_auth_service.dart    gọi API DummyJSON, trả về token; AuthException
  services/google_auth_service.dart       đăng nhập/thoát Google qua Firebase; AuthFailure
  services/local_notification_service.dart  NotificationService: init, requestPermission, showLoginSuccess
test/
  widget_test.dart                        1 widget test: màn Login có form và nút Google
android/app/src/main/
  AndroidManifest.xml                     quyền INTERNET, POST_NOTIFICATIONS; allowBackup=false
  res/drawable/ic_stat_notification.xml   icon nhỏ của thông báo
  res/raw/keep.xml                        giữ icon khi build release
HUONG_DAN_DOC.md                          hướng dẫn đọc code cho người mới học
```

Tên màn hình giống 10.1–10.3: `LoginScreen` (`login_screen.dart`) và `HomeScreen` (`home_screen.dart`).
Bản trước của bài này đặt là `LoginPage`/`HomePage`; nay đổi lại để cùng một màn mang cùng một tên ở 10.1–10.3 và bài full.
`AuthGate` giữ tên riêng vì việc chính của nó là điều hướng: đọc phiên rồi chọn Home hay Login.
Bảng đầy đủ tên nào lấy từ bài con nào nằm trong `HUONG_DAN_DOC.md`.

## Đã kiểm thử những gì?

Đã chạy trên máy Windows (Flutter 3.47.7, Dart 3.13.5):

- `flutter analyze`: `No issues found!`
- `flutter test`: 1 test, `All tests passed!`
  Test dựng `LoginScreen` và kiểm có ô Username, ô Password, nút Login, nút "Sign in with Google".
  Test không bấm nút, nên không gọi mạng, Firebase hay plugin thông báo.
  Đề Lab 10 không yêu cầu test, nên bài chỉ giữ một test ngắn làm mẫu.
- `flutter build apk --debug`: build thành công `build/app/outputs/flutter-apk/app-debug.apk`.
- File APK có `res/drawable/ic_stat_notification.xml`.

Đã mở thử trên emulator `pixel7_api36` (API 36), bằng `app-debug.apk` ở trên:

- Cài xong, app mở được và hiện màn Login (ô Username, ô Password, nút Login, nút "Sign in with Google").
- Logcat có `FirebaseApp initialization successful`. Sau 10 giây không có dòng `FATAL` hay `AndroidRuntime`, app vẫn chạy.
- App đã cài có quyền `INTERNET` và `POST_NOTIFICATIONS`, không có cờ `ALLOW_BACKUP` (tức `allowBackup="false"`).
- Lần này chỉ mở app, chưa đăng nhập.

**Chưa kiểm trên máy.** Những việc sau cần thử tay:

- Đăng nhập DummyJSON, tự đăng nhập lại, Logout.
- Đăng nhập Google thật (cần tài khoản Google và Google Play).
- Hộp thoại xin quyền và thông báo "Đăng nhập thành công" có hiện thật không.

Các bước thử nằm ở mục "Tự thử bằng tay thế nào?" trong `HUONG_DAN_DOC.md`.

## Giới hạn đã biết

- Chỉ chạy trên Android.
- Token nằm trong SharedPreferences, chưa mã hóa. Bản thật nên dùng kho an toàn như `flutter_secure_storage`.
- Tự đăng nhập chỉ kiểm "có token hay không", không hỏi lại server, không kiểm hạn token.
- Username hiện ở Home là username đã gõ lúc đăng nhập (DummyJSON đăng nhập bằng username).
- Bị từ chối quyền thông báo thì app vẫn vào Home nhưng không có thông báo. Bật lại trong Cài đặt > Ứng dụng > Thông báo.
- Nếu chính `FirebaseAuth.signOut()` lỗi (rất hiếm), app ở lại Home.
- Lúc build, Flutter cảnh báo firebase_auth và firebase_core còn dùng Kotlin Gradle Plugin. Hiện vẫn build được.

## Tài liệu Flutter

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)
