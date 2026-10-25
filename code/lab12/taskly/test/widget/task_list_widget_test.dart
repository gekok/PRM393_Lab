import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskly/main.dart';
import 'package:taskly/screens/task_list_screen.dart';

// Mỗi test pump TasklyApp với một kho mới của riêng nó: home của app chính là
// TaskListScreen, Provider nằm trên MaterialApp giống hệt app thật.
// `const TasklyApp()` là cùng một widget, nhưng mỗi test dựng cây widget mới
// nên Provider tạo một `TaskRepository()` mới; các test không dùng chung kho.
//
// `find.text` khớp cả Text lẫn EditableText (chữ đang nằm trong ô nhập). Sau
// `enterText('Buy milk')`, `find.text('Buy milk')` đã thấy chữ trong TextField
// dù task chưa được thêm. Vì vậy khẳng định "task có trong danh sách" phải tìm
// trong ListTile: `find.widgetWithText(ListTile, ...)`.
void main() {
  const emptyMessage = 'No tasks yet. Add one!';
  final taskTextField = find.byKey(const Key('taskTextField'));
  final addTaskButton = find.byKey(const Key('addTaskButton'));

  group('TaskListScreen', () {
    testWidgets('shows the empty state when there are no tasks', (
      tester,
    ) async {
      // Arrange + Act: pump màn danh sách với kho rỗng.
      await tester.pumpWidget(const TasklyApp());

      // Assert: đúng màn TaskListScreen, có thông báo rỗng, chưa có dòng nào.
      expect(find.byType(TaskListScreen), findsOneWidget);
      expect(find.text(emptyMessage), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('adding a task shows it and hides the empty state', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(const TasklyApp());

      // Act: gõ title rồi bấm nút thêm, pump một frame để UI rebuild.
      await tester.enterText(taskTextField, 'Buy milk');
      await tester.tap(addTaskButton);
      await tester.pump();

      // Assert: task nằm trong danh sách, thông báo rỗng biến mất.
      expect(find.widgetWithText(ListTile, 'Buy milk'), findsOneWidget);
      expect(find.text(emptyMessage), findsNothing);
    });

    testWidgets('adding two tasks shows both in the list', (tester) async {
      // Arrange
      await tester.pumpWidget(const TasklyApp());

      // Act: thêm lần lượt hai task.
      await tester.enterText(taskTextField, 'Buy milk');
      await tester.tap(addTaskButton);
      await tester.pump();
      await tester.enterText(taskTextField, 'Walk the dog');
      await tester.tap(addTaskButton);
      await tester.pump();

      // Assert: cả hai cùng hiện, danh sách có đúng hai dòng.
      expect(find.widgetWithText(ListTile, 'Buy milk'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Walk the dog'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(2));
    });
  });
}
