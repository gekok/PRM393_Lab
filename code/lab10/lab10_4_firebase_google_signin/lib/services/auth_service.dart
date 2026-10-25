import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Đăng nhập Google qua Firebase Authentication (google_sign_in 7.x + firebase_auth 7.x).
///
/// Các màn hình gọi lớp này để đọc phiên, đăng nhập và đăng xuất.
/// Lớp không tự giữ dữ liệu: phiên nằm trong `FirebaseAuth.instance` và
/// `GoogleSignIn.instance`, nên màn hình nào tạo `AuthService()` mới cũng thấy cùng một phiên.
///
/// Điều kiện: `main()` đã gọi `Firebase.initializeApp` và
/// `GoogleSignIn.instance.initialize()` trước khi gọi các hàm của lớp này.
class AuthService {
  /// User của phiên Firebase còn lưu trên máy; null nếu chưa đăng nhập.
  User? get currentUser {
    // Trên Android, Firebase khôi phục phiên cũ ngay trong initializeApp,
    // nên đọc đồng bộ ở Splash là đủ để quyết định auto-login.
    return FirebaseAuth.instance.currentUser;
  }

  /// Mở luồng Google Sign-In rồi đăng nhập Firebase.
  ///
  /// Ném [AuthFailure] khi người dùng huỷ hoặc cấu hình sai.
  Future<User> signInWithGoogle() async {
    try {
      // 1. Hiện hộp chọn tài khoản Google (Credential Manager trên Android).
      // v7 bỏ constructor GoogleSignIn(), chỉ còn một instance dùng chung.
      final account = await GoogleSignIn.instance.authenticate();

      // 2. v7: `authentication` là getter đồng bộ và chỉ còn idToken (không còn accessToken).
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const AuthFailure(
          'Google không trả về idToken. Kiểm tra google-services.json có '
          'web client (client_type 3) chưa.',
        );
      }

      // 3. Đổi idToken thành credential của Firebase rồi đăng nhập Firebase.
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final result = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = result.user;
      if (user == null) {
        throw const AuthFailure('Firebase không trả về thông tin người dùng.');
      }
      return user;
    } on GoogleSignInException catch (error) {
      // Ghi code + description (không ghi details) để phân biệt tự huỷ với sai cấu hình.
      debugPrint(
        'GoogleSignInException ${error.code.name}: ${error.description}',
      );

      // Dịch mã lỗi của google_sign_in thành câu người dùng hiểu được.
      if (error.code == GoogleSignInExceptionCode.canceled) {
        // Theo README google_sign_in_android, một số lỗi cấu hình (SHA-1, package name)
        // cũng ra "canceled"; plugin không phân biệt được với việc người dùng tự bấm huỷ.
        throw const AuthFailure(
          'Đã huỷ đăng nhập Google. Nếu bạn không bấm huỷ, hãy kiểm tra '
          'package name và SHA-1 trên Firebase console.',
        );
      }
      if (error.code == GoogleSignInExceptionCode.clientConfigurationError ||
          error.code == GoogleSignInExceptionCode.providerConfigurationError) {
        throw AuthFailure(
          'Cấu hình Google Sign-In chưa đúng: '
          '${error.description ?? error.code.name}',
        );
      }
      final reason = error.description ?? 'không rõ lý do';
      throw AuthFailure(
        'Đăng nhập Google thất bại (${error.code.name}): $reason',
      );
    } on FirebaseAuthException catch (error) {
      // Google đã chọn xong tài khoản nhưng Firebase từ chối → thoát Google,
      // vì google_sign_in khuyên gọi signOut() trước lần authenticate() kế tiếp.
      await _signOutGoogle();
      final reason = error.message ?? 'không rõ lý do';
      throw AuthFailure('Firebase từ chối đăng nhập (${error.code}): $reason');
    }
  }

  /// Thoát khỏi cả Firebase lẫn Google.
  Future<void> signOut() async {
    // 1. Firebase trước: phiên này quyết định lần mở app sau có tự đăng nhập không.
    await FirebaseAuth.instance.signOut();
    // 2. Google sau: xoá trạng thái đăng nhập Google để lần sau phải chọn lại tài khoản.
    await _signOutGoogle();
  }

  // Lỗi khi thoát Google chỉ ghi log, không chặn luồng chính:
  // phiên quyết định app có đăng nhập hay không là phiên Firebase.
  Future<void> _signOutGoogle() async {
    try {
      await GoogleSignIn.instance.signOut();
    } on Exception catch (error) {
      debugPrint('GoogleSignIn.signOut lỗi: $error');
    }
  }
}

/// Lỗi đăng nhập đã được dịch thành câu dễ hiểu để màn hình hiện thẳng lên.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
