# Hướng dẫn đọc code — Taskly (Lab 11)

File này giúp đọc code Taskly theo thứ tự dễ hiểu nhất. Mỗi file trong `lib/` ngắn và chỉ làm một việc.

## App này làm gì?

Taskly là app todo nhỏ, có hai màn:

- **Màn danh sách:** thêm task, tick hoàn thành, xoá task.
- **Màn chi tiết:** sửa title của một task rồi bấm Save.

Dữ liệu chỉ nằm trong bộ nhớ (in-memory). Tắt app là mất.

## Nên đọc file theo thứ tự nào?

Đọc từ **dữ liệu** lên **giao diện**, rồi mới đến **test**.

Phần app (`lib/`):

1. `lib/models/task.dart` — Một task gồm `id`, `title`, `completed`. Hàm `toggle()` đảo `completed`: false → true, true → false.
2. `lib/repositories/task_repository.dart` — "Cái kho" giữ danh sách task. Có `addTask`, `deleteTask`, `updateTask`. Kho cấp id tăng dần từ 1 và từ chối title rỗng.
3. `lib/providers/task_provider.dart` — Người trung gian giữa giao diện và kho. Nó gọi kho, rồi gọi `notifyListeners()` để báo giao diện vẽ lại.
4. `lib/main.dart` — Điểm bắt đầu của app. Tạo provider (đặt **trên** `MaterialApp`) và mở màn danh sách.
5. `lib/screens/task_list_screen.dart` — Màn chính: ô nhập, nút Add và danh sách. Mỗi dòng có checkbox, nút xoá, bấm vào dòng để mở màn chi tiết.
6. `lib/screens/task_detail_screen.dart` — Màn sửa title. Nút Save lưu title mới rồi quay về danh sách.

Phần test (`test/`):

7. `test/unit/task_model_test.dart` — 2 unit test cho `Task`.
8. `test/unit/task_repository_test.dart` — 3 unit test cho kho: thêm, xoá, sửa.
9. `test/widget/task_list_widget_test.dart` — 3 widget test cho màn danh sách.
10. `test/widget/task_navigation_test.dart` — 1 test chuyển màn: bấm task thì sang màn chi tiết.
11. `test/integration/task_integration_test.dart` — 1 test cả luồng: thêm → mở → sửa → lưu.

Tài liệu nộp bài: `docs/TEST_SUMMARY.md` (tóm tắt test) và `docs/DEBUGGING_REPORT.md` (báo cáo debugging).

## Dữ liệu đi qua những tầng nào?

Hình dung một quán cà phê:

- Khách là **giao diện** (UI).
- Nhân viên là **TaskProvider**.
- Kho nguyên liệu là **TaskRepository**.

Khách không tự vào kho. Khách gọi nhân viên, nhân viên vào kho làm việc. Xong việc, nhân viên hô lên để khách nhìn lại bàn.

```
UI (màn hình)
↓ gọi hàm, vd addTask("Buy milk")
TaskProvider
↓ gọi hàm
TaskRepository (giữ List<Task>)
```

Chiều quay về:

```
TaskProvider gọi notifyListeners()
↓
màn nào đang watch provider sẽ build lại
↓
màn hình hiện dữ liệu mới
```

## Mở app thì chuyện gì xảy ra?

```
main()
↓
runApp(const TasklyApp())
↓
TasklyApp.build: ChangeNotifierProvider bọc ngoài MaterialApp
↓
MaterialApp mở home: TaskListScreen
↓
TaskListScreen.build gọi context.watch<TaskProvider>()
↓
lần đầu có widget đọc → provider chạy create: TaskProvider(TaskRepository())   ← kho rỗng
↓
danh sách rỗng → màn hình hiện "No tasks yet. Add one!"
```

Provider tạo object kiểu "lười" (lazy): chỉ chạy `create` khi có widget đọc nó lần đầu.

## Thêm một task thì chuyện gì xảy ra?

```
gõ "Buy milk" vào ô nhập → bấm Add
↓
_addTask() trong TaskListScreen
↓
context.read<TaskProvider>().addTask("Buy milk")
↓
TaskRepository.addTask: title không rỗng → tạo Task(id: 1, ...) → thêm vào list → trả true
↓
TaskProvider gọi notifyListeners() → Provider ghi nhận "dữ liệu đã đổi"
↓
_addTask nhận true → xoá chữ trong ô nhập
↓
frame tiếp theo: TaskListScreen build lại → danh sách hiện "Buy milk"
```

Build lại không xảy ra ngay lúc gọi `notifyListeners()`, mà ở khung hình (frame) tiếp theo. Đó là lý do widget test phải gọi `tester.pump()` sau khi bấm.

Nếu title rỗng hoặc chỉ có dấu cách:

- `addTask` trả `false`, không thêm gì;
- provider không gọi `notifyListeners()`;
- ô nhập giữ nguyên chữ đang gõ.

## Tick checkbox thì chuyện gì xảy ra?

```
bấm checkbox của một dòng
↓
provider.toggleTask(task)
↓
tạo một Task MỚI cùng id, title, completed → gọi toggle() trên task mới
↓
TaskRepository.updateTask(newTask): thay task cùng id trong list
↓
notifyListeners()
↓
frame tiếp theo: màn build lại → checkbox đổi trạng thái
```

Vì sao phải tạo task mới, không gọi `toggle()` thẳng trên task cũ?

Lab 12 sẽ dùng `Selector`. `Selector` so sánh task cũ và task mới theo object. Sửa thẳng object cũ thì `Selector` thấy "vẫn là object đó", nên không vẽ lại.

## Xoá task thì chuyện gì xảy ra?

```
bấm icon thùng rác (tooltip 'Delete')
↓
provider.deleteTask(task.id)
↓
TaskRepository.deleteTask: xoá task mang id đó
↓
notifyListeners()
↓
frame tiếp theo: màn build lại → dòng biến mất
```

## Sửa title thì chuyện gì xảy ra?

```
bấm vào một dòng
↓
Navigator.of(context).push(MaterialPageRoute(...)) mở TaskDetailScreen(task: task)
↓
TaskDetailScreen.initState() điền sẵn title cũ vào ô nhập
↓
sửa chữ → bấm Save → _save()
↓
context.read<TaskProvider>().updateTaskTitle(widget.task, chữ mới)
↓
tạo Task MỚI: giữ id và completed, thay title → TaskRepository.updateTask
↓
notifyListeners() → Provider ghi nhận "dữ liệu đã đổi"
↓
Navigator.of(context).pop() → gỡ màn chi tiết
↓
frame tiếp theo: màn danh sách (nằm bên dưới, đang watch) build lại → thấy title mới
```

Nếu title mới rỗng:

- `updateTask` trả `false`, title cũ giữ nguyên;
- provider không gọi `notifyListeners()`;
- màn vẫn quay về danh sách.

## Các khái niệm cần biết là gì?

**Provider** — Cách đưa một object (ở đây là `TaskProvider`) xuống cho mọi widget bên dưới trong cây widget (widget tree). Widget nào cần thì lấy qua `context`.

**ChangeNotifier** — Class biết "báo tin". `TaskProvider extends ChangeNotifier`, nên khi gọi `notifyListeners()` thì mọi widget đang lắng nghe (listener) đều được báo.

**context.watch và context.read** — Hai cách lấy provider, khác nhau ở chỗ có đăng ký vẽ lại hay không:

```
context.watch<TaskProvider>()
→ lấy provider VÀ đăng ký: provider báo tin thì widget build lại
→ dùng trong build(), vd TaskListScreen.build
```

```
context.read<TaskProvider>()
→ chỉ lấy provider để gọi hàm, KHÔNG đăng ký build lại
→ dùng trong hàm xử lý bấm nút, vd _addTask, _save
```

**Vì sao provider đặt trên MaterialApp?** — Màn chi tiết được mở bằng `Navigator`, nó là một route mới chứ không nằm trong `home`. Provider phải bọc cả `MaterialApp` thì màn chi tiết mới đọc được `TaskProvider`.

**Navigator** — Quản lý chồng màn hình (stack). `push` đặt màn mới lên trên. `pop` gỡ màn trên cùng để quay về màn bên dưới.

**StatefulWidget và TextEditingController** — Hai màn đều là `StatefulWidget` vì phải giữ `TextEditingController` (object giữ chữ trong ô nhập). Controller tạo một lần và giải phóng ở `dispose()`. `initState()` chạy một lần khi màn mở.

Với `StatefulWidget`, các hàm `build()`, `initState()`, `_addTask()`... nằm trong lớp State đi kèm, vd `_TaskListScreenState`. File này gọi tắt là `TaskListScreen.build` cho dễ đọc.

**ListView.builder và itemBuilder** — `ListView.builder` vẽ danh sách kiểu "lười" (lazy): chỉ tạo những dòng đang hiện trên màn hình, cộng vài dòng sát mép. `itemCount` cho nó biết có bao nhiêu dòng. Khi cần vẽ dòng thứ `index`, nó gọi `itemBuilder(context, index)`. Trong `TaskListScreen`, `itemBuilder` lấy `tasks[index]` rồi trả về một `ListTile`.

**Tham số `_`** — Dấu gạch dưới đứng thay cho tham số mà hàm buộc phải nhận nhưng code không dùng tới; nó không tạo ra biến, nên thân hàm cũng không đọc được. Ví dụ `create: (_) => TaskProvider(TaskRepository())` trong `main.dart`: Provider luôn truyền vào một `context`, nhưng tạo `TaskProvider` không cần đến nó.

**Key** — "Tên riêng" của một widget để test tìm đúng nó, vd `find.byKey(const Key('taskTextField'))`. App có 4 key: `taskTextField`, `addTaskButton`, `detailTitleField`, `detailSaveButton`.

## Có những loại test nào?

**Unit test** — Kiểm logic thuần, không có giao diện. Viết bằng `test(...)`, chạy nhanh nhất. Ví dụ: `task_model_test.dart`, `task_repository_test.dart`.

**Widget test** — Kiểm giao diện và thao tác (gõ, bấm) trong môi trường giả lập, không cần máy thật. Viết bằng `testWidgets(...)`. Ví dụ: `task_list_widget_test.dart`.

**Navigation test** — Một dạng widget test, chỉ kiểm việc chuyển màn. Ví dụ: `task_navigation_test.dart`.

**Integration test** — Kiểm cả một luồng người dùng qua nhiều màn. Ví dụ: `task_integration_test.dart`. File này viết bằng `flutter_test` nên chạy bằng `flutter test`, không cần thiết bị.

Tháp test (testing pyramid): unit nhiều nhất, test càng bao nhiều màn thì càng ít. Bộ test này có 5 unit, 3 widget, 1 navigation, 1 integration.

**Mẫu AAA** — Mỗi test chia ba bước: Arrange (chuẩn bị) → Act (làm) → Assert (kiểm). Comment trong unit test và widget test đánh dấu từng bước. Integration test thì đánh dấu theo "Bước 1, 2, 3" của luồng.

## Các lệnh trong widget test làm gì?

- `tester.pumpWidget(...)` — vẽ widget lần đầu.
- `tester.enterText(finder, 'Buy milk')` — gõ chữ vào ô nhập.
- `tester.tap(finder)` — bấm vào widget.
- `tester.pump()` — vẽ thêm một khung hình (frame). Sau khi bấm phải `pump()` mới thấy giao diện mới.
- `tester.pumpAndSettle()` — vẽ liên tục đến khi hết animation, vd hiệu ứng chuyển màn.
- `find.text`, `find.byKey`, `find.byType`, `find.widgetWithText` — tìm widget trên màn hình.
- `expect(finder, findsOneWidget)` — kiểm kết quả. Ngoài ra còn `findsNothing`, `findsNWidgets(2)`.

Một bẫy cần nhớ: `find.text('Buy milk')` khớp cả chữ đang nằm trong ô nhập. Vì vậy test kiểm "task có trong danh sách" bằng `find.widgetWithText(ListTile, 'Buy milk')`.

## `group`, `isTrue`, `async` trong file test là gì?

- `group('TaskRepository', () { ... })` — gom các test cùng chủ đề dưới một tên chung. Khi chạy, tên group được ghép vào trước tên từng test, vd `TaskRepository addTask() adds a task with the given title`.
- `isTrue`, `isFalse`, `hasLength(1)` — các "bộ so khớp" (matcher) đặt ở vế sau của `expect`. `expect(task.completed, isTrue)` đòi giá trị phải là `true`; `expect(repository.tasks, hasLength(1))` đòi danh sách có đúng 1 phần tử.
- `async` / `await` — các lệnh `tester.*` dùng trong bộ test này đều trả về `Future` (việc xong sau), nên hàm của `testWidgets` được đánh dấu `async` và mỗi lệnh có `await` để chờ xong mới chạy dòng tiếp. Unit test không có lệnh nào phải chờ, nên viết `() { ... }` bình thường.

## Vì sao navigation test tự dựng Provider, còn test khác dùng TasklyApp?

`TasklyApp` luôn tạo kho rỗng.

Test danh sách và integration test bắt đầu từ kho rỗng, nên pump thẳng `const TasklyApp()`.

Navigation test cần kho có sẵn một task (seed). Nên test tự làm ba bước:

```
tạo TaskRepository() và addTask('Demo task')
↓
bọc ChangeNotifierProvider(create: (_) => TaskProvider(repository))
↓
child: MaterialApp(home: TaskListScreen())
```

## Chạy test thế nào?

Chạy từ thư mục `taskly/`:

```
flutter test
flutter test --reporter expanded
```

Kết quả mong đợi: `10` test, dòng cuối là `All tests passed!`.
