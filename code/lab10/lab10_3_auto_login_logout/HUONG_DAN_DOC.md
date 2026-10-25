# Hướng dẫn đọc code — Lab 10.3 Auto Login & Logout

## Bài này làm gì?

Lab 10.2 cộng thêm khả năng "nhớ đăng nhập".

- Đăng nhập xong, app lưu token vào bộ nhớ của máy.
- Lần sau mở app: có token thì vào thẳng Home, không phải đăng nhập lại.
- Bấm Logout: app xóa token rồi về Login. Mở lại app thì phải đăng nhập lại.

Tài khoản test: `emilys` / `emilyspass`.

## Khác gì Lab 10.2?

- Có thêm màn chờ `SplashScreen` làm màn đầu tiên. Nó quyết định đi Home hay Login.
- Hàm `login()` của `AuthService` trả về `String` token. Bản 10.2 trả về `AuthUser`. Bài này chỉ cần token để lưu, nên không còn thư mục `models/`.
- `LoginScreen` lưu token sau khi đăng nhập đúng.
- `HomeScreen` chỉ hiện token, vì lúc tự đăng nhập app chỉ có token đã lưu. Nút Logout xóa token.
- Tên khóa lưu token được khai báo một lần, là hằng số `authTokenKey` trong `lib/services/auth_token_key.dart`.

## Token đi qua những file nào?

Token được lưu dưới khóa `'auth_token'`.
Chuỗi này chỉ được viết một lần, trong `lib/services/auth_token_key.dart`:

```
const String authTokenKey = 'auth_token';
```

Ba màn dùng chung hằng số `authTokenKey`:

```
login_screen.dart   ghi   prefs.setString(authTokenKey, token)
↓
splash_screen.dart  đọc   prefs.getString(authTokenKey)
↓
home_screen.dart    xóa   prefs.remove(authTokenKey)
```

Vì sao không gõ thẳng chuỗi `'auth_token'` ở cả ba file?

- Gõ sai một chữ trong chuỗi: Dart không báo gì, auto-login hoặc Logout hỏng âm thầm.
- Gõ sai tên hằng số `authTokenKey`: Dart báo lỗi ngay lúc biên dịch.

## Nên đọc file theo thứ tự nào?

1. `lib/main.dart` — điểm bắt đầu. Mở `SplashScreen` đầu tiên.
2. `lib/services/auth_token_key.dart` — chỉ một dòng: hằng số `authTokenKey`, tên khóa lưu token.
3. `lib/screens/splash_screen.dart` — đọc token đã lưu, chọn sang Home hoặc Login.
4. `lib/services/auth_service.dart` — gọi API DummyJSON như Lab 10.2, trả về token.
5. `lib/screens/login_screen.dart` — form đăng nhập như Lab 10.2, thêm bước lưu token.
6. `lib/screens/home_screen.dart` — hiện token rút gọn. Nút Logout xóa token rồi về Login.
7. `test/widget_test.dart` — một bài test: có token thì vào thẳng Home, bấm Logout thì token bị xóa và về Login.

## Đọc `login_screen.dart` thế nào cho dễ?

Chia file thành 5 phần, đọc từ trên xuống:

1. Các biến của màn hình: `_formKey`, hai controller, `_authService`, `_isLoading`, `_errorMessage`.
2. Hai hàm kiểm tra ô nhập: `_validateUsername`, `_validatePassword`.
3. Hàm `_showError()`: tắt vòng xoay, ghi câu lỗi vào `_errorMessage`.
4. Hàm `_submit()`: chạy khi bấm Login. Gọi `login()`, lưu token vào `SharedPreferences`, rồi sang Home.
5. Hàm `build()`: vẽ giao diện, có khung lỗi đỏ phía trên nút Login.

## App chạy thế nào?

**Kịch bản 1 — mở app lần đầu, chưa có token**

```
main() → Lab10App → SplashScreen
↓
initState() gọi _routeBySession()
↓
SharedPreferences.getInstance() rồi getString(authTokenKey) → null
↓
pushReplacement sang LoginScreen
↓
nhập emilys / emilyspass, bấm Login → _submit() → _authService.login() → token
↓
prefs.setString(authTokenKey, token)
↓
pushReplacement sang HomeScreen(token: token)
```

**Kịch bản 2 — tắt hẳn app rồi mở lại, đã có token**

```
SplashScreen → getString(authTokenKey) → có token
↓
pushReplacement thẳng sang HomeScreen, không đi qua Login
```

**Kịch bản 3 — bấm Logout**

```
_logout() → prefs.remove(authTokenKey)
↓
pushAndRemoveUntil về LoginScreen, xóa hết các màn cũ
↓
lần mở app sau: Splash không thấy token → Login
```

## Các khái niệm xuất hiện trong bài

**Lưu dữ liệu nhỏ trên máy (SharedPreferences)**
Một cuốn sổ nhỏ trong máy, lưu theo cặp khóa – giá trị (key-value).
Dữ liệu vẫn còn sau khi tắt app.
`SharedPreferences.getInstance()` mở cuốn sổ. `setString` ghi, `getString` đọc, `remove` xóa.
`getString` trả về `null` khi chưa từng ghi khóa đó.

**Hằng số dùng chung (`const`)**
`const String authTokenKey = 'auth_token';` khai báo một giá trị cố định, không bao giờ đổi.
Nó nằm ngoài mọi class, nên file nào `import` file đó đều dùng được.

**Không cho Android sao lưu (`android:allowBackup="false"`)**
Android có thể tự sao lưu dữ liệu app, rồi khôi phục khi cài lại app.
Nếu bản sao lưu còn token, cài lại app sẽ vào thẳng Home dù trước đó đã Logout.
Vì vậy `android/app/src/main/AndroidManifest.xml` đặt `android:allowBackup="false"`.

**Phiên đăng nhập (session) và tự đăng nhập (auto-login)**
Phiên đăng nhập là trạng thái "đã đăng nhập", ở đây chính là token đang được lưu.
Auto-login nghĩa là mở app thấy token thì bỏ qua màn Login.

**Màn chờ (SplashScreen) và `initState`**
`initState` chạy đúng một lần khi màn được tạo.
Splash gọi `_routeBySession()` ở đây để đọc token ngay khi app mở.
Trong lúc đọc, màn hiện icon ổ khóa và vòng xoay.

**Ký hiệu null (`String?`, `??`, `!`)**
`String? token` nghĩa là biến có thể chứa chuỗi hoặc `null`.
Splash coi `null`, chuỗi rỗng và chuỗi toàn khoảng trắng đều là "chưa đăng nhập".
`a ?? b` nghĩa là "dùng `a`, nếu `a` là null thì dùng `b`". Ví dụ `(value ?? '').trim()` trong validator.
Dấu `!` (như `_formKey.currentState!`) khẳng định "chỗ này chắc chắn không null". Nếu thật ra là null, app báo lỗi ngay.

**Dart tự hiểu biến đã khác `null` (type promotion)**
Trong `login_screen.dart`, dòng `if (_errorMessage != null)` vừa kiểm xong, nhưng bên dưới vẫn phải viết `_errorMessage!`.
`_errorMessage` là biến của class và không `final`. Chỗ khác có thể gán lại nó, nên Dart không tự hiểu nó khác `null`.
Dart chỉ tự hiểu biến của class khi nó vừa `final` vừa có `_` ở đầu tên.
Trong `splash_screen.dart`, `token` là biến cục bộ của hàm `_routeBySession()`.
Sau `token != null && ...`, Dart tự hiểu `token` khác `null`, nên `HomeScreen(token: token)` không cần `!`.

**Dấu gạch dưới `_` ở đầu tên**
Tên bắt đầu bằng `_` (như `_routeBySession`, `_logout`, `_authService`) là riêng tư (private).
Chỉ code trong cùng file mới dùng được nó.

**`_` đứng một mình: bỏ qua tham số hoặc lỗi**
Khác với `_` ở đầu tên, một dấu `_` đứng riêng nghĩa là "có nhận nhưng không dùng".
`onFieldSubmitted: (_) => _submit()`: Flutter truyền vào chữ trong ô, nhưng `_submit()` không cần.
`builder: (_) => ...`: bỏ qua `context` mà Flutter truyền vào.
`catch (_)`: bắt lỗi nhưng không cần đọc lỗi đó là gì, như ở Splash và Login.

**`try / catch` ở Splash**
Nếu đọc bộ nhớ bị lỗi, `catch` coi như chưa đăng nhập và đưa về Login.
Nhờ vậy app không bị kẹt mãi ở màn chờ.

**`context.mounted` trong `HomeScreen`**
`HomeScreen` là StatelessWidget nên không có biến `mounted` như State.
Sau `await prefs.remove(...)`, code kiểm tra `context.mounted` trước khi chuyển màn.

**Chuyển màn (Navigator)**
`pushReplacement` thay màn hiện tại, nên Back không quay lại Splash hay Login.
`pushAndRemoveUntil(..., (route) => false)` xóa hết các màn cũ khi Logout, nên Back không quay lại Home.

**Gọi API, `AuthException`, `try/catch` ở Login**
Giống Lab 10.2: sai tài khoản, mất mạng, quá 10 giây đều hiện câu lỗi dễ hiểu trong khung đỏ.
Các chi tiết `import ... as http`, `final http.Response response;` và thứ tự các nhánh `on` được giải thích trong `HUONG_DAN_DOC.md` của Lab 10.2.

**Kiểu `dynamic` và `as String`**
`jsonDecode` không biết trước JSON chứa gì, nên trả về kiểu `dynamic`: "kiểu gì cũng được, chạy rồi mới biết".
`final json = jsonDecode(response.body);` không ghi kiểu, nên `json` có kiểu `dynamic`.
Server trả về một object JSON, nên lúc chạy `json` là một `Map<String, dynamic>`: khóa là chuỗi, giá trị là `dynamic`.
`return json['accessToken'] as String;` nói rõ "chỗ này phải là chuỗi". Thiếu trường này hoặc sai kiểu thì `as` ném lỗi, và `LoginScreen` bắt nó ở nhánh `catch (_)`.

**Khóa của Form (`GlobalKey<FormState>`)**
`_formKey` là chiếc chìa khóa gắn vào `Form(key: _formKey)`. Nhờ nó, `_submit()` gọi được `validate()` của Form.
`<FormState>` cho biết khóa này trỏ tới trạng thái (state) của một `Form`.
`_formKey.currentState` có kiểu `FormState?`: Form chưa có trên cây giao diện thì nó là `null`.
`_submit()` chỉ chạy khi bấm Login hoặc Enter trong ô mật khẩu, lúc đó Form chắc chắn đang hiện. Nên code viết `currentState!` để khẳng định nó khác `null`.

**`if` trong danh sách `children`**
Trong `children: [ ... ]` có thể đặt `if (điều kiện) widget`.
Điều kiện đúng thì widget đó có trong danh sách, sai thì bị bỏ qua như chưa từng viết.
`if (_errorMessage != null) Container(...)` chỉ vẽ khung lỗi đỏ khi có lỗi.

**Hai chuỗi đặt liền nhau**
Hai chuỗi viết trong dấu nháy, đặt sát nhau, được Dart tự nối thành một chuỗi, không cần dấu `+`.
Ví dụ câu báo mất mạng trong `auth_service.dart`, hay dòng chữ nhỏ dưới token ở `home_screen.dart`.
Bộ lint của project (`flutter_lints`) cũng khuyên viết vậy thay cho `+`.
Cách này chỉ dùng cho chuỗi trong dấu nháy. Ghép chuỗi với biến thì dùng `${}`.

**Giả lập bộ nhớ trong test (`SharedPreferences.setMockInitialValues`)**
Test không dùng ổ đĩa thật.
`setMockInitialValues({'auth_token': 'abc'})` giả vờ máy đã lưu sẵn token `abc`.
Test cố ý viết thẳng chuỗi `'auth_token'`: nếu ai đổi giá trị của `authTokenKey`, test sẽ báo đỏ.

## Các cú pháp nhỏ trong code nghĩa là gì?

- `final`: biến chỉ được gán một lần, gán xong không gán lại được. Ví dụ `final String token;` trong `HomeScreen`: màn nhận token lúc được tạo rồi giữ nguyên.
- `const` trước widget, như `const SizedBox(height: 24)`: widget được tạo sẵn lúc biên dịch, nên vẽ lại màn chỉ dùng lại chứ không tạo mới. Mọi giá trị bên trong phải biết ngay lúc biên dịch, `final` thôi là chưa đủ: `shortToken` tuy `final` nhưng chỉ có giá trị lúc chạy, nên `Text(shortToken)` trong `home_screen.dart` không thể `const`.
- `@override`: đánh dấu hàm viết lại (ghi đè) một hàm mà lớp cha đã khai báo sẵn, như `initState()`, `build()`, `dispose()`. Nhờ `@override`, gõ sai tên (vd `dispos()`) thì Dart cảnh báo ngay vì lớp cha không có hàm đó; thiếu `@override` thì `dispos()` chỉ là một hàm mới và Dart im lặng.
- `super.key`: nhận tham số `key` rồi chuyển thẳng cho lớp cha (`StatelessWidget`, `StatefulWidget`). Gần như widget nào cũng có dòng này.
- `required`: tham số đặt tên bắt buộc phải truyền. Gọi `HomeScreen()` mà thiếu `token` thì Dart báo lỗi ngay lúc biên dịch.
- `=>`: cách viết ngắn cho hàm chỉ có một biểu thức. `(route) => false` giống hệt `(route) { return false; }`.
- `${}`: chèn giá trị vào giữa chuỗi. `'${token.substring(0, 16)}...'` ghép 16 ký tự đầu của token với dấu `...`.
- `? :`: chọn một trong hai giá trị. `_isLoading ? null : _submit` nghĩa là đang chờ thì `null` (nút bị khóa), không thì `_submit`.
- `find.*`: trong test, tìm widget theo loại (`find.byType(HomeScreen)`) hoặc theo chữ (`find.text('Logout')`). `findsOneWidget` là có đúng một, `findsNothing` là không có cái nào.

## Tự thử bằng tay thế nào?

"Tắt hẳn app" nghĩa là vuốt app khỏi danh sách ứng dụng gần đây, không chỉ bấm nút Home.

1. Mở app lần đầu: thấy Login.
2. Nhập `emilys` và mật khẩu sai (vẫn đủ 6 ký tự): khung đỏ hiện `Invalid credentials`.
3. Nhập `emilys` / `emilyspass`: sang Home, thấy token rút gọn.
4. Tắt hẳn app rồi mở lại: vào thẳng Home.
5. Bấm Logout: về Login. Tắt hẳn app rồi mở lại: vẫn là Login.
