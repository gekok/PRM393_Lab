# Lab 10.4 – Firebase Google Sign-In

Đăng nhập bằng tài khoản Google qua Firebase Authentication.
Sau khi đăng nhập, app hiện ảnh, tên hiển thị và email.
Nút **Đăng xuất** thoát cả Firebase lẫn Google rồi quay về màn hình đăng nhập.

Mới học Flutter? Đọc [HUONG_DAN_DOC.md](HUONG_DAN_DOC.md) trước.
File đó có thứ tự nên đọc file, luồng chạy và giải thích từng khái niệm trong code.

## Cần chuẩn bị gì?

- Flutter 3.47.x (Dart 3.13) và Android SDK 36.
- Thiết bị Android thật, hoặc emulator dùng image **Google Play** (có Play Store).
- Thiết bị đã đăng nhập sẵn một tài khoản Google.
- Không có tài khoản test cố định: dùng tài khoản Google của bạn.
- Bản debug phải ký bằng debug keystore có SHA-1 đã đăng ký trên Firebase.
  Máy đang dùng đã khớp. Máy khác cần thêm SHA-1 của máy đó (xem mục "Gặp lỗi thì kiểm tra gì?").

## Chạy thế nào?

```bash
cd code/lab10/lab10_4_firebase_google_signin
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

Lúc mở app:

```
main()
↓  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
↓  GoogleSignIn.instance.initialize()
SplashScreen: đọc FirebaseAuth.instance.currentUser
↓ còn phiên                         ↓ chưa có phiên
ProfileScreen (tự đăng nhập lại)    SignInScreen
```

Khi bấm **Sign in with Google**:

```
GoogleSignIn.instance.authenticate()        → hộp chọn tài khoản Google
↓
account.authentication.idToken
↓
GoogleAuthProvider.credential(idToken: ...)
↓
FirebaseAuth.instance.signInWithCredential(...)
↓
ProfileScreen: ảnh, tên hiển thị, email
```

Khi bấm **Đăng xuất**:

```
FirebaseAuth.instance.signOut()
↓
GoogleSignIn.instance.signOut()
↓
SignInScreen
```

Vài hành vi cần biết:

- Mọi lần chuyển màn dùng `pushReplacement`, nên nút Back không quay lại Splash hay SignIn.
- Huỷ hộp chọn tài khoản hoặc sai cấu hình → SnackBar báo lỗi, nút bấm lại được.
- Đã chọn tài khoản Google nhưng Firebase từ chối → app thoát Google trước khi báo lỗi,
  vì google_sign_in khuyên gọi `signOut()` trước lần `authenticate()` kế tiếp.
- Google signOut lỗi vẫn về SignIn, vì Firebase đã được thoát trước.

## Vì sao applicationId và namespace là `com.example.lab10_full`?

`google-services.json` được copy từ `lab10_full`.
File này chỉ đăng ký app Android có package `com.example.lab10_full`, kèm SHA-1 debug của máy này.

Nếu đặt package khác:

- Plugin Gradle `google-services` dừng build với lỗi `No matching client found for package name`.
- Google Sign-In từ chối, vì cặp package + SHA-1 không khớp Firebase (DEVELOPER_ERROR hoặc báo "đã huỷ").

`namespace` đổi theo để `.MainActivity` trong manifest trỏ đúng class.
Vì vậy `MainActivity.kt` nằm ở `android/app/src/main/kotlin/com/example/lab10_full/`.

Hệ quả: Lab 10.4 và Lab10_Full là **cùng một app** trên thiết bị.
Cài bản này sẽ ghi đè bản kia. Nhãn trên launcher là "Lab10_4 Google Sign-In" để phân biệt.
Cài đè vẫn giữ dữ liệu của app, nên hai bản dùng chung một vùng lưu phiên Firebase trên máy.
Khi Lab10_Full có đăng nhập, phiên của bản này có thể làm bản kia mở thẳng vào màn hình sau đăng nhập (chưa thử).

## Đã cấu hình Firebase và Gradle thế nào?

- `android/app/google-services.json` và `lib/firebase_options.dart`: copy nguyên từ `lab10_full`.
- `android/settings.gradle.kts`: khai báo plugin `com.google.gms.google-services` 4.4.4, giống lab10_full (chạy với AGP 9.1.0).
- `android/app/build.gradle.kts`: áp dụng plugin đó.
  Plugin sinh resource `default_web_client_id` từ OAuth client web (`client_type: 3`) trong google-services.json.
  google_sign_in 7.x trên Android tự đọc resource này.
  Vì vậy `GoogleSignIn.instance.initialize()` không cần truyền `serverClientId`.
- Không bật core library desugaring: project này không dùng flutter_local_notifications.

## Gặp lỗi thì kiểm tra gì?

**DEVELOPER_ERROR, hoặc báo "Đã huỷ đăng nhập" ngay sau khi chọn tài khoản**

Package name hoặc SHA-1 chưa khớp Firebase console.
Theo README của google_sign_in_android, một số lỗi cấu hình cũng làm Credential Manager trả về "canceled".
App không phân biệt được trường hợp này với việc bạn tự bấm huỷ.
Xem logcat dòng `GoogleSignInException <mã lỗi>: <mô tả>` để biết lý do cụ thể.

Lấy SHA-1 debug bằng Command Prompt (keytool nằm trong `C:\Program Files\Android\Android Studio\jbr\bin` nếu chưa có trong PATH):

```bat
keytool -list -v -alias androiddebugkey -keystore "%USERPROFILE%\.android\debug.keystore" -storepass android -keypass android
```

Thêm SHA-1 (và SHA-256) vào Firebase console → Project settings → app `com.example.lab10_full`.
Sau đó tải lại `google-services.json` và build lại.

**`serverClientId must be provided on Android`**

google-services.json thiếu OAuth client web (`client_type: 3`), hoặc chưa áp dụng plugin `google-services`.

**Không hiện hộp chọn tài khoản, hoặc báo không có credential**

Thiết bị chưa có tài khoản Google, hoặc thiếu Google Play services.
Dùng emulator image Google Play hoặc máy thật.

## Cấu trúc thư mục

```
lib/
  main.dart                          khởi tạo Firebase + GoogleSignIn, MaterialApp mở SplashScreen
  firebase_options.dart              cấu hình Firebase (copy từ lab10_full)
  services/auth_service.dart         AuthService (google_sign_in 7.x + firebase_auth 7.x) + lỗi AuthFailure
  screens/splash_screen.dart         kiểm tra phiên rồi chuyển màn
  screens/sign_in_screen.dart        nút "Sign in with Google", đăng nhập xong sang Profile
  screens/profile_screen.dart        ảnh, tên, email (từ User của Firebase), nút Đăng xuất
test/
  sign_in_screen_test.dart           1 widget test: hiện nút "Sign in with Google"
HUONG_DAN_DOC.md                     hướng dẫn đọc code cho người mới học
android/
  settings.gradle.kts                khai báo plugin google-services 4.4.4
  app/build.gradle.kts               áp dụng plugin; namespace + applicationId = com.example.lab10_full
  app/google-services.json           cấu hình Firebase Android (copy từ lab10_full)
  app/src/main/kotlin/com/example/lab10_full/MainActivity.kt
```

## Đã kiểm thử những gì?

`flutter test`: 1 test, không cần Firebase hay thiết bị.
Test dựng `SignInScreen` và kiểm có một nút `FilledButton` mang chữ "Sign in with Google".
Đề Lab 10 không yêu cầu test, nên bài chỉ giữ một test ngắn làm mẫu.

Đăng nhập Google thật **không test tự động được**.
Nó cần tài khoản Google thật và hộp chọn tài khoản của hệ thống, nên phải thử tay trên thiết bị.

Bản code hiện tại đã qua `flutter analyze`, `flutter test` và `flutter build apk --debug`.
Bản này chưa cài lên emulator.
App dùng chung package `com.example.lab10_full` với Lab10_Full.
Cài vào sẽ ghi đè bản Lab10_Full đang có trên emulator.

Bản code **trước khi rút gọn** (cùng luồng màn hình) đã chạy thử trên emulator `pixel7_api36`
(image `google_apis`, chưa có tài khoản Google):

1. App mở được, logcat có `FirebaseApp initialization successful`, không có crash.
2. Splash chuyển sang SignInScreen vì chưa có phiên.
3. Bấm "Sign in with Google" thì hệ thống mở màn hình đăng nhập/thêm tài khoản của Google.
   Nghĩa là `initialize()` đã đọc được web client id (không gặp lỗi `serverClientId`).
4. Bấm Back để huỷ: app hiện SnackBar "Đã huỷ đăng nhập Google..." và nút bấm lại được.

Chưa kiểm chứng trên thiết bị: đăng nhập trọn vẹn tới ProfileScreen, đăng xuất, và tự đăng nhập lại khi mở app.
Ba bước này cần một tài khoản Google thật.

## Giới hạn đã biết

- Chỉ chạy trên Android: project chỉ có thư mục `android`.
- Dùng chung package với Lab10_Full, nên cài app này sẽ ghi đè app kia.
- Chưa thử trọn vẹn đăng nhập Google thật trên máy này: emulator `pixel7_api36` dùng image `google_apis` (không có Play Store) và chưa có tài khoản Google.
- Lúc build, Flutter cảnh báo firebase_auth và firebase_core còn dùng Kotlin Gradle Plugin. Hiện vẫn build được; bản Flutter sau có thể không build được cho tới khi plugin cập nhật.
- Bản release đang ký bằng debug key (mặc định của template). Đổi sang key release thật thì phải thêm SHA-1 của key đó vào Firebase.
- Nếu chính `FirebaseAuth.signOut()` lỗi (rất hiếm), app ở lại Profile và chỉ ghi lỗi ra console, chưa hiện SnackBar.
