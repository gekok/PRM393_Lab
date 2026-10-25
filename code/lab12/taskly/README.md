# Taskly — Lab 12 (Performance Optimization & Deployment)

App todo nhỏ viết bằng Flutter và Provider. Có hai màn: danh sách task và chi tiết task.

Lab 12 tối ưu số lần build của màn danh sách, tối ưu ảnh, phân tích dung lượng app, rồi build bản phát hành (release).

Mới đọc code lần đầu? Xem `HUONG_DAN_DOC.md`: thứ tự đọc file, luồng chạy của app, và giải thích các khái niệm Selector, const, ValueKey, precacheImage, `--analyze-size`, release APK.

Kết quả và số đo: `docs/BAO_CAO_LAB12.md`, bản PDF là `docs/BAO_CAO_LAB12.pdf`.

## App được tổ chức thế nào?

Dữ liệu đi một chiều:

```
UI (TaskListScreen, TaskTile, TaskDetailScreen)
↓
TaskProvider (ChangeNotifier, package provider)
↓
TaskRepository (lưu trong bộ nhớ)
```

Các file chính:

- `lib/main.dart` — `TasklyApp`. `ChangeNotifierProvider` nằm **trên** `MaterialApp`, home là `TaskListScreen`. Mỗi lần mở app tạo một kho rỗng mới.
- `lib/models/task.dart` — `Task` gồm `id`, `title`, `completed` và `toggle()`.
- `lib/repositories/task_repository.dart` — thêm, xoá, sửa task. Id tăng dần từ 1. Title rỗng bị từ chối.
- `lib/providers/task_provider.dart` — bọc repository, gọi `notifyListeners()` để báo UI vẽ lại. Tick và sửa title tạo một `Task` mới rồi thay vào kho.
- `lib/screens/task_list_screen.dart` — ô nhập, nút Add và danh sách. Danh sách nằm trong `Selector<TaskProvider, List<Task>>`, mỗi dòng gắn `ValueKey(task.id)`. `didChangeDependencies()` nạp sẵn logo bằng `precacheImage`.
- `lib/widgets/task_tile.dart` — một dòng của danh sách: checkbox, title, nút xoá, bấm để mở chi tiết.
- `lib/screens/task_detail_screen.dart` — logo ở trên cùng, sửa title, nút Save.
- `assets/images/taskly_logo.png` — logo 128×128, khai báo trong `pubspec.yaml`.

## Lab 12 tối ưu những gì?

- **12.1 — Danh sách:** tách `TaskTile`, dùng `Selector` thay cho `watch` ở đầu màn, gắn `ValueKey(task.id)`. Tick 1 task trong kho 3 task: `342 → 252` lần build, AppBar và ô nhập không còn build lại. Các dòng đang hiện thì vẫn build lại (xem báo cáo).
- **12.2 — Ảnh:** logo gốc 512×512 (`10136` byte) thu nhỏ còn 128×128 (`4812` byte). Nạp sẵn bằng `precacheImage`. Ảnh 512 đã bỏ khỏi `pubspec.yaml`.
- **12.3 — Dung lượng:** APK arm64 nặng `16 752 717` byte (~16.0 MiB). Phần lớn nhất là thư viện native: engine Flutter và code Dart đã biên dịch.
- **12.4 — Phát hành:** không có `print()` hay log debug, `const` đã đủ. `flutter clean` rồi `flutter build apk --release` thành công. Sau đó bỏ dependency `cupertino_icons`, vì app không dùng icon Cupertino nào. Build release lại, không clean lại, vẫn thành công.

Chi tiết từng con số, cách đo và giới hạn: xem báo cáo.

## Chạy thế nào?

Mọi lệnh chạy từ thư mục `taskly/`:

```
flutter pub get
flutter analyze
flutter test
flutter test --reporter expanded
```

Build Android:

```
flutter build apk --analyze-size --target-platform android-arm64
flutter clean
flutter build apk --release
flutter build apk --debug
```

APK release nằm ở `build/app/outputs/flutter-apk/app-release.apk`. `flutter clean` xoá mọi APK đã build, nên chạy `--release` và `--debug` sau nó.

Muốn chạy trên Android thì chọn thiết bị bằng `flutter devices` rồi `flutter run -d <id>`. Đo hiệu năng thì chạy `flutter run --profile -d <id>`.

## Test nằm ở đâu?

```
test/
 ├─ unit/
 │   ├─ task_model_test.dart         2 test: giá trị mặc định, toggle()
 │   └─ task_repository_test.dart    3 test: addTask, deleteTask, updateTask
 ├─ widget/
 │   ├─ task_list_widget_test.dart   3 test: empty state, thêm 1 task, thêm 2 task
 │   └─ task_navigation_test.dart    1 test: bấm task → màn Task Detail
 └─ integration/
     └─ task_integration_test.dart   1 test: thêm → mở → sửa → Save → danh sách cập nhật
```

Tổng `10` test, giữ nguyên từ Lab 11. Ở Lab 12 chúng là kiểm hồi quy (regression test): tối ưu xong mà vẫn xanh nghĩa là thêm task, mở chi tiết và sửa title vẫn chạy đúng.

## Vì sao integration test nằm ở `test/integration/`?

Đề bài Lab 11 ghi hai chỗ khác nhau:

- Lab 11.4 ghi đường dẫn `test/widget/task_integration_test.dart`.
- Lab 11.5 yêu cầu cấu trúc `test/unit/`, `test/widget/`, `test/integration/`.

File được đặt theo **11.5**, vì đó là bước tổng hợp cuối cùng của cả suite.

Test này viết bằng `flutter_test` (`testWidgets`), không dùng package `integration_test`. Hệ quả:

- Chạy được bằng `flutter test`, không cần thiết bị hay emulator.
- Nó chạy trong môi trường test không có giao diện thật (headless). Lỗi riêng của nền tảng không được kiểm, ví dụ bàn phím ảo hay kích thước màn hình thật.

## Còn gì chưa làm?

- **Chạy `flutter run --profile` trên máy thật hoặc emulator** để xem FPS, jank, độ mượt: chưa làm.
- **Cài APK release lên máy và thử tay:** chưa làm.
- **Ảnh chụp:** chưa có ảnh nào. Cần chụp: đếm rebuild trước/sau trong DevTools, cây dung lượng (App Size) trong DevTools, app chạy bản release.
- **Ký app bằng keystore riêng:** chưa làm. Bản release đang ký bằng khoá debug của template Flutter. Đủ để cài thử, không dùng được để đưa lên Google Play.
- **AppBundle** (`flutter build appbundle --release`): đề cho phép thay cho APK. Chưa build.
- **File nộp:** zip gồm `lib/`, `assets/`, báo cáo và `app-release.apk`. APK nằm trong `build/`, nên chép nó ra trước khi chạy `flutter clean`. Không cần đưa `.dart_tool/` và `build/` vào zip: đó là file sinh tự động, trong đó có đường dẫn chứa tên tài khoản máy.

Cách chụp bằng DevTools (tên mục chính xác trong DevTools 2.60 chưa được kiểm, vì DevTools chưa được mở):

1. **Đếm rebuild:** chạy bản **debug** (`flutter run -d <id>`). Flutter chỉ đếm rebuild ở bản debug. Mở link DevTools in ra console, bật đếm rebuild ở trang Performance, tick vài task rồi chụp.
2. **FPS và jank:** chạy bản **profile** (`flutter run --profile -d <id>`), mở trang Performance, cuộn và tick vài task rồi chụp.
3. **App Size:** chạy `dart devtools --appSizeBase=<file JSON>`. Đường dẫn file JSON in ra cuối lệnh `--analyze-size` (xem báo cáo, mục 12.3). Chụp cây dung lượng.
