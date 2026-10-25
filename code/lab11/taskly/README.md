# Taskly — Lab 11 (Testing & Debugging)

App todo nhỏ để luyện viết test trong Flutter. Có hai màn: danh sách task và chi tiết task.

Mới đọc code lần đầu? Xem `HUONG_DAN_DOC.md`: thứ tự đọc file, luồng chạy của app và giải thích các khái niệm chính.

## App được tổ chức thế nào?

Dữ liệu đi một chiều:

```
UI (TaskListScreen, TaskDetailScreen)
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
- `lib/screens/task_list_screen.dart` — ô nhập, nút Add và danh sách (tick, xoá, bấm để mở chi tiết).
- `lib/screens/task_detail_screen.dart` — sửa title, nút Save.

`TaskListScreen` cố ý để ở dạng **chưa tối ưu**:

- `context.watch` ở đầu `build`;
- `ListTile` viết thẳng trong `itemBuilder`.

Đây là mốc để so sánh trước/sau khi tối ưu rebuild ở Lab 12.

## Chạy thế nào?

Mọi lệnh chạy từ thư mục `taskly/`:

```
flutter pub get
flutter analyze
flutter test
flutter test --reporter expanded
```

Muốn chạy trên Android thì chọn thiết bị bằng `flutter devices` rồi `flutter run -d <id>`.

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

Tổng `10` test. Số test, hành vi được kiểm và giới hạn: xem `docs/TEST_SUMMARY.md`.

## Vì sao integration test nằm ở `test/integration/`?

Đề bài ghi hai chỗ khác nhau:

- Lab 11.4 ghi đường dẫn `test/widget/task_integration_test.dart`.
- Lab 11.5 yêu cầu cấu trúc `test/unit/`, `test/widget/`, `test/integration/`.

File được đặt theo **11.5**, vì đó là bước tổng hợp cuối cùng của cả suite.

Test này viết bằng `flutter_test` (`testWidgets`), không dùng package `integration_test`. Hệ quả:

- Chạy được bằng `flutter test`, không cần thiết bị hay emulator.
- Nó chạy trong môi trường test không có giao diện thật (headless). Lỗi riêng của nền tảng không được kiểm, ví dụ bàn phím ảo hay kích thước màn hình thật.

## Còn gì chưa làm?

- **Ảnh chụp DevTools** (Widget Inspector và Performance Timeline): cần tự chụp khi chạy app ở chế độ debug. Chưa làm ở bước này.
- **Định dạng báo cáo**: đề yêu cầu Debugging report dạng PDF/DOC và Test summary dạng PDF. Bản PDF nằm cạnh bản Markdown: `docs/DEBUGGING_REPORT.pdf` và `docs/TEST_SUMMARY.pdf`. Sửa file `.md` thì phải xuất lại PDF.
- **File nộp**: `Module11_Testing_<StudentID>_<FullName>.zip`, gồm `/lib`, `/test`, ảnh DevTools và các báo cáo. Không cần đưa `.dart_tool/` và `build/` vào zip: đó là file sinh tự động, trong đó có đường dẫn chứa tên tài khoản máy.

Cách mở DevTools để chụp:

1. Chọn thiết bị Android bằng `flutter devices`, rồi chạy `flutter run -d <id>`.
2. Console in ra dòng `The Flutter DevTools debugger and profiler on <tên thiết bị> is available at: ...`. Mở link đó.
3. Trang Flutter Inspector: chụp cây widget (widget tree).
4. Trang Performance: thêm và tick vài task, rồi chụp timeline.
