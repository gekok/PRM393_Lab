// Khóa lưu access token trong SharedPreferences, khai báo một lần cho cả app:
// LoginScreen ghi, SplashScreen đọc, HomeScreen xóa khi Logout.
// Splash dựa vào khóa này để biết người dùng đã đăng nhập hay chưa
const String authTokenKey = 'auth_token';
