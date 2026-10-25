# Hướng dẫn đọc code — Lab 10.2 Real API Login

## Bài này làm gì?

Giống Lab 10.1, nhưng hỏi server thật là DummyJSON.
App gửi username và password tới `https://dummyjson.com/auth/login`.
Server trả về token kèm hồ sơ người dùng, hoặc trả về lỗi.

Tài khoản test: `emilys` / `emilyspass`.

## Khác gì Lab 10.1?

Lab 10.1:

```
MockAuthService chờ 2 giây giả
trả về token, hoặc null khi sai
sai thì hiện SnackBar
đăng nhập bằng email
```

Lab 10.2:

```
AuthService gửi HTTP POST thật
trả về AuthUser, hoặc ném AuthException khi lỗi
lỗi hiện trong khung đỏ phía trên nút Login
đăng nhập bằng username
```

## Nên đọc file theo thứ tự nào?

1. `lib/main.dart` — điểm bắt đầu. Mở màn `LoginScreen` đầu tiên.
2. `lib/models/auth_user.dart` — lớp `AuthUser` chứa dữ liệu server trả về. `fromJson` đọc từng trường trong JSON.
3. `lib/services/auth_service.dart` — hàm `login()` của `AuthService` gửi request, xem mã trạng thái (status code), trả kết quả hoặc ném lỗi.
4. `lib/screens/login_screen.dart` — form đăng nhập. `_submit()` gọi `login()` trong `try/catch`.
5. `lib/screens/home_screen.dart` — hiện ảnh, tên, email, token rút gọn và nút Logout.
6. `test/widget_test.dart` — một bài test: bấm Login khi form trống thì hiện lỗi.

## Đọc `login_screen.dart` thế nào cho dễ?

Chia file thành 5 phần, đọc từ trên xuống:

1. Các biến của màn hình: `_formKey`, hai controller, `_authService`, `_isLoading`, `_errorMessage`.
2. Hai hàm kiểm tra ô nhập: `_validateUsername`, `_validatePassword`.
3. Hàm `_showError()`: tắt vòng xoay, ghi câu lỗi vào `_errorMessage`.
4. Hàm `_submit()`: chạy khi bấm Login, gọi `login()` trong `try/catch`.
5. Hàm `build()`: vẽ giao diện, có khung lỗi đỏ phía trên nút Login.

## App chạy thế nào từ lúc mở đến màn cuối?

```
main()
↓
runApp(Lab10App) → MaterialApp mở LoginScreen
↓
người dùng nhập username, password rồi bấm Login
↓
_submit() gọi validate(); ô nào sai thì dừng ở đây
↓
setState: bật vòng xoay, xóa lỗi của lần trước
↓
_authService.login() gửi http.post tới DummyJSON, chờ tối đa 10 giây
↓
status 200 → jsonDecode → AuthUser.fromJson → trả về AuthUser
status 400 hoặc 401 → ném AuthException với message của server ("Invalid credentials")
mất mạng / quá 10 giây / status khác → ném AuthException với câu dễ hiểu
↓
quay lại LoginScreen:
có AuthUser → pushReplacement sang HomeScreen(user: user)
bắt được AuthException → _showError(e.message) → khung đỏ hiện câu lỗi
lỗi khác (vd JSON hỏng) → _showError('Something went wrong. Please try again.')
↓
HomeScreen hiện ảnh, "Welcome, Emily Johnson", @emilys, email, 16 ký tự đầu của token
↓
bấm Logout → pushAndRemoveUntil về LoginScreen
```

## Vì sao `try` trong AuthService chỉ bọc lời gọi mạng?

`AuthException` cũng là một `Exception`.
Nhánh `on Exception` bắt mọi `Exception` ném ra bên trong `try`.

Nếu đoạn kiểm tra status code nằm trong `try`, chuyện sau sẽ xảy ra:

```
sai mật khẩu
↓
throw AuthException('Invalid credentials')
↓
on Exception bắt luôn lỗi này
↓
người dùng thấy "Cannot connect to the server" — sai sự thật
```

Vì vậy `try` chỉ bọc `http.post(...)`. Phần xử lý status code nằm bên dưới.

## Các khái niệm xuất hiện trong bài

**REST API và HTTP POST**
API là "cửa" để app nói chuyện với server qua Internet.
POST là kiểu request gửi dữ liệu lên server, ở đây là username và password.

**Mã trạng thái (status code)**
Con số server trả kèm mỗi phản hồi.
`200` là thành công. `400` là request sai, DummyJSON dùng nó khi sai tài khoản.
Code xử lý `401` (chưa xác thực) giống hệt `400`.

**Gói `http` và `import ... as http`**
`import 'package:http/http.dart' as http;` đặt cho gói một tên ngắn là `http`.
Vì vậy code viết `http.post(...)` và `http.Response`.
`http.post(Uri.parse(url), headers: ..., body: ...)` gửi request và trả về `Future<http.Response>`.
`response.statusCode` là mã trạng thái, `response.body` là nội dung dạng chuỗi.

**JSON, `jsonEncode`, `jsonDecode`**
JSON là dạng chữ để gửi dữ liệu, ví dụ `{"username": "emilys"}`.
`jsonEncode` đổi Map của Dart thành chuỗi JSON. `jsonDecode` làm ngược lại.

**Kiểu `dynamic`, `Map<String, dynamic>` và `as String`**
`jsonDecode` không biết trước JSON chứa gì, nên trả về kiểu `dynamic`: "kiểu gì cũng được, chạy rồi mới biết".
Một object JSON như `{"username": "emilys"}` được đọc thành `Map<String, dynamic>`: khóa là chuỗi, giá trị là `dynamic`.
`json['accessToken'] as String` nói rõ "chỗ này phải là chuỗi". Thiếu trường này hoặc sai kiểu thì `as` ném lỗi, và `LoginScreen` bắt nó ở nhánh `catch (_)`.
Các trường còn lại dùng `?? ''`, nên server không gửi thì chỉ nhận chuỗi rỗng. Còn gửi sai kiểu (vd một số) thì vẫn ném lỗi như trên.

**Hàm tạo `factory AuthUser.fromJson`**
Hàm tạo đặc biệt nhận một Map JSON rồi dựng ra đối tượng `AuthUser`.
Đây là cách viết quen thuộc khi đọc dữ liệu từ API.

**Ký hiệu null (`String?`, `??`, `!`)**
`String?` là kiểu "có thể là chuỗi, cũng có thể là `null`" (chưa có giá trị). Ví dụ `_errorMessage`.
`a ?? b` nghĩa là "dùng `a`, nếu `a` là null thì dùng `b`".
`json['email'] ?? ''` cho chuỗi rỗng khi server không gửi email.
Dấu `!` (như `_errorMessage!`) khẳng định "chỗ này chắc chắn không null". Nếu thật ra là null, app báo lỗi ngay.

**Dart tự hiểu biến đã khác `null` (type promotion)**
Trong `build()`, dòng `if (_errorMessage != null)` vừa kiểm xong, nhưng bên dưới vẫn phải viết `_errorMessage!`.
Lý do: `_errorMessage` là biến của class và không `final`. Chỗ khác có thể gán lại nó, nên Dart không tự hiểu nó khác `null`.
Dart chỉ tự hiểu biến của class khi nó vừa `final` vừa có `_` ở đầu tên.
Biến cục bộ (khai báo trong hàm) thì dễ hơn: kiểm `!= null` xong mà không gán lại, Dart tự hiểu nó khác `null`, không cần `!`.

**Dấu gạch dưới `_` ở đầu tên**
Tên bắt đầu bằng `_` (như `_submit`, `_showError`, `_authService`) là riêng tư (private).
Chỉ code trong cùng file mới dùng được nó.

**`_` đứng một mình: bỏ qua tham số hoặc lỗi**
Khác với `_` ở đầu tên, một dấu `_` đứng riêng nghĩa là "có nhận nhưng không dùng".
`onFieldSubmitted: (_) => _submit()`: Flutter truyền vào chữ trong ô, nhưng `_submit()` không cần.
`builder: (_) => ...`: bỏ qua `context` mà Flutter truyền vào.
`catch (_)`: bắt lỗi nhưng không cần đọc lỗi đó là gì.

**Giới hạn thời gian (`timeout`)**
`.timeout(const Duration(seconds: 10))` ném `TimeoutException` nếu 10 giây chưa có phản hồi.

**Ném và bắt lỗi (`throw`, `try`, `on`, `catch`)**
`throw` ném lỗi ra ngoài hàm.
`try { ... } on AuthException catch (e) { ... }` bắt đúng loại lỗi đó, `e.message` là câu để hiển thị.
`catch (_)` cuối cùng bắt mọi lỗi còn lại, để nút Login không bị khóa mãi.

**Thứ tự các nhánh `on`**
Dart thử từng nhánh từ trên xuống. Nhánh nào khớp trước thì chạy nhánh đó.
`TimeoutException` cũng là một `Exception`.
Vì vậy `on TimeoutException` phải đứng trước `on Exception`. Đảo ngược thì lỗi quá giờ bị báo nhầm thành "Cannot connect".

**Khai báo trước, gán trong `try` (`final http.Response response;`)**
`response` được khai báo phía trên `try`, rồi mới gán giá trị bên trong `try`.
Nếu `try` gặp lỗi, hàm đã `throw` ra ngoài ngay.
Nên đoạn code bên dưới `try` chỉ chạy khi `response` đã có giá trị. Dart tự kiểm chuyện này lúc biên dịch.

**Lớp lỗi tự định nghĩa (`AuthException implements Exception`)**
Lớp lỗi riêng của bài, chỉ chứa câu thông báo `message`.

**Hai chuỗi đặt liền nhau**
Hai chuỗi viết trong dấu nháy, đặt sát nhau, được Dart tự nối thành một chuỗi, không cần dấu `+`.
Ví dụ `'Cannot connect to the server. '` và `'Please check your internet connection and try again.'` trong `auth_service.dart` ghép thành một câu báo lỗi.
Bộ lint của project (`flutter_lints`) cũng khuyên viết vậy thay cho `+`.
Cách này chỉ dùng cho chuỗi trong dấu nháy. Ghép chuỗi với biến thì dùng `$` hoặc `${}`.

**Widget có trạng thái, `setState`, `mounted`, Navigator**
Giống Lab 10.1.
`setState` đổi `_isLoading` và `_errorMessage` rồi vẽ lại màn.
`if (!mounted) return;` tránh dùng màn đã bị đóng trong lúc chờ mạng.
`pushReplacement` sang Home, `pushAndRemoveUntil` khi Logout.

**Khóa của Form (`GlobalKey<FormState>`)**
`_formKey` là chiếc chìa khóa gắn vào `Form(key: _formKey)`. Nhờ nó, `_submit()` gọi được `validate()` của Form.
`<FormState>` cho biết khóa này trỏ tới trạng thái (state) của một `Form`.
`_formKey.currentState` có kiểu `FormState?`: Form chưa có trên cây giao diện thì nó là `null`.
`_submit()` chỉ chạy khi bấm Login hoặc Enter trong ô mật khẩu, lúc đó Form chắc chắn đang hiện. Nên code viết `currentState!` để khẳng định nó khác `null`.

**`if` trong danh sách `children`**
Trong `children: [ ... ]` có thể đặt `if (điều kiện) widget`.
Điều kiện đúng thì widget đó có trong danh sách, sai thì bị bỏ qua như chưa từng viết.
`if (_errorMessage != null) Container(...)` chỉ vẽ khung lỗi đỏ khi có lỗi.

**Ảnh từ mạng (`Image.network`)**
Tải ảnh từ một URL. `errorBuilder` vẽ icon thay thế khi tải ảnh lỗi.

**Quyền INTERNET trên Android**
Khai báo trong `android/app/src/main/AndroidManifest.xml`.
Bản debug tự có quyền này, bản release thì cần dòng khai báo đó mới gọi được API.

## Các cú pháp nhỏ trong code nghĩa là gì?

- `final`: biến chỉ được gán một lần, gán xong không gán lại được. Ví dụ `final String username;` trong `AuthUser`: đọc từ JSON một lần rồi giữ nguyên.
- `const` trước widget, như `const SizedBox(height: 24)`: widget được tạo sẵn lúc biên dịch, nên vẽ lại màn chỉ dùng lại chứ không tạo mới. Mọi giá trị bên trong phải biết ngay lúc biên dịch, `final` thôi là chưa đủ: `user.email` tuy `final` nhưng chỉ có giá trị lúc chạy, nên `Text(user.email)` trong `home_screen.dart` không thể `const`.
- `@override`: đánh dấu hàm viết lại (ghi đè) một hàm mà lớp cha đã khai báo sẵn, như `build()`, `createState()`, `dispose()`. Nhờ `@override`, gõ sai tên (vd `dispos()`) thì Dart cảnh báo ngay vì lớp cha không có hàm đó; thiếu `@override` thì `dispos()` chỉ là một hàm mới và Dart im lặng.
- `super.key`: nhận tham số `key` rồi chuyển thẳng cho lớp cha (`StatelessWidget`, `StatefulWidget`). Gần như widget nào cũng có dòng này.
- `required`: tham số đặt tên bắt buộc phải truyền. Gọi `HomeScreen()` mà thiếu `user` thì Dart báo lỗi ngay lúc biên dịch.
- `=>`: cách viết ngắn cho hàm chỉ có một biểu thức. `(route) => false` giống hệt `(route) { return false; }`.
- `$` và `${}`: chèn giá trị vào giữa chuỗi. `'Welcome, $displayName'` chèn một biến; có dấu chấm như `user.username` thì phải bọc ngoặc nhọn: `'@${user.username}'`.
- `? :`: chọn một trong hai giá trị. `_isLoading ? null : _submit` nghĩa là đang chờ thì `null` (nút bị khóa), không thì `_submit`.
- `find.*`: trong test, tìm widget theo chữ (`find.text('Please enter your username')`) hoặc theo loại (`find.byType(CircularProgressIndicator)`). `findsOneWidget` là có đúng một, `findsNothing` là không có cái nào.

## Tự thử bằng tay thế nào?

1. Bấm Login khi để trống: hai ô hiện lỗi đỏ, không gọi mạng.
2. Nhập `emilys` và mật khẩu sai (vẫn đủ 6 ký tự): khung đỏ hiện `Invalid credentials`.
3. Tắt mạng rồi đăng nhập: khung đỏ hiện `Cannot connect to the server...`.
4. Nhập `emilys` / `emilyspass`: sang Home, thấy ảnh và `Welcome, Emily Johnson`.
5. Bấm Logout: về Login. Bấm Back không quay lại Home.
