# Hướng dẫn đọc code – Lab10_Full

## Bài này làm gì?

Lab10_Full gộp 5 bài con thành một app hoàn chỉnh.

- Mở app: màn chờ `AuthGate` xem máy còn phiên đăng nhập không, rồi vào Home hoặc Login.
- Màn Login có hai cách đăng nhập: tài khoản DummyJSON (`emilys` / `emilyspass`) và tài khoản Google.
- Đăng nhập xong bằng cách nào cũng hiện thông báo "Đăng nhập thành công", rồi vào Home.
- Home hiện tên và email (Google), hoặc username (DummyJSON).
- Bấm Logout: app xóa token, thoát Firebase và Google, rồi về Login.

Cách chạy, tài khoản test và cấu hình Android nằm trong `README.md`.
File này chỉ giúp bạn đọc code.

## Phần nào lấy từ bài con nào?

```
Form đăng nhập DummyJSON, khung lỗi đỏ, vòng xoay  ← Lab 10.2 + 10.3
Lưu token, màn chờ, Logout xóa token              ← Lab 10.3
Đăng nhập Google, đọc phiên Firebase, thoát       ← Lab 10.4
Thông báo sau khi đăng nhập                       ← Lab 10.5
```

Code chép từ bài con được giữ gần như nguyên.
Tên lớp và tên file so với bài con:

```
SplashScreen (10.3, 10.4)                  →  gộp thành AuthGate             (auth_gate.dart)
LoginScreen (10.3) + SignInScreen (10.4)   →  gộp thành LoginScreen          (login_screen.dart)
HomeScreen (10.3) + ProfileScreen (10.4)   →  gộp thành HomeScreen           (home_screen.dart)
AuthService (10.3)                         →  DummyJsonAuthService           (dummyjson_auth_service.dart)
AuthService (10.4)                         →  GoogleAuthService              (google_auth_service.dart)
NotificationService (10.5)                 →  giữ nguyên NotificationService (local_notification_service.dart)
```

Vì sao đặt tên như vậy?

- `LoginScreen` và `HomeScreen` giữ đúng tên của 10.1–10.3, để cùng một màn mang cùng một tên ở 10.1–10.3 và bài full.
  Bản trước của bài full đặt là `LoginPage`/`HomePage` (file `login_page.dart`, `home_page.dart`); nay đã đổi lại cho khớp.
- `AuthGate` giữ tên riêng vì việc chính của nó là điều hướng: đọc phiên rồi chọn Home hay Login.
  Giao diện của nó chỉ có icon ổ khóa và vòng xoay chờ.
- Hai bài 10.3 và 10.4 đều có lớp tên `AuthService`, gộp vào một app thì trùng tên.
  Vì vậy mỗi lớp được đổi tên theo việc nó làm.
- File thông báo đổi tên, nhưng lớp bên trong vẫn là `NotificationService` (xem mục `local_notification_service.dart` bên dưới).

Ba phần chỉ có ở bài full:

- Khóa `authUsernameKey`: lưu username DummyJSON, để Home còn tên sau khi tự đăng nhập.
- Hàm `_onLoginSuccess` trong `login_screen.dart`: bước chung sau khi đăng nhập thành công.
- `HomeScreen` nhận một trong hai loại dữ liệu: `googleUser` hoặc `username`.

## Nên đọc file theo thứ tự nào?

Đọc theo đường đi của người dùng: mở app → màn chờ → đăng nhập → Home.

```
1. lib/main.dart
2. lib/screens/auth_gate.dart
3. lib/services/auth_token_key.dart
4. lib/screens/login_screen.dart
5. lib/services/dummyjson_auth_service.dart
6. lib/services/google_auth_service.dart
7. lib/services/local_notification_service.dart
8. lib/screens/home_screen.dart
9. test/widget_test.dart
```

Phần cấu hình Android đọc sau:

```
10. android/app/src/main/AndroidManifest.xml
11. android/app/src/main/res/drawable/ic_stat_notification.xml
12. android/app/src/main/res/raw/keep.xml
```

`lib/firebase_options.dart` không cần đọc kỹ.
File này do FlutterFire CLI sinh ra, chỉ chứa cấu hình Firebase.

## Mỗi file làm gì?

**`lib/main.dart`** — điểm bắt đầu của app.

- Khởi tạo Firebase, rồi Google Sign-In, rồi plugin thông báo.
- Chạy `Lab10App`. Hàm `build` của nó trả về `MaterialApp`, mở `AuthGate` đầu tiên.

**`lib/screens/auth_gate.dart`** — màn chờ (Splash).

- Đọc token và username trong SharedPreferences.
- Đọc phiên Google còn lưu bằng `GoogleAuthService().currentUser`.
- Có token thì vào Home với username. Có phiên Google thì vào Home với `User` đó. Không có gì thì sang Login.

**`lib/services/auth_token_key.dart`** — hai hằng số tên khóa.

- `authTokenKey = 'auth_token'`: khóa lưu token, giống bài 10.3.
- `authUsernameKey = 'auth_username'`: khóa lưu username, mới thêm ở bài này.

**`lib/screens/login_screen.dart`** — màn đăng nhập.

- Form Username + Password, nút Login, khung báo lỗi màu đỏ (giống 10.3).
- Nút "Sign in with Google" (giống 10.4).
- `_submit()`: đăng nhập DummyJSON, lưu username rồi lưu token.
- `_signInWithGoogle()`: đăng nhập Google. Firebase tự lưu phiên, nên không lưu gì thêm.
- `_onLoginSuccess()`: xin quyền, hiện thông báo, rồi thay màn Login bằng Home.
- `_buildErrorBox()`: dựng khung báo lỗi màu đỏ; `build()` chỉ gọi hàm này khi có `_errorMessage`.
  Giao diện khung giống 10.3. Bài 10.3 viết khối này thẳng trong `build()`, bài full tách ra vì `build()` ở đây dài hơn (có thêm nút Google).

**`lib/services/dummyjson_auth_service.dart`** — gọi API `POST https://dummyjson.com/auth/login`.

- Thành công trả về access token.
- Sai tài khoản, mất mạng, quá 10 giây, lỗi server: ném `AuthException` kèm câu lỗi dễ hiểu.

**`lib/services/google_auth_service.dart`** — mọi việc nói chuyện với Firebase và Google.

- `currentUser`: user của phiên còn lưu trên máy, hoặc `null`.
- `signInWithGoogle()`: chọn tài khoản Google, lấy idToken, rồi đăng nhập Firebase.
- `signOut()`: thoát Firebase trước, thoát Google sau.
- `AuthFailure`: lỗi đã dịch thành câu tiếng Việt.

**`lib/services/local_notification_service.dart`** — lớp `NotificationService`, chép từ bài 10.5.

- `init()`: khởi tạo plugin và tạo kênh thông báo. Gọi một lần trong `main()`.
- `requestPermission()`: xin quyền thông báo, trả về `true` nếu được phép.
- `showLoginSuccess()`: hiện thông báo "Đăng nhập thành công" / "Chào mừng bạn quay lại!".

Tên file là `local_notification_service.dart`, còn tên lớp vẫn là `NotificationService`.
Slide Module 10 (phần ghi chú) gọi lớp này là `NotificationService`, nên bài giữ tên lớp của 10.5.

**`lib/screens/home_screen.dart`** — màn sau khi đăng nhập.

- Nhận `googleUser` (đăng nhập Google) hoặc `username` (đăng nhập DummyJSON).
- Google: hiện tên và email. DummyJSON: hiện username.
- Nút Logout: xóa token và username, thoát Firebase và Google, rồi về Login.

**`test/widget_test.dart`** — một test duy nhất.
Nó dựng `LoginScreen`, rồi kiểm có ô Username, ô Password, nút Login và nút "Sign in with Google".

**`AndroidManifest.xml`** — khai báo quyền `INTERNET` và `POST_NOTIFICATIONS`, đặt `android:allowBackup="false"`.

**`ic_stat_notification.xml`** — icon chuông trắng hiện trên thanh trạng thái.
**`keep.xml`** — giữ icon đó lại khi build release. Cả hai chép từ bài 10.5.

## Từ lúc mở app tới lúc đăng xuất, chuyện gì xảy ra?

### Lúc mở app

```
main()
↓  WidgetsFlutterBinding.ensureInitialized()
↓  Firebase.initializeApp(...)
↓  GoogleSignIn.instance.initialize()
↓  NotificationService().init()
↓  runApp(Lab10App)
AuthGate (màn chờ)
↓  đọc token, username trong SharedPreferences
↓  đọc GoogleAuthService().currentUser
├─ có token         → HomeScreen(username: ...)
├─ có phiên Google  → HomeScreen(googleUser: ...)
└─ không có gì      → LoginScreen
```

### Khi đăng nhập bằng DummyJSON

```
bấm Login → _submit()
↓  kiểm form: username không rỗng, password ít nhất 6 ký tự
↓  DummyJsonAuthService().login(...)  → token
↓  lưu username, rồi lưu token (SharedPreferences)
↓  _onLoginSuccess(HomeScreen(username: ...))
```

Vì sao lưu username trước, token sau cùng?
AuthGate chỉ nhìn token để quyết định "đã đăng nhập".
Nếu lệnh ghi username bị lỗi, token chưa được ghi, nên lần mở sau app không vào Home với username rỗng.

### Khi đăng nhập bằng Google

```
bấm Sign in with Google → _signInWithGoogle()
↓  GoogleAuthService().signInWithGoogle()
↓     hộp chọn tài khoản Google → idToken → credential → Firebase
↓  _onLoginSuccess(HomeScreen(googleUser: user))
```

Firebase tự lưu phiên trên máy, nên nhánh này không lưu token.

### Bước chung: thông báo rồi vào Home

```
_onLoginSuccess(home)
↓  NotificationService().requestPermission()
↓     Android 13+, lần đầu: hộp thoại "Allow ... to send you notifications?"
├─ được phép   → showLoginSuccess() → thông báo "Đăng nhập thành công"
└─ bị từ chối  → bỏ qua thông báo
↓
pushReplacement sang HomeScreen
```

Lỗi của phần thông báo được bắt ngay trong `_onLoginSuccess`.
Lúc đó đăng nhập đã xong, nên app vẫn vào Home.

### Khi đăng nhập lỗi

```
AuthException hoặc AuthFailure (kèm câu lỗi dễ hiểu)
↓
_showError(): tắt hai cờ chờ, ghi _errorMessage
↓
build() vẽ lại màn
├─ _buildErrorBox() hiện khung đỏ với câu lỗi
└─ hai cờ đã tắt nên isBusy = false, hai nút mở lại để thử lần nữa
```

Với Google, chỉ nhánh Firebase từ chối mới gọi `_signOutGoogle()` trước khi ném lỗi; hai nhánh hiếm (Google không trả `idToken`, Firebase không trả `user`) ném lỗi luôn, không thoát Google.

### Khi bấm Logout

```
HomeScreen._logout()
↓  prefs.remove(authTokenKey), prefs.remove(authUsernameKey)
↓  GoogleAuthService().signOut()
↓     FirebaseAuth.instance.signOut()
↓     GoogleSignIn.instance.signOut()
↓  pushAndRemoveUntil về LoginScreen, xóa hết các màn cũ
```

Đăng nhập bằng DummyJSON thì không có phiên Google.
Logout vẫn gọi `signOut()`, vì đề yêu cầu thoát cả Firebase và Google.

## Các khái niệm trong code nghĩa là gì?

**Hàm bất đồng bộ (`Future`, `async`, `await`)**
`Future` là kết quả "sẽ có sau", ví dụ chờ server trả token.
`await` cho hàm `async` tạm dừng chờ kết quả, còn giao diện vẫn chạy.

**Khởi tạo binding (`WidgetsFlutterBinding.ensureInitialized()`)**
Chuẩn bị phần nối giữa Dart và Android trước khi `runApp` chạy.
Firebase, Google Sign-In và plugin thông báo đều cần nó.

**Lưu dữ liệu nhỏ trên máy (SharedPreferences)**
Một cuốn sổ nhỏ trong máy, lưu theo cặp khóa – giá trị (key-value), tắt app vẫn còn.
`setString` ghi, `getString` đọc (chưa ghi thì ra `null`), `remove` xóa.

**Hằng số dùng chung (`const`)**
`authTokenKey` và `authUsernameKey` khai báo tên khóa đúng một lần.
Gõ sai tên hằng số thì Dart báo lỗi ngay; gõ sai chuỗi `'auth_token'` thì không ai báo.

**Phiên đăng nhập (session) và tự đăng nhập (auto-login)**
Phiên là trạng thái "đã đăng nhập": token đã lưu (DummyJSON) hoặc user Firebase còn lưu (Google).
Auto-login nghĩa là mở app thấy còn phiên thì bỏ qua màn Login.

**Firebase Authentication**
Dịch vụ đăng nhập của Google: app gửi "vé" của Google cho Firebase kiểm, Firebase trả về `User`.
Firebase tự lưu phiên trên máy, nên lần mở app sau `currentUser` vẫn còn.

**Vé đăng nhập (idToken) và credential**
idToken là "vé" Google cấp, chứng minh bạn là chủ tài khoản vừa chọn.
`GoogleAuthProvider.credential(...)` gói vé lại để `signInWithCredential(...)` gửi cho Firebase.

**`User` của Firebase**
Đối tượng chứa thông tin người đã đăng nhập, ví dụ `displayName`, `email`.
Hai trường này có thể là `null`, nên Home có chữ thay thế như "(No email)".

**Đối tượng dùng chung (singleton)**
Lớp chỉ có đúng một đối tượng cho cả app, ví dụ `FirebaseAuth.instance`, `GoogleSignIn.instance`, `FlutterLocalNotificationsPlugin()`.
Vì vậy `GoogleAuthService()` hay `NotificationService()` tạo mới ở màn nào cũng dùng chung một phiên, một plugin.

**Thuộc tính tính toán (getter, từ khóa `get`)**
`User? get currentUser { ... }` trong `GoogleAuthService` là một getter: nơi dùng viết `GoogleAuthService().currentUser`, sau `currentUser` không có `()` như khi gọi hàm (cặp `()` trong `GoogleAuthService()` là để tạo đối tượng).
`get _androidPlugin` trong `local_notification_service.dart` cũng vậy; mỗi lần đọc, thân getter chạy lại và trả về giá trị của lúc đó.

**Thông báo cục bộ (local notification), kênh (channel), quyền `POST_NOTIFICATIONS`**
App tự tạo thông báo ngay trên máy, không cần server.
Từ Android 8 mỗi thông báo thuộc một kênh; từ Android 13 app phải xin quyền lúc chạy mới hiện được thông báo.

**Hằng số của lớp (`static const`)**
`local_notification_service.dart` gom id, tên kênh, icon vào các hằng `static const` ở đầu lớp.
`static` nghĩa là hằng thuộc về lớp, dùng chung cho mọi `NotificationService()`; `const` nghĩa là cố định ngay lúc biên dịch.

**Mức độ quan trọng (`Importance`) và mức ưu tiên (`Priority`)**
`Importance.high` làm thông báo bật xuống đầu màn hình (heads-up); từ Android 8, mức này gắn với kênh.
`Priority.high` là cách đặt tương tự cho Android 7, đời chưa có kênh.

**Lấy phần riêng cho Android (`resolvePlatformSpecificImplementation<...>()`)**
Hàm này lấy phần riêng cho Android của plugin; tên trong `< >` cho biết lấy phần nền tảng nào.
Kết quả là `null` khi app không chạy trên Android.

**Không cho Android sao lưu (`android:allowBackup="false"`)**
Nếu Android sao lưu dữ liệu app, cài lại app có thể khôi phục token cũ.
Khi đó app vào thẳng Home dù trước đó đã Logout.

**`StatefulWidget`, `StatelessWidget`, `setState`**
`LoginScreen` có dữ liệu tự đổi được (state), ví dụ `_isLoading`; `setState(...)` đổi dữ liệu đó rồi vẽ lại màn.
`HomeScreen` chỉ vẽ theo dữ liệu nhận vào, nên là `StatelessWidget`.

**Hai cờ chờ (`_isLoading`, `_isGoogleLoading`)**
Mỗi nút một cờ, nên vòng xoay hiện đúng ở nút vừa bấm.
`isBusy = _isLoading || _isGoogleLoading` khóa cả hai nút trong lúc chờ, tránh đăng nhập hai lần cùng lúc.

**`initState`**
Chạy một lần khi màn vừa được tạo. `AuthGate` gọi `_routeBySession()` ở đây.
`initState` chạy giữa lúc Flutter đang dựng frame đầu, nên chưa chuyển màn ngay được; vì vậy bài 10.4 phải bọc lệnh chuyển màn trong `addPostFrameCallback`.
`AuthGate` không cần: `_routeBySession()` `await` đọc SharedPreferences trước, mà code sau `await` luôn chạy sau khi frame đang dựng đã xong.

**Bài này không dùng `FutureBuilder`**
`FutureBuilder` là widget tự vẽ lại khi một `Future` có kết quả.
`AuthGate` làm theo cách của bài 10.3: đọc phiên trong `initState`, đọc xong thì tự chuyển màn.

**`mounted` và `context.mounted`**
Trong lúc `await`, màn hình có thể đã bị đóng.
Code kiểm `mounted` (trong State) hoặc `context.mounted` (trong StatelessWidget) trước khi dùng lại màn đó.

**Chuyển màn (Navigator)**
`pushReplacement` thay màn hiện tại, nên Back không quay lại màn chờ hay Login.
`pushAndRemoveUntil(..., (route) => false)` xóa hết các màn cũ khi Logout, nên Back không quay lại Home.

**Form và kiểm dữ liệu nhập (`Form`, `TextFormField`, `validator`)**
`validator` trả về câu lỗi, hoặc `null` nếu hợp lệ.
`_formKey.currentState!.validate()` chạy mọi validator trước khi gọi API.
`_formKey` (kiểu `GlobalKey<FormState>`) được gắn vào `Form(key: _formKey)`, nhờ đó code nằm ngoài form vẫn gọi được `validate()`.

**Đọc chữ trong ô nhập (`TextEditingController`) và dọn dẹp (`dispose`)**
Mỗi ô nhập có một controller; `_usernameController.text` đọc chữ người dùng đã gõ.
Controller giữ tài nguyên, nên hàm `dispose()` của màn gọi `.dispose()` cho từng controller khi màn bị đóng.

**Bắt lỗi (`try`, `on ... catch`, `catch`, `throw`)**
`throw` ném lỗi ra ngoài; `on AuthException catch (e)` chỉ bắt đúng loại đó, `catch` không có `on` thì bắt mọi lỗi.
`AuthException` (DummyJSON) và `AuthFailure` (Google) là hai lớp lỗi tự viết, giữ nguyên từ bài con.

**Gọi API bằng gói `http` (`import ... as http`, `http.post`, `.timeout`)**
`as http` đặt tiền tố cho gói, nên code viết `http.post(...)`, `http.Response`: đọc là biết hàm hay lớp đó đến từ gói nào.
`.timeout(const Duration(seconds: 10))` ném `TimeoutException` nếu quá 10 giây server chưa trả lời.

**Chuỗi JSON (`jsonEncode`, `jsonDecode`) và mã trạng thái (`statusCode`)**
`jsonEncode({...})` biến Map thành chuỗi JSON để gửi đi; `jsonDecode(response.body)` làm ngược lại với chuỗi server trả về.
`response.statusCode` là mã HTTP: `200` là thành công, `400` hoặc `401` là server từ chối tài khoản.

**Kiểu `dynamic` và `as String`**
`jsonDecode` không biết trước JSON chứa gì, nên trả về kiểu `dynamic`: "kiểu gì cũng được, chạy rồi mới biết".
`return json['accessToken'] as String;` nói rõ "chỗ này phải là chuỗi". Thiếu trường này hoặc sai kiểu thì `as` ném lỗi, và `LoginScreen` bắt nó ở nhánh `catch (_)`.
`as` ở đây là ép kiểu (type cast), khác `as http` ở dòng import (đặt tiền tố cho gói).

**Xử lý null (`String?`, `??`, `!`)**
`String?` là biến có thể chứa chuỗi hoặc `null`; `a ?? b` nghĩa là "nếu `a` null thì dùng `b`".
`!` khẳng định "chỗ này chắc chắn không null"; nếu thật ra là null, app báo lỗi ngay.

**Chép sang biến cục bộ để Dart biết "không null"**
`HomeScreen` viết `final user = googleUser;` rồi mới kiểm `if (user != null)`.
`local_notification_service.dart` cũng làm vậy: `final androidPlugin = _androidPlugin;` rồi mới kiểm `== null`.
Dart không tự hiểu "đã kiểm, không null" với getter hay với trường (field) public như `googleUser`; chép sang biến cục bộ thì hiểu.

**Khai báo `final` trước, gán sau**
`final Widget next;` trong `auth_gate.dart` chưa có giá trị; mỗi nhánh `if`/`else` gán cho nó đúng một lần.
Dart kiểm việc này lúc biên dịch: dùng trước khi gán, hoặc gán hai lần, đều báo lỗi. Cùng kiểu: `final Widget info;` (`home_screen.dart`), `final http.Response response;` (`dummyjson_auth_service.dart`).

**Toán tử ba ngôi và cách khóa nút**
`isBusy ? null : _submit` nghĩa là "đang chờ thì `null`, không thì `_submit`".
Nút có `onPressed` là `null` thì bị khóa, không bấm được.

**`if` bên trong danh sách widget (collection if)**
`if (_errorMessage != null) _buildErrorBox(_errorMessage!),` nằm trong `children: [...]`: chỉ khi có lỗi thì khung lỗi mới được thêm vào danh sách.
Không có lỗi thì danh sách không có phần tử đó, chứ không phải một khung rỗng.

**Truyền một màn (widget) vào hàm làm tham số**
`_onLoginSuccess(HomeScreen(username: username))` tạo đối tượng màn Home rồi đưa cho hàm chung; màn chỉ được vẽ sau khi hàm `pushReplacement` tới nó.
Nhờ vậy hai cách đăng nhập dùng chung một hàm `_onLoginSuccess`, mỗi cách tự chọn dữ liệu cho Home.

**Dấu gạch dưới `_` ở đầu tên**
Tên như `_submit`, `_logout` là riêng tư (private), chỉ code trong cùng file dùng được.
Riêng `_` đứng một mình, như `(_) => next` hay `catch (_)`, là tên đặt cho tham số không dùng tới, không phải tên riêng tư.

**In log (`debugPrint`)**
In một dòng ra console (logcat trên Android), ví dụ lỗi khi hiện thông báo.
Lệnh này vẫn chạy ở bản release, nên không in token hay thông tin cá nhân.

**Widget test (`testWidgets`, `pumpWidget`, `find`, `expect`)**
`pumpWidget` dựng màn hình trong môi trường test, không cần điện thoại.
`find.widgetWithText(...)` tìm widget có chữ đó; `expect(..., findsOneWidget)` kiểm có đúng một cái.

## Tự thử bằng tay thế nào?

"Tắt hẳn app" nghĩa là vuốt app khỏi danh sách ứng dụng gần đây, không chỉ bấm nút Home.

Đăng nhập DummyJSON:

1. Mở app lần đầu: thấy Login.
2. Nhập `emilys` và mật khẩu sai (vẫn đủ 6 ký tự): khung đỏ hiện `Invalid credentials`.
3. Nhập `emilys` / `emilyspass`. Android 13+ hỏi quyền thông báo ở lần đầu. Thông báo hiện, rồi vào Home với Username `emilys`.
4. Tắt hẳn app rồi mở lại: vào thẳng Home.
5. Bấm Logout: về Login. Tắt hẳn rồi mở lại: vẫn là Login.

Đăng nhập Google (cần thiết bị có Google Play và đã đăng nhập tài khoản Google):

6. Bấm "Sign in with Google", chọn tài khoản: thông báo hiện, rồi vào Home với tên và email.
7. Tắt hẳn app rồi mở lại: vào thẳng Home.
8. Bấm Logout: về Login. Tắt hẳn rồi mở lại: vẫn là Login.
