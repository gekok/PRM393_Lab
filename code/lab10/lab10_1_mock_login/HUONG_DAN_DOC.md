# Hướng dẫn đọc code — Lab 10.1 Mock Login

## Bài này làm gì?

App có một màn đăng nhập.
Người dùng nhập email, mật khẩu rồi bấm Login.
App giả vờ hỏi server trong 2 giây, rồi báo đúng hoặc sai.

- Đúng tài khoản demo: sang màn Home.
- Sai: ở lại màn Login, hiện thông báo lỗi.

Chưa có server thật.
Lớp `MockAuthService` đóng vai server giả (mock).

Tài khoản demo: `demo@test.com` / `123456`.

## Nên đọc file theo thứ tự nào?

1. `lib/main.dart` — điểm bắt đầu của app. Mở màn `LoginScreen` đầu tiên.
2. `lib/services/mock_auth_service.dart` — server giả. Chờ 2 giây, so với tài khoản demo, trả về token hoặc `null`.
3. `lib/screens/login_screen.dart` — màn đăng nhập. File dài nhất, nên đọc kỹ nhất.
4. `lib/screens/home_screen.dart` — màn sau khi đăng nhập. Hiện email, token và nút Logout.
5. `test/widget_test.dart` — một bài test tự động: đăng nhập bằng tài khoản demo rồi kiểm tra đã sang Home.

## Đọc `login_screen.dart` thế nào cho dễ?

Chia file thành 4 phần, đọc từ trên xuống:

1. Các biến của màn hình: `_formKey`, hai controller, `_authService`, `_isLoading`.
2. Hai hàm kiểm tra ô nhập: `_validateEmail`, `_validatePassword`.
3. Hàm `_submit()`: chạy khi bấm Login.
4. Hàm `build()`: vẽ giao diện.

## App chạy thế nào từ lúc mở đến màn cuối?

```
main()
↓
runApp(Lab10App)
↓
MaterialApp mở LoginScreen
↓
người dùng nhập email, mật khẩu rồi bấm Login
↓
_submit() gọi _formKey.currentState!.validate()
↓
ô nào sai → hiện chữ đỏ dưới ô đó, dừng lại
mọi ô đúng → bật vòng xoay, gọi _authService.login()
↓
MockAuthService chờ 2 giây
↓
sai tài khoản → trả về null → tắt vòng xoay, hiện SnackBar "Invalid credentials"
đúng tài khoản → trả về token → pushReplacement sang HomeScreen
↓
HomeScreen hiện email và 16 ký tự đầu của token
↓
bấm Logout → pushAndRemoveUntil về LoginScreen
```

## Các khái niệm xuất hiện trong bài

**Widget có trạng thái (StatefulWidget) và `setState`**
Màn có dữ liệu thay đổi khi đang chạy thì dùng StatefulWidget, ví dụ `LoginScreen`.
Gọi `setState(() { ... })` để đổi dữ liệu, Flutter sẽ vẽ lại màn hình (rebuild).
Ví dụ: đặt `_isLoading = true` thì nút Login biến thành vòng xoay.

**Widget không trạng thái (StatelessWidget)**
Màn chỉ hiển thị dữ liệu được truyền vào, không tự đổi, ví dụ `HomeScreen`.

**Form và `validator`**
`Form` gom các ô nhập lại thành một nhóm.
`validator` là hàm kiểm tra một ô: trả về chuỗi thì ô hiện lỗi đỏ, trả về `null` là hợp lệ.
`_formKey.currentState!.validate()` chạy mọi validator cùng lúc, trả về `true` khi tất cả đều hợp lệ.

**Khóa của Form (`GlobalKey<FormState>`)**
`_formKey` là chiếc chìa khóa gắn vào `Form(key: _formKey)`. Nhờ nó, `_submit()` gọi được `validate()` của Form.
`<FormState>` cho biết khóa này trỏ tới trạng thái (state) của một `Form`.
`_formKey.currentState` có kiểu `FormState?`: Form chưa có trên cây giao diện thì nó là `null`.
`_submit()` chỉ chạy khi bấm Login hoặc Enter trong ô mật khẩu, lúc đó Form chắc chắn đang hiện. Nên code viết `currentState!` để khẳng định nó khác `null`.

**Bộ điều khiển ô nhập (TextEditingController)**
Giữ chữ người dùng đã gõ. Đọc bằng `_emailController.text`.
Phải gọi `dispose()` khi màn bị đóng để giải phóng bộ nhớ.

**Ký hiệu null (`String?`, `?.`, `??`, `!`)**
`String?` là kiểu "có thể là chuỗi, cũng có thể là `null`" (chưa có giá trị).
`value?.trim()` chỉ gọi `trim()` khi `value` khác `null`. Nếu `value` là `null` thì cả biểu thức ra `null`.
`a ?? b` nghĩa là "dùng `a`, nếu `a` là `null` thì dùng `b`". Ví dụ: `value?.trim() ?? ''`.
Dấu `!` trong `_formKey.currentState!` khẳng định "chỗ này chắc chắn không `null`". Nếu thật ra là `null`, app báo lỗi ngay.
`login()` trả về `Future<String?>`: có token khi đúng tài khoản, `null` khi sai.

**Dart tự hiểu biến đã khác `null` (type promotion)**
Trong `_submit()`, `token` có kiểu `String?`.
Dòng `if (token == null) { ... return; }` đã chặn trường hợp `null`.
`token` là biến cục bộ khai báo bằng `final`, nên không ai gán lại được nó.
Vì vậy từ đó trở xuống, Dart tự hiểu `token` khác `null`, kể cả bên trong `builder: (_) => ...`.
Nhờ đó `HomeScreen(email: email, token: token)` không cần `!`.
Biến của class thì khác: kiểm `!= null` xong thường vẫn phải viết `!`, vì chỗ khác có thể gán lại nó.
Dart chỉ tự hiểu biến của class khi nó vừa `final` vừa có `_` ở đầu tên.

**Dấu gạch dưới `_` ở đầu tên**
Tên bắt đầu bằng `_` (như `_submit`, `_isLoading`, `_LoginScreenState`) là riêng tư (private).
Chỉ code trong cùng file mới dùng được nó.

**`_` đứng một mình: bỏ qua tham số**
Khác với `_` ở đầu tên, một dấu `_` đứng riêng nghĩa là "có nhận nhưng không dùng".
`onFieldSubmitted: (_) => _submit()`: Flutter truyền vào chữ trong ô, nhưng `_submit()` không cần.
`builder: (_) => HomeScreen(...)`: bỏ qua `context` mà Flutter truyền vào.

**Hàm bất đồng bộ (async / await / Future)**
`Future` là kết quả sẽ có sau một lúc.
`await` bắt hàm chờ kết quả đó rồi mới chạy tiếp, nhưng giao diện không bị đơ.
Hàm có `await` phải được đánh dấu `async`.
`Future.delayed(const Duration(seconds: 2))` tạo độ trễ 2 giây giống lúc chờ server.

**`mounted`**
Trong 2 giây chờ, màn Login có thể đã bị đóng.
`if (!mounted) return;` kiểm tra màn còn trên cây giao diện hay không trước khi dùng `context` hoặc `setState`.

**Chuyển màn (Navigator)**
Navigator giữ các màn chồng lên nhau như một chồng đĩa (stack).
`pushReplacement` mở màn mới và bỏ màn hiện tại, nên bấm Back không quay lại form đăng nhập.
`pushAndRemoveUntil(..., (route) => false)` mở màn mới và xóa hết các màn cũ. Logout dùng cách này.

**Thanh thông báo (SnackBar)**
Thanh chữ ngắn hiện ở đáy màn.
Hiện bằng `ScaffoldMessenger.of(context).showSnackBar(...)`.
`hideCurrentSnackBar()` ẩn thông báo cũ trước khi thử đăng nhập lần nữa.

**Token**
Chuỗi server cấp khi đăng nhập đúng, giống vé vào cửa.
Ở bài này token là chuỗi giả `mock-token-<thời điểm đăng nhập>`.

**Hằng số của lớp (`static const`)**
Gắn với lớp, dùng được mà không cần tạo đối tượng: `MockAuthService.demoEmail`.

**Hai chuỗi đặt liền nhau**
Hai chuỗi viết trong dấu nháy, đặt sát nhau, được Dart tự nối thành một chuỗi, không cần dấu `+`.
Dòng chữ gợi ý tài khoản demo cuối `login_screen.dart` viết theo cách này, để chia chuỗi dài thành hai dòng.
Bộ lint của project (`flutter_lints`) cũng khuyên viết vậy thay cho `+`.
Cách này chỉ dùng cho chuỗi trong dấu nháy. Ghép chuỗi với biến thì dùng `${}`.

**Widget test**
`testWidgets` dựng app trong môi trường giả lập.
`enterText` gõ chữ, `tap` bấm nút, `pump` vẽ lại một khung hình.
`pumpAndSettle` chờ mọi hiệu ứng chuyển màn chạy xong.

## Các cú pháp nhỏ trong code nghĩa là gì?

- `final`: biến chỉ được gán một lần, gán xong không gán lại được. Ví dụ `final String token;` trong `HomeScreen`: màn nhận token lúc được tạo rồi giữ nguyên.
- `const` trước widget, như `const SizedBox(height: 24)`: widget được tạo sẵn lúc biên dịch, nên vẽ lại màn chỉ dùng lại chứ không tạo mới. Mọi giá trị bên trong phải biết ngay lúc biên dịch, `final` thôi là chưa đủ: `email` tuy `final` nhưng chỉ có giá trị lúc chạy, nên `Text(email)` trong `home_screen.dart` không thể `const`.
- `@override`: đánh dấu hàm viết lại (ghi đè) một hàm mà lớp cha đã khai báo sẵn, như `build()`, `createState()`, `dispose()`. Nhờ `@override`, gõ sai tên (vd `dispos()`) thì Dart cảnh báo ngay vì lớp cha không có hàm đó; thiếu `@override` thì `dispos()` chỉ là một hàm mới và Dart im lặng.
- `super.key`: nhận tham số `key` rồi chuyển thẳng cho lớp cha (`StatelessWidget`, `StatefulWidget`). Gần như widget nào cũng có dòng này.
- `required`: tham số đặt tên bắt buộc phải truyền. Gọi `HomeScreen(...)` mà thiếu `email` hoặc `token` thì Dart báo lỗi ngay lúc biên dịch.
- `=>`: cách viết ngắn cho hàm chỉ có một biểu thức. `(route) => false` giống hệt `(route) { return false; }`.
- `${}`: chèn giá trị vào giữa chuỗi. `'mock-token-${DateTime.now().millisecondsSinceEpoch}'` ghép chữ `mock-token-` với số mili-giây tính từ năm 1970 đến lúc đăng nhập.
- `? :`: chọn một trong hai giá trị. `_isLoading ? null : _submit` nghĩa là đang chờ thì `null` (nút bị khóa), không thì `_submit`.
- `find.*`: trong test, tìm widget theo loại (`find.byType(HomeScreen)`), theo chữ (`find.text(...)`), hoặc ô nhập theo nhãn (`find.widgetWithText(TextFormField, 'Email')`). `expect(..., findsOneWidget)` kiểm có đúng một widget như vậy.

## Tự thử bằng tay thế nào?

1. Bấm Login khi để trống: hai ô hiện lỗi đỏ, không có vòng xoay.
2. Nhập `abc` vào ô email: báo thiếu `@`.
3. Nhập đúng email nhưng sai mật khẩu (vẫn đủ 6 ký tự, ví dụ `abcdef`): chờ 2 giây, hiện SnackBar `Invalid credentials`.
4. Nhập `demo@test.com` / `123456`: chờ 2 giây, sang Home. Bấm Back không quay lại Login.
5. Bấm Logout: về Login. Bấm Back không quay lại Home.
