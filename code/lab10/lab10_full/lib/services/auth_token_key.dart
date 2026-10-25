// Khóa lưu access token trong SharedPreferences, khai báo một lần cho cả app:
// LoginScreen ghi, AuthGate đọc, HomeScreen xóa khi Logout.
// AuthGate dựa vào khóa này để biết người dùng đã đăng nhập DummyJSON hay chưa
const String authTokenKey = 'auth_token';

// Username DummyJSON: LoginScreen ghi ngay trước token, HomeScreen xóa cùng
// token khi Logout. Lúc tự đăng nhập, app chỉ đọc lại được những gì đã lưu,
// nên phải lưu username thì HomeScreen mới có tên để hiện
const String authUsernameKey = 'auth_username';
