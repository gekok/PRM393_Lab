import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskly/main.dart';
import 'package:taskly/screens/task_detail_screen.dart';

// Luồng đầy đủ qua hai màn: thêm → mở chi tiết → sửa → lưu → quay lại danh
// sách. Chạy bằng `flutter test` (flutter_test, không cần thiết bị). Test pump
// cả app thật (TasklyApp, bắt đầu với kho rỗng) và kiểm kết quả trên UI.
//
// Khẳng định "có" thì tìm trong ListTile, vì `find.text` khớp cả chữ trong ô
// nhập (EditableText). Khẳng định "không còn" thì tìm toàn màn hình: chặt
// hơn, vì title cũ không được sót lại ở bất kỳ đâu.
void main() {
  testWidgets('add, open, edit and save shows the updated title in the list', (
    tester,
  ) async {
    await tester.pumpWidget(const TasklyApp());

    // Bước 1: thêm task "Original title".
    await tester.enterText(
      find.byKey(const Key('taskTextField')),
      'Original title',
    );
    await tester.tap(find.byKey(const Key('addTaskButton')));
    await tester.pump();
    expect(find.widgetWithText(ListTile, 'Original title'), findsOneWidget);

    // Bước 2: bấm vào task để mở màn chi tiết.
    await tester.tap(find.text('Original title'));
    await tester.pumpAndSettle();
    expect(find.byType(TaskDetailScreen), findsOneWidget);

    // Bước 3: sửa title rồi bấm Save.
    await tester.enterText(
      find.byKey(const Key('detailTitleField')),
      'Updated title',
    );
    await tester.tap(find.byKey(const Key('detailSaveButton')));
    await tester.pumpAndSettle();

    // Assert UI: đã quay về danh sách, title mới hiện, title cũ biến mất.
    expect(find.byType(TaskDetailScreen), findsNothing);
    expect(find.widgetWithText(ListTile, 'Updated title'), findsOneWidget);
    expect(find.text('Original title'), findsNothing);
  });
}
