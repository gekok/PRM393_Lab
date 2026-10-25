# Tóm tắt test suite — Taskly (Lab 11.5)

Môi trường: Flutter 3.47.7, Dart 3.13.5, package provider 6.1.5+1.

## Kết quả lần chạy cuối

Lệnh `flutter test --reporter expanded`:

```
10 test — 10 pass — 0 fail
```

Lệnh `flutter analyze`:

```
No issues found!
```

## Có bao nhiêu test, thuộc loại nào?

Theo file (đếm từ output `flutter test --reporter expanded --concurrency=1`):

| File | Loại | Số test |
|---|---|---|
| `test/unit/task_model_test.dart` | Unit | 2 |
| `test/unit/task_repository_test.dart` | Unit | 3 |
| `test/widget/task_list_widget_test.dart` | Widget | 3 |
| `test/widget/task_navigation_test.dart` | Navigation | 1 |
| `test/integration/task_integration_test.dart` | Integration | 1 |

Theo loại:

```
Unit           5
Widget         3
Navigation     1
Integration    1
Tổng          10
```

Navigation test nằm trong thư mục `test/widget/`, đúng đường dẫn đề 11.3 yêu cầu. Đếm theo **thư mục** sẽ ra widget = 4. Đếm theo **loại** thì navigation được tách riêng như trên.

Phân bố theo hình tháp test (testing pyramid): unit nhiều nhất (5). Navigation và integration ít nhất, mỗi loại 1.

Vì sao integration test nằm ở `test/integration/`? Đề ghi hai chỗ khác nhau:

- Lab 11.4 ghi `test/widget/task_integration_test.dart`;
- Lab 11.5 yêu cầu cấu trúc `test/unit/`, `test/widget/`, `test/integration/`.

File được đặt theo 11.5, bước tổng hợp cuối. Test viết bằng `flutter_test` (`testWidgets`), không dùng package `integration_test`, nên chạy được bằng `flutter test` mà không cần thiết bị.

## Những hành vi nào được kiểm?

### Unit — `Task`

1. `completed` mặc định là `false`.
2. `toggle()` đổi `false → true`, gọi thêm lần nữa thì `true → false`.

### Unit — `TaskRepository`

3. `addTask` thêm đúng một task, đúng title, chưa hoàn thành.
4. `deleteTask` xoá task ở **giữa** trong 3 task. Chỉ task đó mất, hai task còn lại giữ nguyên thứ tự.
5. `updateTask` sửa task ở **dòng thứ hai** trong 2 task. Id giữ nguyên, title đổi, task đầu không bị đụng.

### Widget — `TaskListScreen`

6. Kho rỗng → hiện `No tasks yet. Add one!`, chưa có dòng nào.
7. Nhập `Buy milk`, bấm `addTaskButton`:
   - task hiện trong danh sách;
   - thông báo rỗng biến mất.
8. Thêm hai task → cả hai cùng hiện, danh sách có đúng 2 dòng.

### Navigation

9. Seed kho với `Demo task`, bấm vào nó, rồi `pumpAndSettle()`:
   - AppBar có `Task Detail`;
   - có ô `detailTitleField`.

### Integration

10. Luồng đầy đủ qua hai màn:

```
thêm "Original title"
↓
bấm vào task → mở màn chi tiết
↓
sửa thành "Updated title" → Save
↓
quay về danh sách
```

Kết quả được kiểm trên UI:

- danh sách hiện `Updated title`;
- `Original title` không còn ở bất kỳ đâu trên màn hình.

## Test có phát hiện lỗi logic nào không?

**Suite chính thức: không.** Lần chạy đầu của suite pass hết. Lúc đó suite có 17 test, sau này rút gọn còn 10. Không có dòng code app nào phải sửa vì một test **của suite** fail.

**Một test tạm ngoài suite thì có, và lỗi đó đã được sửa:**

- **Ở đâu:** `TaskProvider.toggleTask` (`lib/providers/task_provider.dart`).
- **Lỗi gì:** bản đầu gọi `toggle()` thẳng trên object `Task` đang nằm trong kho.
- **Vì sao suite không thấy:** màn hiện tại dùng `context.watch` nên vẽ lại cả màn, che mất lỗi.
- **Khi nào lộ ra:** khi Lab 12 dùng `Selector<TaskProvider, List<Task>>`. `Selector` so sánh từng phần tử theo object. Sửa tại chỗ thì list cũ và list mới chứa cùng object, nên `Selector` coi như không có gì đổi.
- **Bằng chứng:** test tạm dựng đúng `Selector<TaskProvider, List<Task>>` rồi tick:
  - trước khi sửa: dữ liệu `completed=true`, checkbox vẫn hiện `false`;
  - sau khi sửa: dữ liệu `completed=true`, checkbox hiện `true`.
- **Sửa thế nào:** provider tạo một `Task` mới (cùng id, title, completed), gọi `toggle()` trên task mới, rồi lưu qua `updateTask`. `updateTaskTitle` cũng tạo `Task` mới theo cách đó.

Khi rút gọn code, điều này được kiểm lại bằng một test tạm khác (chạy một lần rồi xoá khỏi suite):

- code hiện tại: `Selector` thấy cả tick, đổi tên, thêm và xoá;
- đối chứng, toggle tại chỗ rồi notify: dữ liệu `completed=true` nhưng `Selector` vẫn hiện `false`.

## Chi tiết kỹ thuật đáng chú ý

- `find.text` khớp cả `Text` lẫn `EditableText` (chữ trong ô nhập). Sau `enterText('Buy milk')`, `find.text('Buy milk')` đã thấy chữ trong TextField dù task chưa được thêm. Vì vậy:
  - khẳng định "có trong danh sách" tìm trong `ListTile` (`find.widgetWithText(ListTile, ...)`);
  - khẳng định "không còn" tìm trên toàn màn hình.
- Widget test của danh sách và integration test pump `const TasklyApp()`. Đó là app thật, mỗi test bắt đầu với một kho rỗng mới.
- Navigation test cần kho có sẵn task. Nó tự dựng `ChangeNotifierProvider` với kho đã seed, bọc `MaterialApp(home: TaskListScreen())`. Provider đặt trên `MaterialApp` giống `TasklyApp`.
- Mỗi test của repository tự tạo kho mới ở bước Arrange. Unit test và widget test đều theo mẫu AAA: Arrange → Act → Assert.

## Giới hạn đã biết

Suite chỉ giữ đúng 10 test của đề. Những hành vi sau có trong app nhưng **không có test trong suite**:

1. Tick checkbox trên UI và `TaskProvider.toggleTask`.
2. Nút xoá trên UI.
3. Title rỗng hoặc chỉ có khoảng trắng:
   - bấm Add: không thêm, ô nhập giữ nguyên chữ đang gõ;
   - bấm Save ở màn chi tiết: title cũ giữ nguyên, màn vẫn quay về danh sách;
   - app không hiện thông báo lỗi nào cho hai trường hợp trên (đọc từ code, không có test).
4. Id không bị dùng lại sau khi xoá (kho dùng bộ đếm `_nextId`).
5. Nhánh "id không tồn tại" của `deleteTask` và `updateTask`.
6. Ô `detailTitleField` được điền sẵn đúng title của task vừa bấm.
7. `TaskProvider` chưa có unit test riêng. Nó chỉ được kiểm gián tiếp qua widget/integration test (thêm, sửa title).

Các mục 1–6 đã được kiểm bằng test tạm khi rút gọn code, trừ ý "không hiện thông báo lỗi" ở mục 3. Test tạm chạy trên code trước và sau khi rút gọn, cả hai lần đều pass, rồi bị xoá khỏi suite.

Riêng việc bấm Add thành công thì ô nhập được xoá: không có test riêng, nhưng integration test bắt được gián tiếp. Nếu ô nhập không được xoá, `find.text('Original title')` ở bước 2 sẽ khớp 2 widget (dòng trong danh sách và chữ trong ô nhập). Khi đó `tester.tap` báo lỗi vì không biết bấm cái nào.

Giới hạn khác:

- Hai test xoá/sửa của repository chưa phân biệt được "theo id" với "theo vị trí `id - 1`". Task được xoá/sửa có id 2 và nằm đúng vị trí 1, nên code lỡ dùng `id - 1` làm vị trí vẫn pass.
- Integration test chạy bằng `flutter_test` trong môi trường không có giao diện thật (headless). Nó không phải package `integration_test` chạy trên thiết bị, nên không bắt được lỗi riêng của nền tảng.
- Không có test layout ở màn hẹp. Lỗi tràn ngang khi cửa sổ rất hẹp chỉ được đo bằng test tạm (xem `DEBUGGING_REPORT.md`).
- Title không giới hạn độ dài.
- Không có golden test, không có test hiệu năng, không đo coverage.
- Dữ liệu chỉ nằm trong bộ nhớ, nên không có gì về lưu trữ để test.
