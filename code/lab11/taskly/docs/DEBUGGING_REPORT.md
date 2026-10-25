# Báo cáo debugging — Taskly (Lab 11.4, Part B)

Hai vấn đề dưới đây lấy từ code thật của app. Số đo lấy từ test tạm chạy bằng `flutter_test`. Test tạm chạy trên code trước và sau khi rút gọn, cho cùng số đo, rồi bị xoá khỏi suite. Chưa đo trên thiết bị thật.

## 1. Layout: vì sao hàng nhập liệu tràn ngang khi màn rất hẹp?

```
Trạng thái: ĐÃ THẤY trong môi trường test · TIỀM ẨN trên thiết bị thật
```

Code ở `lib/screens/task_list_screen.dart:49`:

```
Padding(16)
└─ Row
   ├─ Expanded(TextField)
   ├─ SizedBox(width: 8)
   └─ ElevatedButton("Add")
```

Khoảng cách 8 px và nút Add không co lại được. Khi màn quá hẹp, `Expanded` co về 0 mà vẫn thiếu chỗ. Lúc đó `Row` tràn sang phải.

Quét độ rộng bằng `setSurfaceSize` (danh sách có 1 task):

```
400 / 320 / 140 / 131 px   không lỗi
130 px   A RenderFlex overflowed by 0.300 pixels on the right.
120 px   A RenderFlex overflowed by 10 pixels on the right.
100 px   A RenderFlex overflowed by 30 pixels on the right.
```

Con số khớp phép tính:

```
padding 2 × 16 + khoảng cách 8 + nút Add 90.3 = 130.3 px
```

Nút Add rộng `90.3 px`, đo bằng một test tạm khác trong `flutter_test`. Màn hẹp hơn 130.3 px là tràn. Flutter làm tròn số tràn lớn hơn 10 px khi in, nên 10.3 hiện thành `10`.

Vì sao chỉ là **tiềm ẩn** trên máy thật:

- Các số trên đo trong `flutter_test`. Trên máy thật chưa đo, nên ngưỡng thật có thể khác.
- Điện thoại thường rộng từ 320 dp, rộng hơn ngưỡng nhiều.

Hướng sửa (chưa áp dụng): đổi nút Add thành `IconButton` cho gọn, hoặc dùng `LayoutBuilder` để xếp dọc khi hẹp.

## 2. Hiệu năng: vì sao tick một task làm cả màn build lại?

```
Trạng thái: ĐÃ THẤY cơ chế rebuild · CHƯA ĐO độ chậm
```

Code ở `lib/screens/task_list_screen.dart:40`: `context.watch<TaskProvider>()` nằm ở đầu `build`.

`watch` đăng ký cả màn với provider. Mỗi lần `notifyListeners()`, toàn bộ `build` chạy lại.

Đếm bằng hook `debugOnRebuildDirtyWidget` của Flutter. DevTools đếm rebuild cũng qua hook này (hook được gắn bởi `WidgetInspectorService` trong Flutter SDK). Danh sách 3 task, tick checkbox của task 1:

```
TaskListScreen 1 · AppBar 1 · TextField 1 · ListTile 3 · Checkbox 3
```

Chỉ 1 dòng đổi, nhưng cả 3 `ListTile`, `AppBar` và ô nhập đều build lại.

Vì sao độ chậm chỉ là **tiềm ẩn**:

- Chưa đo thời gian build. Với 3 task, số widget build lại còn ít (số đếm ở trên).
- `ListView.builder` chỉ build các dòng đang hiển thị, cộng một vùng đệm nhỏ ngoài màn (`cacheExtent`, mặc định 250 px). Số widget build lại tăng theo số dòng trên màn, không theo tổng số task.
- Riêng getter `tasks` thì mỗi lần đọc tạo một list mới chứa cả danh sách (`List.unmodifiable`).

Hướng sửa (Lab 12): tách `TaskTile`, dùng `Selector`, thêm `const`, gán `ValueKey(task.id)`.

## 3. Test và DevTools giúp phát hiện thế nào?

Lỗi tràn không làm app crash:

- **Bản debug:** vẽ dải sọc vàng–đen ở mép bị tràn và in lỗi `A RenderFlex overflowed…` ra console.
- **Bản release:** không có cảnh báo nào. Phần vẽ sọc và báo lỗi nằm trong `assert`, mà `assert` chỉ chạy ở debug (Flutter SDK, `rendering/flex.dart`). Phần bị tràn vẫn được vẽ, lệch ra ngoài mép, vì `Row` mặc định không cắt (`Clip.none`).

Vì không ai được báo lỗi, lỗi này dễ lọt. Test và DevTools giúp thấy nó:

- **Widget test:** overflow được báo thành exception, test fail. Đặt `setSurfaceSize` nhỏ là quét được nhiều độ rộng trong vài giây.
- **DevTools Widget Inspector:** chọn `Row` để xem constraints và kích thước từng widget con.
- **DevTools đếm rebuild:** bật chế độ đếm rebuild rồi tick một checkbox. Theo số đo ở mục 2, số đếm sẽ cho thấy cả những `ListTile` không đổi cũng build lại. Timeline của trang Performance cho biết thời gian build của từng frame.

Ảnh chụp Widget Inspector và Performance Timeline chưa có. Tên mục chính xác trong DevTools 2.60 chưa được kiểm, vì DevTools chưa được mở.
