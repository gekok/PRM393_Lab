import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Gói flutter_local_notifications (22.x) thành 3 việc app cần:
/// khởi tạo, xin quyền, hiện thông báo đăng nhập thành công.
///
/// Lớp không tự giữ dữ liệu riêng: `FlutterLocalNotificationsPlugin()` luôn trả về
/// cùng một plugin dùng chung, nên `NotificationService()` tạo ở màn hình nào
/// cũng dùng được plugin mà `main()` đã `init()`.
///
/// [showLoginSuccess] được tách riêng để Lab10_Full gọi lại sau khi đăng nhập thành công.
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Tên file icon trong android/app/src/main/res/drawable.
  // Phải trùng tên file drawable và tên trong res/raw/keep.xml.
  static const String _smallIcon = 'ic_stat_notification';

  // Channel và thông báo phải dùng cùng một id; người dùng bật/tắt thông báo theo channel.
  static const String _channelId = 'login_success';
  static const String _channelName = 'Đăng nhập';
  static const String _channelDescription =
      'Thông báo khi đăng nhập thành công';

  // Id cố định: đăng nhập nhiều lần chỉ cập nhật một thông báo, không xếp chồng.
  static const int _loginSuccessId = 1;

  // High để thông báo bật lên đầu màn hình (heads-up), không chỉ nằm trong khay.
  // Từ Android 8, mức này do channel quyết định. Channel có hai chỗ khai báo:
  // _loginChannel (init() tạo channel) và _loginDetails (show() tự tạo channel
  // nếu máy chưa có), nên hai chỗ dùng chung hằng này để không lệch nhau.
  // Channel đã tạo trên máy thì app chỉ hạ được mức này, và chỉ khi người dùng
  // chưa chỉnh channel trong Cài đặt. Muốn nâng lên phải gỡ app rồi cài lại.
  static const Importance _importance = Importance.high;

  static const AndroidNotificationChannel _loginChannel =
      AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: _importance,
      );

  static const NotificationDetails _loginDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: _importance,
      priority: Priority.high,
    ),
  );

  /// Khởi tạo plugin và tạo channel. Gọi một lần trong `main()` trước khi show.
  Future<void> init() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings(_smallIcon),
    );
    await _plugin.initialize(settings: settings);

    // Android 8+ bắt buộc có channel. Tạo trước để hiện ngay trong Cài đặt của app.
    // Không chạy trên Android thì _androidPlugin là null, bỏ qua bước này.
    final androidPlugin = _androidPlugin;
    if (androidPlugin == null) return;
    await androidPlugin.createNotificationChannel(_loginChannel);
  }

  /// Xin quyền POST_NOTIFICATIONS; trả về true nếu app được phép hiện thông báo.
  ///
  /// Android 13+ hiện hộp thoại xin quyền (chỉ khi chưa cấp và chưa bị chặn hẳn).
  /// Android 12 trở xuống không có hộp thoại: plugin trả ngay trạng thái
  /// bật/tắt thông báo của app trong Cài đặt.
  /// Ngoài Android (chưa hỗ trợ) trả về false.
  Future<bool> requestPermission() async {
    final androidPlugin = _androidPlugin;
    if (androidPlugin == null) return false;
    // Plugin trả về bool? → null cũng coi như chưa có quyền.
    final granted = await androidPlugin.requestNotificationsPermission();
    return granted ?? false;
  }

  /// Hiện thông báo "Đăng nhập thành công".
  Future<void> showLoginSuccess() async {
    await _plugin.show(
      id: _loginSuccessId,
      title: 'Đăng nhập thành công',
      body: 'Chào mừng bạn quay lại!',
      notificationDetails: _loginDetails,
    );
  }

  // null khi không chạy trên Android.
  AndroidFlutterLocalNotificationsPlugin? get _androidPlugin {
    return _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
  }
}
