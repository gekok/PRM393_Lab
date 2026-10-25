# Hướng dẫn đọc code – Lab 10.4 Firebase Google Sign-In

## Bài này làm gì?

App cho đăng nhập bằng tài khoản Google, thông qua Firebase Authentication.
Đăng nhập xong, app hiện ảnh, tên và email.
Bấm **Đăng xuất** thì app thoát cả Firebase lẫn Google, rồi quay về màn đăng nhập.

Cách chạy, cấu hình Firebase và cách xử lý lỗi nằm trong `README.md`.
File này chỉ giúp bạn đọc code.

## Nên đọc file theo thứ tự nào?

```
1. lib/main.dart
2. lib/screens/splash_screen.dart
3. lib/screens/sign_in_screen.dart
4. lib/services/auth_service.dart
5. lib/screens/profile_screen.dart
6. test/sign_in_screen_test.dart
```

Thứ tự này đi theo đường của người dùng: mở app → màn chờ → đăng nhập → hồ sơ.
`auth_service.dart` đứng thứ 4.
Đọc xong nút đăng nhập, bạn sẽ muốn biết bấm nút thì chuyện gì xảy ra.
Test đọc cuối cùng, vì nó không chạy khi mở app.

`lib/firebase_options.dart` không cần đọc kỹ.
File này do công cụ FlutterFire CLI sinh ra, chỉ chứa khóa cấu hình Firebase.

## Mỗi file làm gì?

**`lib/main.dart`** — điểm bắt đầu của app.

- Khởi tạo Firebase bằng `Firebase.initializeApp(...)`.
- Khởi tạo Google Sign-In bằng `GoogleSignIn.instance.initialize()`.
- Chạy `GoogleSignInApp`. Đây là một `StatelessWidget`.
- Hàm `build` của nó trả về `MaterialApp`, mở `SplashScreen` đầu tiên.

**`lib/screens/splash_screen.dart`** — màn chờ lúc mở app.

- Hỏi `AuthService` xem máy còn lưu phiên đăng nhập không.
- Còn phiên thì sang `ProfileScreen`. Không còn thì sang `SignInScreen`.

**`lib/screens/sign_in_screen.dart`** — màn đăng nhập.

- Có một nút "Sign in with Google".
- Bấm nút thì gọi `AuthService().signInWithGoogle()`.
- Thành công thì sang `ProfileScreen`. Lỗi thì hiện SnackBar.

**`lib/services/auth_service.dart`** — mọi việc nói chuyện với Firebase và Google nằm ở đây.

- `currentUser`: user của phiên còn lưu trên máy, hoặc `null`.
- `signInWithGoogle()`: chọn tài khoản Google, lấy idToken, rồi đăng nhập Firebase.
- `signOut()`: thoát Firebase trước, thoát Google sau.
- `AuthFailure`: lỗi đã được dịch thành câu tiếng Việt dễ hiểu.

Lớp `AuthService` không tự giữ dữ liệu.
Phiên đăng nhập nằm trong `FirebaseAuth.instance` và `GoogleSignIn.instance`.
Vì vậy màn hình nào tạo `AuthService()` mới cũng thấy cùng một phiên.

**`lib/screens/profile_screen.dart`** — màn hồ sơ.

- Nhận `User` của Firebase qua constructor, ví dụ `ProfileScreen(user: user)`.
- Hiện ảnh đại diện, tên, email lấy từ `User` đó.
- Nút "Đăng xuất" gọi `AuthService().signOut()`, rồi về `SignInScreen`.

**`test/sign_in_screen_test.dart`** — một test duy nhất.
Nó kiểm màn đăng nhập có một nút `FilledButton` mang chữ "Sign in with Google".

## Từ lúc mở app tới màn cuối, chuyện gì xảy ra?

### Lúc mở app

```
main()
↓  WidgetsFlutterBinding.ensureInitialized()
↓  Firebase.initializeApp(...)
↓  GoogleSignIn.instance.initialize()
↓  runApp(GoogleSignInApp)
SplashScreen
↓  đợi vẽ xong frame đầu tiên
↓  đọc AuthService().currentUser
├─ có user  → ProfileScreen   (tự đăng nhập lại = auto-login)
└─ null     → SignInScreen
```

### Khi bấm "Sign in with Google"

```
SignInScreen: khóa nút, hiện vòng xoay nhỏ
↓
AuthService().signInWithGoogle()
↓  GoogleSignIn.instance.authenticate()
↓     → hệ thống hiện hộp chọn tài khoản Google
↓  account.authentication.idToken
↓     → "vé" Google cấp, chứng minh bạn là chủ tài khoản đó
↓  GoogleAuthProvider.credential(idToken: ...)
↓     → gói vé vào một credential
↓  FirebaseAuth.instance.signInWithCredential(credential)
↓     → Firebase kiểm vé rồi đăng nhập
ProfileScreen(user: ...)
```

Nếu một bước bị lỗi (bấm huỷ, sai SHA-1, Firebase từ chối):

```
AuthService ném AuthFailure("câu lỗi tiếng Việt")
↓
SignInScreen bắt lỗi trong catch
↓
hiện SnackBar với câu lỗi đó
↓
finally: mở lại nút để bấm lại
```

Chỉ nhánh Firebase từ chối mới gọi `_signOutGoogle()` trước khi ném lỗi; hai nhánh hiếm (Google không trả `idToken`, Firebase không trả `user`) ném lỗi luôn, không thoát Google.

### Khi bấm "Đăng xuất"

```
ProfileScreen
↓  AuthService().signOut()
↓     FirebaseAuth.instance.signOut()   → lần mở app sau không tự đăng nhập nữa
↓     GoogleSignIn.instance.signOut()   → lần sau phải chọn lại tài khoản
SignInScreen
```

Mọi lần chuyển màn đều dùng `Navigator.pushReplacement`.
Vì vậy bấm Back không quay lại màn đã đi qua.

## Các khái niệm trong code nghĩa là gì?

**Hàm bất đồng bộ (`Future`, `async`, `await`)**
`Future` là kết quả "sẽ có sau", ví dụ chờ người dùng chọn tài khoản.
`await` (chỉ dùng trong hàm `async`) cho hàm đó tạm dừng chờ kết quả, còn giao diện vẫn chạy.

**Khởi tạo binding (`WidgetsFlutterBinding.ensureInitialized()`)**
Chuẩn bị phần nối giữa Dart và Android (binding) trước khi `runApp` chạy.
Plugin cần phần này, nên phải gọi trước Firebase và Google trong `main()`.

**Firebase, `firebase_options.dart`, `google-services.json`**
Bài này dùng Firebase Authentication, dịch vụ đăng nhập của Google.
Hai file cấu hình cho app biết nó thuộc project Firebase nào.

**Dấu vân tay khóa ký (SHA-1)**
"Dấu vân tay" của khóa dùng để ký app.
Google Sign-In chỉ chạy khi cặp package name + SHA-1 đã đăng ký trên Firebase console.

**Vé đăng nhập (idToken) và credential**
idToken là "vé" Google cấp, chứng minh bạn là chủ tài khoản vừa chọn.
`GoogleAuthProvider.credential(...)` gói vé đó lại để `signInWithCredential(...)` gửi cho Firebase kiểm.

**`User` của Firebase**
Đối tượng chứa thông tin người đã đăng nhập, ví dụ `displayName`, `email`, `photoURL`.
Tên, email, ảnh đều có thể là `null`.

**Thuộc tính tính toán (getter, từ khóa `get`)**
`User? get currentUser { ... }` trong `AuthService` là một getter: nơi dùng viết `AuthService().currentUser`, sau `currentUser` không có `()` như khi gọi hàm (cặp `()` trong `AuthService()` là để tạo đối tượng).
Mỗi lần đọc, thân getter chạy lại và trả về `FirebaseAuth.instance.currentUser` của lúc đó.

**Truyền dữ liệu qua constructor**
`ProfileScreen(user: user)` đưa `User` vào màn hồ sơ.
Bên trong, màn hình đọc lại bằng `user.displayName`, `user.email`, `user.photoURL`.

**Xử lý null (`??` và `?.`)**
`a ?? b` nghĩa là "nếu `a` null thì dùng `b`", ví dụ hiện chữ "(Chưa có email)".
`a?.b()` chỉ gọi `b()` khi `a` khác null.

**Toán tử ba ngôi (`điều kiện ? a : b`) và cách khóa nút**
`_loading ? null : _handleSignIn` nghĩa là "đang chờ thì `null`, không thì `_handleSignIn`".
Nút có `onPressed` là `null` thì bị khóa, không bấm được.

**`StatelessWidget` và `StatefulWidget`**
`StatelessWidget` chỉ vẽ theo dữ liệu nhận vào, ví dụ `ProfileScreen`.
`StatefulWidget` có dữ liệu tự đổi được (state), ví dụ `_loading` trong `SignInScreen`.

**`setState`**
Báo cho Flutter "state vừa đổi, vẽ lại đi".
Ví dụ `setState(() => _loading = true)` làm nút bị khóa và hiện vòng xoay.

**`initState` và `addPostFrameCallback`**
`initState` chạy một lần khi màn hình vừa được tạo, lúc đó chưa chuyển màn được.
Vì vậy `SplashScreen` dùng `addPostFrameCallback` để đợi vẽ xong frame đầu tiên rồi mới chuyển.

**Dấu gạch dưới `_`: tên riêng tư và tham số không dùng**
Tên bắt đầu bằng `_`, như `_loading`, `_handleSignIn`, `_signOutGoogle`, là riêng tư (private): chỉ code trong cùng file dùng được.
Dấu `_` đứng một mình trong `(_) { ... }` là tên đặt cho tham số mà code không dùng tới.

**`mounted` và `context.mounted`**
Trong lúc `await`, màn hình có thể đã bị đóng, nên code kiểm `mounted` trước khi dùng lại nó.
Trong `StatelessWidget` như `ProfileScreen` thì kiểm `context.mounted`.

**`Navigator.pushReplacement` và `MaterialPageRoute`**
`pushReplacement` mở màn mới và bỏ màn hiện tại khỏi lịch sử, nên Back không quay lại được.
`MaterialPageRoute(builder: ...)` cho biết màn mới là widget nào.

**`ScaffoldMessenger`, `SnackBar` và dấu `..`**
`SnackBar` là thanh thông báo nhỏ ở đáy màn hình.
Dấu `..` (cascade) gọi liên tiếp hai hàm trên cùng một đối tượng: ẩn SnackBar cũ, rồi hiện SnackBar mới.

**`try` / `on ... catch` / `finally` và `throw`**
`throw` ném lỗi ra ngoài, `on GoogleSignInException catch (error)` chỉ bắt đúng loại lỗi đó.
`finally` luôn chạy, kể cả khi có lỗi hay khi gặp `return` sớm.

**Lớp lỗi tự viết (`AuthFailure implements Exception`)**
`AuthFailure` ghi đè `toString()` để `'$error'` in ra đúng câu thông báo.
Không ghi đè thì SnackBar sẽ hiện `Instance of 'AuthFailure'`.

**In log (`debugPrint`)**
In một dòng ra console (logcat trên Android), ví dụ mã lỗi khi đăng nhập Google thất bại.
Lệnh này vẫn chạy ở bản release, nên đừng in token hay thông tin cá nhân của người dùng.

**Ảnh tròn (`CircleAvatar`) và ảnh từ mạng (`NetworkImage`)**
`CircleAvatar` là khung ảnh tròn, `NetworkImage` tải ảnh từ link.
Không có ảnh hoặc ảnh tải lỗi thì icon người nằm bên dưới sẽ hiện ra.
`CircleAvatar` báo lỗi (assert) nếu có `onForegroundImageError` mà không có ảnh, nên code viết `image == null ? null : (error, stackTrace) {}`.
Hàm rỗng `{}` nghĩa là "nhận lỗi tải ảnh rồi bỏ qua", để Flutter không in lỗi ra console.

**Sao chép kiểu chữ rồi đổi một phần (`copyWith`)**
`theme.textTheme.bodyMedium?.copyWith(color: ...)` lấy kiểu chữ có sẵn của theme, tạo bản sao chỉ đổi màu; bản gốc giữ nguyên.
Có `?.` vì `bodyMedium` có thể là `null`; khi đó cả biểu thức ra `null` và `Text` dùng kiểu chữ mặc định.

**Hằng số (`const`)**
Giá trị `const` được tạo sẵn lúc biên dịch và dùng chung, ví dụ `const avatarRadius = 48.0`.
Widget `const` không phải dựng lại (rebuild) khi màn hình cha vẽ lại.

**Widget test (`testWidgets`, `pumpWidget`, `find`, `expect`)**
`pumpWidget` dựng màn hình trong môi trường test, không cần điện thoại.
`find.widgetWithText(FilledButton, '...')` tìm nút có chữ đó, `expect(..., findsOneWidget)` kiểm có đúng một nút.
