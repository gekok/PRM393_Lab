# Hướng dẫn đọc code — Taskly (Lab 12)

File này giúp đọc code Taskly theo thứ tự dễ hiểu nhất. Mỗi file trong `lib/` ngắn và chỉ làm một việc.

Lab 12 lấy Taskly của Lab 11, tối ưu hiệu năng, rồi build bản phát hành (release). Số đo và kết quả build nằm ở `docs/BAO_CAO_LAB12.md`.

## App này làm gì?

Taskly là app todo nhỏ, có hai màn:

- **Màn danh sách:** thêm task, tick hoàn thành, xoá task.
- **Màn chi tiết:** có logo Taskly ở trên cùng. Sửa title của một task rồi bấm Save.

Dữ liệu chỉ nằm trong bộ nhớ (in-memory). Tắt app là mất.

## Lab 12 đổi gì so với Lab 11?

Bốn thay đổi trong code:

1. Mỗi dòng của danh sách tách thành widget riêng: `lib/widgets/task_tile.dart`.
2. `TaskListScreen` không `watch` provider ở đầu `build` nữa. Chỉ phần danh sách nằm trong `Selector`.
3. Mỗi dòng có `ValueKey(task.id)`.
4. Màn chi tiết có logo `assets/images/taskly_logo.png` (128×128). Màn danh sách nạp sẵn logo bằng `precacheImage`.

Không đổi logic: model, repository, provider, `main.dart` và 10 test.

`pubspec.yaml` bỏ dependency `cupertino_icons`, vì app không dùng icon Cupertino nào. Các dependency khác giữ nguyên.

## Nên đọc file theo thứ tự nào?

Đọc từ **dữ liệu** lên **giao diện**, rồi mới đến **test**.

Phần app (`lib/`):

1. `lib/models/task.dart` — Một task gồm `id`, `title`, `completed`. Hàm `toggle()` đảo `completed`: false → true, true → false.
2. `lib/repositories/task_repository.dart` — "Cái kho" giữ danh sách task. Có `addTask`, `deleteTask`, `updateTask`. Kho cấp id tăng dần từ 1 và từ chối title rỗng.
3. `lib/providers/task_provider.dart` — Người trung gian giữa giao diện và kho. Nó gọi kho, rồi gọi `notifyListeners()` để báo giao diện vẽ lại.
4. `lib/main.dart` — Điểm bắt đầu của app. Tạo provider (đặt **trên** `MaterialApp`) và mở màn danh sách.
5. `lib/screens/task_list_screen.dart` — Màn chính: ô nhập, nút Add và danh sách. Danh sách nằm trong `Selector`. Hàm `didChangeDependencies()` nạp sẵn logo của màn chi tiết.
6. `lib/widgets/task_tile.dart` — Một dòng của danh sách: checkbox, title, nút xoá. Bấm vào dòng để mở màn chi tiết.
7. `lib/screens/task_detail_screen.dart` — Màn sửa title, có logo ở trên cùng. Nút Save lưu title mới rồi quay về danh sách.

Cấu hình và ảnh:

8. `pubspec.yaml` — Mục `assets:` khai báo đúng một ảnh: `assets/images/taskly_logo.png`.
9. `assets/images/taskly_logo.png` — Logo 128×128 dùng trong app. Ảnh gốc 512×512 nằm ở `docs/images/`, chỉ để so sánh trong báo cáo, không được đóng gói vào app.

Phần test (`test/`), giữ nguyên từ Lab 11:

10. `test/unit/task_model_test.dart` — 2 unit test cho `Task`.
11. `test/unit/task_repository_test.dart` — 3 unit test cho kho: thêm, xoá, sửa.
12. `test/widget/task_list_widget_test.dart` — 3 widget test cho màn danh sách.
13. `test/widget/task_navigation_test.dart` — 1 test chuyển màn: bấm task thì sang màn chi tiết.
14. `test/integration/task_integration_test.dart` — 1 test cả luồng: thêm → mở → sửa → lưu.

Tài liệu:

- `docs/BAO_CAO_LAB12.md` và `docs/BAO_CAO_LAB12.pdf` — báo cáo Lab 12, có số đo thật.

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
Selector trong màn danh sách lấy lại danh sách task, so với lần trước
↓
khác → build lại phần danh sách          giống → không làm gì
↓
màn hình hiện dữ liệu mới
```

AppBar và hàng nhập liệu không nằm trong `Selector`, nên không build lại theo.

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
TaskListScreen.didChangeDependencies: precacheImage bắt đầu nạp logo của màn chi tiết
↓
TaskListScreen.build: vẽ AppBar, hàng nhập liệu và Selector
↓
Selector đọc provider lần đầu → provider chạy create: TaskProvider(TaskRepository())   ← kho rỗng
↓
danh sách rỗng → màn hình hiện "No tasks yet. Add one!"
```

Provider tạo object kiểu "lười" (lazy): chỉ chạy `create` khi có widget đọc nó lần đầu. Ở Lab 12, widget đọc đầu tiên là `Selector`.

`didChangeDependencies()` chạy một lần ngay sau `initState()`, trước `build()` đầu tiên. Nó chạy lại khi thứ mà màn đang phụ thuộc thay đổi, ví dụ mật độ điểm ảnh của màn hình.

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
frame tiếp theo: Selector thấy danh sách dài hơn → build lại phần danh sách → hiện "Buy milk"
```

Build lại không xảy ra ngay lúc gọi `notifyListeners()`, mà ở khung hình (frame) tiếp theo. Đó là lý do widget test phải gọi `tester.pump()` sau khi bấm.

Nếu title rỗng hoặc chỉ có dấu cách:

- `addTask` trả `false`, không thêm gì;
- provider không gọi `notifyListeners()`;
- ô nhập giữ nguyên chữ đang gõ.

## Tick checkbox thì chuyện gì xảy ra?

```
bấm checkbox của một dòng (TaskTile)
↓
context.read<TaskProvider>().toggleTask(task)
↓
tạo một Task MỚI cùng id, title, completed → gọi toggle() trên task mới
↓
TaskRepository.updateTask(newTask): thay task cùng id trong list
↓
notifyListeners()
↓
frame tiếp theo: Selector thấy phần tử ở vị trí đó là object khác → build lại danh sách → checkbox đổi trạng thái
```

Vì sao phải tạo task mới, không gọi `toggle()` thẳng trên task cũ?

`Selector` so sánh danh sách cũ và mới **từng phần tử, theo object**. Sửa thẳng object cũ thì hai danh sách vẫn chứa cùng các object. `Selector` kết luận "không có gì đổi" và không vẽ lại. Dữ liệu đã tick, nhưng checkbox đứng yên.

## Xoá task thì chuyện gì xảy ra?

```
bấm icon thùng rác (tooltip 'Delete') của một TaskTile
↓
context.read<TaskProvider>().deleteTask(task.id)
↓
TaskRepository.deleteTask: xoá task mang id đó
↓
notifyListeners()
↓
frame tiếp theo: Selector thấy danh sách ngắn hơn → build lại danh sách → dòng biến mất
```

## Sửa title thì chuyện gì xảy ra?

```
bấm vào một dòng (TaskTile)
↓
Navigator.of(context).push(route) mở TaskDetailScreen(task: task)
↓
TaskDetailScreen.initState() điền sẵn title cũ vào ô nhập
↓
logo lấy từ bộ nhớ đệm ảnh (image cache), vì màn danh sách đã nạp sẵn
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
frame tiếp theo: Selector của màn danh sách (vẫn nằm bên dưới) thấy task đổi → build lại danh sách → thấy title mới
```

Nếu title mới rỗng:

- `updateTask` trả `false`, title cũ giữ nguyên;
- provider không gọi `notifyListeners()`;
- màn vẫn quay về danh sách.

## Các khái niệm nền là gì?

**Provider** — Cách đưa một object (ở đây là `TaskProvider`) xuống cho mọi widget bên dưới trong cây widget (widget tree). Widget nào cần thì lấy qua `context`.

**ChangeNotifier** — Class biết "báo tin". `TaskProvider extends ChangeNotifier`, nên khi gọi `notifyListeners()` thì mọi widget đang lắng nghe (listener) đều được báo.

**context.watch và context.read** — Hai cách lấy provider, khác nhau ở chỗ có đăng ký vẽ lại hay không:

```
context.watch<TaskProvider>()
→ lấy provider VÀ đăng ký: provider báo tin thì widget build lại
→ Lab 11 đặt ở đầu TaskListScreen.build, nên cả màn build lại mỗi lần báo tin
→ Lab 12 bỏ, thay bằng Selector chỉ bọc phần danh sách
```

```
context.read<TaskProvider>()
→ chỉ lấy provider để gọi hàm, KHÔNG đăng ký build lại
→ dùng trong hàm xử lý bấm nút, vd _addTask, _save, các callback trong TaskTile
```

**Vì sao provider đặt trên MaterialApp?** — Màn chi tiết được mở bằng `Navigator`, nó là một route mới chứ không nằm trong `home`. Provider phải bọc cả `MaterialApp` thì màn chi tiết mới đọc được `TaskProvider`.

**Navigator** — Quản lý chồng màn hình (stack). `push` đặt màn mới lên trên. `pop` gỡ màn trên cùng để quay về màn bên dưới.

**StatefulWidget và TextEditingController** — Hai màn đều là `StatefulWidget` vì phải giữ `TextEditingController` (object giữ chữ trong ô nhập). Controller tạo một lần và giải phóng ở `dispose()`. `initState()` chạy một lần khi màn mở.

Với `StatefulWidget`, các hàm `build()`, `initState()`, `didChangeDependencies()`, `_addTask()`... nằm trong lớp State đi kèm, vd `_TaskListScreenState`. File này gọi tắt là `TaskListScreen.build` cho dễ đọc.

**Tham số `_`** — Dấu gạch dưới đứng thay cho tham số mà hàm buộc phải nhận nhưng code không dùng tới; nó không tạo ra biến, nên thân hàm cũng không đọc được. Ví dụ `create: (_) => TaskProvider(TaskRepository())` trong `main.dart`: Provider luôn truyền vào một `context`, nhưng tạo `TaskProvider` không cần đến nó.

**Key** — "Tên riêng" của một widget. App dùng key theo hai cách:

- 4 key để test tìm đúng widget: `taskTextField`, `addTaskButton`, `detailTitleField`, `detailSaveButton`. Ví dụ `find.byKey(const Key('taskTextField'))`.
- `ValueKey(task.id)` trên mỗi dòng của danh sách. Xem phần ValueKey bên dưới.

## Các khái niệm của Lab 12 là gì?

### Selector — vì sao không watch cả màn?

`Selector<TaskProvider, List<Task>>` là widget nghe provider, giống `watch`. Khác ở chỗ nó chỉ chạy lại `builder` khi giá trị chọn ra (`selector`) khác lần trước.

Hình dung: `watch` ở đầu màn giống loa phát thanh cho cả trường mỗi khi có tin. `Selector` giống nhắn tin cho đúng một lớp cần biết.

Code trong `task_list_screen.dart`:

```dart
Selector<TaskProvider, List<Task>>(
  selector: (_, provider) => provider.tasks,
  builder: (context, tasks, _) {
    // ... ListView.builder, mỗi dòng là TaskTile
  },
)
```

Trong `selector: (_, provider)`, `_` là `context`, không dùng tới. Trong `builder: (context, tasks, _)`, tham số thứ ba (`_`) là `child`: một widget truyền sẵn vào `Selector`, được đưa lại nguyên vẹn cho builder; app này không truyền nên bỏ qua.

Đo bằng một test tạm (đã xoá sau khi đo), kho 3 task, tick checkbox của Task 1:

```
Lab 11 (watch đầu build): 342 lần build — có TaskListScreen, AppBar, TextField, ElevatedButton
Lab 12 (Selector):        252 lần build — 4 widget đó đều 0 lần
```

Bẫy cần nhớ: `Selector` so sánh từng phần tử **theo object**. Vì vậy provider phải tạo `Task` mới khi tick hoặc sửa title (mục "Tick checkbox" ở trên).

Giới hạn, đo thật: các dòng đang hiện **vẫn build lại hết**. Tick 1 dòng thì cả 3 `TaskTile` vẫn build.

Lý do nằm trong Flutter:

```
Selector build lại → tạo ListView.builder mới
↓
ListView.builder mới → Flutter gọi lại itemBuilder cho mọi dòng đang hiện
↓
mỗi dòng nhận một TaskTile mới → mỗi TaskTile build lại
```

Slide 15 ghi "Only the affected TaskTile rebuilds" (chỉ TaskTile bị ảnh hưởng mới build lại). Với code theo đúng đề (một `Selector` quanh cả danh sách), số đo cho thấy chưa đạt được điều đó.

Khi nào chấp nhận được: `ListView.builder` chỉ build các dòng đang hiện trên màn. Danh sách 1000 task thì vẫn chỉ build khoảng một màn hình dòng, không build cả 1000.

### const — vì sao widget có const nhanh hơn?

`const Text('Taskly')` tạo widget lúc biên dịch (compile time). Mỗi lần `build` chạy lại, Flutter nhận lại **đúng object cũ**, nên bỏ qua phần cây đó.

Ví dụ trong app: `const Text('Add')`, `const SizedBox(width: 8)`, `const Center(child: Text('No tasks yet. Add one!'))`.

Không thêm `const` được khi widget nhận giá trị lúc chạy (runtime):

- `Text(task.title)` — title chỉ biết khi app chạy;
- `TextField(controller: _titleController)` — controller là object tạo lúc chạy;
- `Image.asset(...)` — constructor này không phải const.

`flutter_lints 6.0.0` không bật sẵn lint `prefer_const_constructors` (lint nhắc thêm `const` khi tạo widget). Lab 12 bật tạm lint này để quét, kết quả `0` chỗ thiếu, rồi trả file cấu hình về như cũ.

### ValueKey — dòng nào là của task nào?

`ValueKey(task.id)` là "tên riêng" của một dòng, lấy theo id của task. Khi danh sách đổi, Flutter so key ở từng vị trí: key khác thì không dùng lại dòng cũ cho task mới.

Ví dụ đo thật: 3 task, xoá Task 2 ở giữa. Task 3 dời lên vị trí số 2.

```
Lab 11 (không key): vị trí số 2 dùng lại dòng cũ của Task 2, chỉ thay chữ thành Task 3
Lab 12 (có key):    key khác nhau (2 ≠ 3) → Flutter tạo dòng MỚI cho Task 3
```

Vì sao quan trọng: dòng dùng lại mang theo trạng thái cũ. Ví dụ hiệu ứng checkbox đang chạy dở của Task 2 sẽ hiện trên dòng của Task 3.

Hiểu nhầm hay gặp: key ở đây **không** làm giảm số lần build. Nó làm cho đúng dòng, không làm cho nhanh hơn.

Đừng dùng `UniqueKey()` cho dòng: mỗi lần build nó ra key mới, nên Flutter tạo lại dòng mọi lúc.

### precacheImage — vì sao nạp ảnh trước?

`precacheImage` đọc file ảnh và giải mã (decode) sẵn vào bộ nhớ đệm ảnh (image cache). Lần sau `Image.asset` cùng đường dẫn sẽ lấy từ cache, không phải đọc và giải mã lại.

Code trong `task_list_screen.dart`:

```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  precacheImage(const AssetImage(TaskDetailScreen.logoPath), context);
}
```

Khác nhau giữa `AssetImage` và `Image.asset`: `AssetImage` chỉ là "địa chỉ" của ảnh (một `ImageProvider`, không liên quan package `provider`), biết lấy ảnh ở đâu nhưng không tự vẽ. `Image.asset(path)` là widget vẽ ảnh, bên trong tự tạo `AssetImage(path)`; `precacheImage` nhận địa chỉ (`ImageProvider`) chứ không nhận widget, nên ở đây truyền `AssetImage`.

`static const logoPath`: `static` gắn hằng vào chính class `TaskDetailScreen` chứ không vào từng màn được tạo ra, nên `task_list_screen.dart` đọc được `TaskDetailScreen.logoPath` mà không cần tạo màn chi tiết. `const` nghĩa là giá trị cố định lúc biên dịch, nhờ vậy viết được `const AssetImage(TaskDetailScreen.logoPath)`.

Vì sao đặt ở `didChangeDependencies()`:

- không đặt trong `build()`: build chạy lại nhiều lần;
- không đặt trong `initState()`: `precacheImage` đọc `MediaQuery` qua `context`, mà Flutter không cho `initState()` đọc như vậy (bản debug báo lỗi ngay).

Bẫy im lặng: `precacheImage` và `Image.asset` phải dùng **cùng một đường dẫn**. Lệch một ký tự thì ảnh nạp sẵn không ai dùng, mà không có lỗi nào báo. Vì vậy cả hai dùng chung hằng `TaskDetailScreen.logoPath`.

Lợi ích trong app này nhỏ, vì logo chỉ 128×128. Chưa đo trên máy thật.

### width/height có làm ảnh nhẹ đi không?

Không. Đây là hiểu nhầm hay gặp.

`Image.asset(..., width: 64, height: 64)` chỉ quyết định kích thước **hiển thị**. Flutter vẫn giải mã ảnh theo **số pixel của file**.

Bộ nhớ sau giải mã bằng rộng × cao × 4 byte (mỗi pixel 4 byte màu RGBA). Đây là số tính, không phải số đo:

```
ảnh 512×512: 512 × 512 × 4 = 1 048 576 byte (1 MiB)
ảnh 128×128: 128 × 128 × 4 =    65 536 byte (64 KiB)   → ít hơn 16 lần
```

Vì vậy cách đơn giản nhất là thu nhỏ **file**. Flutter còn có tham số `cacheWidth`/`cacheHeight` để giải mã nhỏ hơn, nhưng bài này không dùng. Logo hiện ở ô 64×64; màn mật độ 2x cần đúng 64 × 2 = 128 pixel.

### flutter build apk --analyze-size — app nặng ở đâu?

Lệnh này build bản release kèm bảng phân tích dung lượng: code Dart, thư viện native, asset.

Phải chọn **một** kiến trúc CPU (ABI):

```
flutter build apk --analyze-size --target-platform android-arm64
```

Thiếu `--target-platform` thì Flutter dừng và báo:

```
Cannot perform code size analysis when building for multiple ABIs.
```

Kết quả gồm hai phần:

- bảng tóm tắt in ra terminal;
- một file JSON. Mở file này trong DevTools, mục App Size, để xem dạng cây (treemap).

Số liệu thật của Taskly nằm trong báo cáo, mục 12.3.

### Debug, Profile, Release khác nhau thế nào?

```
Debug    có hot reload, assert, công cụ debug → chậm, file to. Dùng khi viết code.
Profile  gần như release, còn giữ công cụ đo → dùng để xem FPS, jank trong DevTools.
Release  bỏ công cụ debug, Dart biên dịch trước (AOT) → nhanh, nhỏ. Bản để phát hành.
```

Release APK:

```
flutter build apk --release
→ build/app/outputs/flutter-apk/app-release.apk
```

Ký app (signing): Android chỉ cài APK đã ký. Template Flutter (`android/app/build.gradle.kts`) ký bản release bằng **khoá debug**.

- Đủ để cài thử lên máy.
- **Không** dùng được để đưa lên Google Play. Muốn phát hành thật phải tạo keystore riêng. Lab này chưa làm bước đó.

`flutter clean` xoá `build/` và `.dart_tool/`, để lần build sau làm lại từ đầu, không dính file cũ. Nó xoá luôn APK đã build, nên chép APK ra chỗ khác trước khi clean.

## Có những loại test nào?

**Unit test** — Kiểm logic thuần, không có giao diện. Viết bằng `test(...)`, chạy nhanh nhất. Ví dụ: `task_model_test.dart`, `task_repository_test.dart`.

**Widget test** — Kiểm giao diện và thao tác (gõ, bấm) trong môi trường giả lập, không cần máy thật. Viết bằng `testWidgets(...)`. Ví dụ: `task_list_widget_test.dart`.

**Navigation test** — Một dạng widget test, chỉ kiểm việc chuyển màn. Ví dụ: `task_navigation_test.dart`.

**Integration test** — Kiểm cả một luồng người dùng qua nhiều màn. Ví dụ: `task_integration_test.dart`. File này viết bằng `flutter_test` nên chạy bằng `flutter test`, không cần thiết bị.

Tháp test (testing pyramid): unit nhiều nhất, test càng bao nhiều màn thì càng ít. Bộ test này có 5 unit, 3 widget, 1 navigation, 1 integration.

**Mẫu AAA** — Mỗi test chia ba bước: Arrange (chuẩn bị) → Act (làm) → Assert (kiểm). Comment trong unit test và widget test đánh dấu từng bước. Integration test thì đánh dấu theo "Bước 1, 2, 3" của luồng.

Ở Lab 12, 10 test này đóng vai **kiểm hồi quy** (regression test): tối ưu xong mà test vẫn xanh nghĩa là thêm task, mở chi tiết và sửa title vẫn chạy đúng.

## Các lệnh trong widget test làm gì?

- `tester.pumpWidget(...)` — vẽ widget lần đầu.
- `tester.enterText(finder, 'Buy milk')` — gõ chữ vào ô nhập.
- `tester.tap(finder)` — bấm vào widget.
- `tester.pump()` — vẽ thêm một khung hình (frame). Sau khi bấm phải `pump()` mới thấy giao diện mới.
- `tester.pumpAndSettle()` — vẽ liên tục đến khi hết animation, vd hiệu ứng chuyển màn.
- `find.text`, `find.byKey`, `find.byType`, `find.widgetWithText` — tìm widget trên màn hình.
- `expect(finder, findsOneWidget)` — kiểm kết quả. Ngoài ra còn `findsNothing`, `findsNWidgets(2)`.

Một bẫy cần nhớ: `find.text('Buy milk')` khớp cả chữ đang nằm trong ô nhập. Vì vậy test kiểm "task có trong danh sách" bằng `find.widgetWithText(ListTile, 'Buy milk')`. `TaskTile` vẽ ra một `ListTile`, nên các test này không phải sửa.

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

## Chạy test và build thế nào?

Chạy từ thư mục `taskly/`:

```
flutter analyze
flutter test
flutter test --reporter expanded
flutter build apk --analyze-size --target-platform android-arm64
flutter clean
flutter build apk --release
flutter build apk --debug
```

Kết quả mong đợi của `flutter test`: `10` test, dòng cuối là `All tests passed!`.

`flutter clean` xoá mọi APK đã build, nên chạy `--release` và `--debug` sau nó.
